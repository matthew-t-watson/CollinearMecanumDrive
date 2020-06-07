classdef flatOutputClass < handle
    % Stores the waypoints and generates polynomials for a single flat
    % output.
    
    properties (Access = public)
        numWaypoints % Returns number of waypoints in obj.waypoints
        numSegments % Returns number of polynomial segments, or numWaypoints-1
        polyCoefs % Cell array of optimised polynomial coefficients with length numSegments
        config % Structure containing all configuration variables relevant to the setup of the object
        polyDegree % Getter for polynomial polyDegree to be used
        tend % Time index of last waypoint
        waypoints % Vector of structs representing waypoints
        segmentAcceleration % Acceleration of trapezoidal segments, used in defining SOS constraints
        segmentInitialVelocity % Initial velocity of trapezoidal segment
        segmentType % Type of segment optimisation, used for plotting
        optimisedByMethod % Flag that is set when polyCoefs contains optimised coefficients for the current set of waypoints
        prevOut
    end
    
    properties (Access = private)
        %numVar % Number of optimisation variables
        %polyOptFuns % Functions for generating H and Aeq matrices for polynomial optimisation
        precompiled % Structure of precompiled optimisation data
        SDerivativesFun % Function handle for getting S derivatives at a given t
        vMax
        aMax
    end
       
    methods 
        
        %% Init functions
        function obj = flatOutputClass(config)
            %flatOutputClass Constructor
            obj.config = config;
            obj.reinitialise;
            obj.vMax = [];
            obj.aMax = [];
        end
        
        function reinitialise(obj)
            obj.waypoints = [];
            obj.optimisedByMethod = optimisationTypeEnum.none;
            obj.precompiled = [];
            obj.precompiled.waypointTypes = [];
            obj.precompiled.config = [];
            obj.optimisedByMethod = 0;
            obj.polyCoefs = [];
            obj.prevOut = [];
            obj.segmentType = segmentTypeEnum.free;
        end
        
        function setConstraints(obj, vMax, aMax)
            obj.vMax = vMax;
            obj.aMax = aMax;
            obj.optimisedByMethod = optimisationTypeEnum.none;
        end
        
        function updatePolyCoefsForStepTrajectory(obj)
            % Function to configure polycoefs to represent a series of step
            % trajectories between position waypoints. Requires all
            % waypoints to be of type boundary or position.
                       
            obj.polyCoefs = zeros(obj.config.polyDegree+1,obj.numSegments);
            for i=1:obj.numSegments
                obj.polyCoefs(:,i) = flipud([obj.waypoints(i+1).val(1); zeros(obj.config.polyDegree,1)]);
            end
            
            obj.optimisedByMethod = optimisationTypeEnum.step;
        end
            
        function setTrajectoryFromPolyCoefs(obj, p, dt)   
            
            t = [0 cumsum(dt)];
            obj.reinitialise;
            obj.polyCoefs = p;
            obj.addWaypoint(polyval(p(:,1), 0), 0, 'boundary');
            for j=2:size(p,2)-1
                obj.addWaypoint(polyval(p(:,j), 0), t(j), 'position');
            end
            obj.addWaypoint(polyval(p(:,end), dt(end)), t(end), 'boundary');
            obj.optimisedByMethod = optimisationTypeEnum.manual;
        end
        
        function manuallySetPolyCoefs(obj,idx,p)
            obj.polyCoefs(:,idx) = p(:);
            obj.optimisedByMethod = optimisationTypeEnum.manual;
        end
        
        %% Optimisation functions        
        function out = optimiseFlatOutputQRDecomposition(obj, verbosity, durations)
            % Defines and optimises problem using QR decomposition. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            % Optional arguments kv and vMax can be used to include a cost
            % on any velocity constrained sections with velocities greater
            % than vMax.
            % This cannot be performed in YALMIP as it does not allow the
            % removal of equalities when using the optimizer object.
                        
            forceRegen = false;
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations); 
                end
            end                 
            
            if (obj.optimisedByMethod == optimisationTypeEnum.QR_decomp) && ~forceRegen
                disp('Problem unchanged, reusing solution');
                out = obj.prevOut;
                return;
            end
            
            % Regenerate QP functions if problem has changed
            if (~isequal(obj.precompiled.waypointTypes, vertcat(obj.waypoints(:).type)) || ...             
                ~isequal(obj.precompiled.config, obj.config))
                % Define time variable
                syms t real;
                dt = sym('dt', [1 numel(durations)], 'Real');
                assumeAlso(dt>0);

                % Define polynomials and their derivatives, plus waypoint
                % value variables
                for i=1:obj.numSegments
                    % Define polycoefs
                    if obj.waypoints(i).type ~= waypointTypeEnum.velocityConstraint || ...
                            obj.waypoints(i+1).type ~= waypointTypeEnum.velocityConstraint
                        % Full polyDegree polynomial segment
                        pCoefs{i} = sym(['polyCoefs_' num2str(i) '_'], [obj.config.polyDegree+1 1], 'real');
                        obj.segmentType(i) = segmentTypeEnum.free;  
                    else
                        % Constant velocity segment
                        pCoefs{i} = sym(['polyCoefs_' num2str(i) '_'], [obj.config.polyDegreeVelSeg+1 1], 'real');
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;  
                    end

                    p(i,1) = poly2sym(pCoefs{i},t);

                    for j=2:max([obj.config.conDerivDeg, 6])
                        p(i,j) = diff(p(i,1),t,j-1);
                    end
                end
                
                % Define waypoint value variables
                for i=1:obj.numWaypoints
                    val{i} = sym(['val' num2str(i) '_'], [numel(obj.getDerivativesDefinedByType(obj.waypoints(i).type)), 1]);
                end

                % Cost function
                for i=1:obj.numSegments
                    J(i) = int(p(i,obj.config.derivToMin+1)^2,t,0,dt(i));
                end
                J = sum(J);

                %% Build parameterised equality constraint vector.
                Feq = []; % Constraints in form Feq(x)=0

                % Define segment initial constraints
                for i=1:obj.numSegments
                    if obj.waypoints(i).type ~= waypointTypeEnum.velocityConstraint
                        Feq = [Feq; subs(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0)' - val{i}];
                    end
                end

                % Define final segment terminal constraint
                Feq = [Feq; subs(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end))' - val{end}];

                % Define intermediary equivalence constraints
                for i=1:obj.numSegments-1
                    Feq = [Feq; subs(p(i,1:obj.config.conDerivDeg+1),t,dt(i))' - subs(p(i+1,1:obj.config.conDerivDeg+1),t,0)'];
                end
                
                % Create optimisation matrices
                x = vertcat(pCoefs{:});
                Aeq = jacobian(Feq,x);
                beq = -simplify(Feq - Aeq*x);
                H = hessian(J,x);
                              
                obj.precompiled.Aeq = matlabFunction(Aeq, 'Vars', {dt});
                obj.precompiled.beq = matlabFunction(beq, 'Vars', {vertcat(val{:})});
                obj.precompiled.H = matlabFunction(H, 'Vars', {dt});
                
                for i=1:obj.numSegments
                    obj.precompiled.polyCoefsIndices{i} = 1:numel(pCoefs{i});
                end
                
                for i=2:obj.numSegments
                    obj.precompiled.polyCoefsIndices{i} = obj.precompiled.polyCoefsIndices{i} + obj.precompiled.polyCoefsIndices{i-1}(end);
                end
                
                % Store data structure used to generate optimizer for
                % future comparison
                obj.precompiled.waypointTypes = vertcat(obj.waypoints(:).type);                
                obj.precompiled.config = obj.config;
            end
                        
            tic;            
            % Calculate optimisation variables for given durations
            Aeq = obj.precompiled.Aeq(durations);
            beq = obj.precompiled.beq(vertcat(obj.waypoints(:).val));
            H = obj.precompiled.H(durations);           
            
            method = 1;
            if method == 1   
                % Find QR decomposition of Aeq'
                [Q,R] = qr(Aeq');

                % QR = [Qhat QN][Rhat;0]
                Rhat = R(1:rank(Aeq),:);
                Qhat = Q(:,1:rank(Aeq));
                QN = Q(:,rank(Aeq)+1:end);

                xhat = Qhat*((Rhat')\beq);
                v = -(QN'*H*QN)\(xhat'*H*QN)';

                x = xhat + QN*v;
            elseif method == 2
                opt = optimset('quadprog');
                opt.Display = 'off';
                opt.TolX = 1e-12;
                x = quadprog(H,[],[],[],Aeq,beq,[],[],[],opt);
            end
            
            t_exec = toc;
            
            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.setPolyCoefs(i, [zeros(obj.config.polyDegree+1-numel(obj.precompiled.polyCoefsIndices{i}),1); x(obj.precompiled.polyCoefsIndices{i})]);
            end
            
            J = x'*H*x;
            
            if verbosity>0
                disp(['Polynomial coefficients optimised in ' num2str(t_exec) ' seconds.']);
            end
            
            % Set optimised flag
            obj.optimisedByMethod = optimisationTypeEnum.QR_decomp;
            
            % Set outputs
            out.J = J;
            out.vMax = [];
            out.solveTime = t_exec;
            for i = 2:3:obj.numSegments
                out.vMax = abs([out.vMax; obj.polyCoefs(end-1,i)]);
            end
            
            % Store result for reuse
            obj.prevOut = out;
        end
        
        function out = optimiseFlatOutputYALMIPQP(obj, verbosity, durations)
            % Defines and optimises problem using YALMIP. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations);
                end
            end                        
            
            % Shortcut if optimisation parameters haven't changed and we've already optimised
            forceRegen = false;
            if (obj.optimisedByMethod == optimisationTypeEnum.QP_YALMIP) && ~forceRegen
                disp('Problem unchanged, reusing solution');
                out = obj.prevOut;
                return;
            end
            tic;

            % Prevents accumulation of junk in memory, giving a massive performance boost in gradient descent
            yalmip('clear');

            % Define independent time variable
            sdpvar t;

            p = sdpvar(obj.numSegments, max([obj.config.conDerivDeg+1, obj.config.derivToMin+1, 6]));

            % Define durations variable
            dt = durations;

            % Define polynomials and their derivatives
            for i=1:obj.numSegments
                if numel(obj.segmentAcceleration) == obj.numSegments
                    if obj.segmentAcceleration(i) == 0
                        % Constant velocity segment
                        p(i,1) = polynomial(t,obj.config.polyDegreeVelSeg);
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;
                    else
                        % Full polyDegree acceleration segment
                        p(i,1) = polynomial(t,obj.config.polyDegree);
                        obj.segmentType(i) = segmentTypeEnum.free;                        
                    end
                else
                    % Trapezoidal optimisation not performed, all
                    % segments are full polyDegree
                    p(i,1) = polynomial(t,obj.config.polyDegree);
                    obj.segmentType(i) = segmentTypeEnum.free;    
                end

                for j=2:max([obj.config.conDerivDeg+1, obj.config.derivToMin+1, 6])
                    p(i,j) = jacobian(p(i,j-1),t);
                end
            end

            % Cost function
            for i=1:obj.numSegments
                J(i) = int(p(i,obj.config.derivToMin+1)^2,t,0,dt(i));
            end
            J = sum(J)/1e6;

            % Define segment initial constraints if the waypoint defines position
            F = [];
            for i=1:obj.numSegments
                if ismember(1, obj.getDerivativesDefinedByType(obj.waypoints(i).type))
                    F = [F (replace(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0) == obj.waypoints(i).val'):['Position constraint waypoint ' num2str(i) ' of type ' char(obj.waypoints(i).type)]];
                end
            end

            % Define final segment terminal constraint
            F = [F (replace(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end)) == obj.waypoints(end).val'):['Position constraint waypoint ' num2str(obj.numWaypoints) ' of type ' char(obj.waypoints(end).type)]];

            % Define intermediary equivalence constraints
            for i=1:obj.numSegments-1
                F = [F (replace(p(i,1:obj.config.conDerivDeg+1),t,dt(i)) == replace(p(i+1,1:obj.config.conDerivDeg+1),t,0)):['Derivative equivalence segment ' num2str(i) ' to ' num2str(i+1)]];
            end

            % Velocity inequalities at boundaries
            for i=1:obj.numSegments
                % Constrain velocity at start and end
                F = [F -obj.vMax <= replace(p(i,2), t, 0) <= obj.vMax];
                F = [F -obj.vMax <= replace(p(i,2), t, dt(i)) <= obj.vMax];
            end

            opt = sdpsettings;
            opt.removeequalities = 1;
            opt.verbose = verbosity;
            opt.showprogress = verbosity>0;
            opt.cachesolvers = 1;
            opt.quadprog.MaxIter = 1e5;
            opt.solver = 'quadprog';

            % Perform optimization
            diag = optimize(F,J,opt);

            % Check for silly solution and run again without removing
            % equalities if found
            if any(isnan(value(coefficients(p(:,1),t))))
                if verbosity>0
                    warning('Optimizing with constraint elmination yielded NaN, running again without eliminating constraints');
                end
                opt.removeequalities = 0;
                diag = optimize(F,J,opt);
            end


            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.setPolyCoefs(i, flipud([value(coefficients(p(i,1),t)); zeros(obj.config.polyDegree+1-numel(coefficients(p(i,1),t)),1)]));
            end

            % Get final cost
            J = value(J);

            if diag.problem == 1
                % Infeasible problem
                J = inf;
            end


            t_derive = toc;

            if verbosity>0
                disp(['Polynomial coefficients optimised in ' num2str(diag.solvertime) ' seconds.']);
                disp(['Derivation & solution completed in ' num2str(t_derive) ' seconds']);
            end

            % Set optimised flag
            obj.optimisedByMethod = optimisationTypeEnum.QP_YALMIP;

            % Set outputs
            out.J = J;
            out.vMax = [];
            out.solveTime = diag.solvertime;
            for i = 2:3:obj.numSegments
                out.vMax = abs([out.vMax; obj.polyCoefs(end-1,i)]);
            end

            % Store parameters and results for reuse
            obj.prevOut = out;
        end
        
        function out = optimiseFlatOutputYALMIPAccelerationSOSBounded(obj, verbosity, durations)
            % Defines and optimises problem using YALMIP. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            % SOS constraints are enforced on full polyDegree segments,
            % velocity inequalities are enforced on all segment boundaries.
            tic
            forceRegen = true;
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations);
                end
            end 
            
            % Shortcut if optimisation parameters haven't changed and we've
            % already optimised
            if (obj.optimisedByMethod == optimisationTypeEnum.SOS) && ~forceRegen
                if verbosity
                    disp('Reusing existing solution');
                end
                out = obj.prevOut;
                return;
            end
            % Prevents accumulation of junk in memory, giving a massive performance boost in gradient descent
            yalmip('clear');

            % Define independent time variable
            sdpvar t;

            p = sdpvar(obj.numSegments, max([obj.config.conDerivDeg, 6]));
            s_t = sdpvar(obj.numSegments, 1);
            t_t = sdpvar(obj.numSegments, 1);

            % Define durations variable
            dt = durations;

            % Define acceleration polynomials, their integrals, and their derivatives
            for i=1:obj.numSegments
                if numel(obj.segmentAcceleration) == obj.numSegments
                    if obj.segmentAcceleration(i) == 0
                        if obj.config.polyDegreeVelSeg == 1
                            p(i,3) = 0;
                        else
                            p(i,3) = polynomial(t,obj.config.polyDegreeVelSeg-2);
                        end
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;
                    else
                        % Full polyDegree acceleration segment
                        if mod(obj.config.polyDegree-2,2) == 0
                            d = (obj.config.polyDegree-2)/2;
                            s_t(i) = polynomial(t, 2*d);
                            t_t(i) = polynomial(t, (2*d)-2);
                            p(i,3) = s_t(i) + t*(dt(i)-t)*t_t(i);
                        else
                            d = (obj.config.polyDegree-3)/2;
                            s_t(i) = polynomial(t, 2*d);
                            t_t(i) = polynomial(t, 2*d);
                            p(i,3) = t*s_t(i) + (dt(i)-t)*t_t(i);
                        end
                        obj.segmentType(i) = segmentTypeEnum.free;
                    end
                else
%                         % Trapezoidal optimisation not performed, all
%                         % segments are full polyDegree
%                         p(i,1) = polynomial(t,obj.config.polyDegree);
%                         obj.segmentType(i) = segmentTypeEnum.free;    
                        error('to do');
                end

                % Generate higher derivatives
                for j=4:max([obj.config.conDerivDeg, 6])
                    p(i,j) = jacobian(p(i,j-1),t);
                end
                
                % and lower derivatives
                p(i,2) = int(p(i,3),t) + sdpvar;
                p(i,1) = int(p(i,2),t) + sdpvar;
            end

            % Cost function
            for i=1:obj.numSegments
                J(i) = int(p(i,6)^2,t,0,dt(i));
            end
            J = sum(J)/1e6;

            % Define segment initial constraints if the waypoint defines position
            F = [];
            for i=1:obj.numSegments
                if ismember(1, obj.getDerivativesDefinedByType(obj.waypoints(i).type))
                    F = [F (replace(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0) == obj.waypoints(i).val'):['Position constraint waypoint ' num2str(i) ' of type ' char(obj.waypoints(i).type)]];
                end
            end

            % Define final segment terminal constraint
            F = [F (replace(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end)) == obj.waypoints(end).val'):['Position constraint waypoint ' num2str(obj.numWaypoints) ' of type ' char(obj.waypoints(end).type)]];

            % Define intermediary equivalence constraints
            for i=1:obj.numSegments-1
                F = [F (replace(p(i,1:obj.config.conDerivDeg),t,dt(i)) == replace(p(i+1,1:obj.config.conDerivDeg),t,0)):['Derivative equivalence segment ' num2str(i) ' to ' num2str(i+1)]];
            end

            % Apply SOS constraints using sign of trapezoidal
            % acceleration and velocity
            for i=1:obj.numSegments
                % Break if trapezoidal optimisation has not been
                % performed
                if numel(obj.segmentAcceleration) ~= obj.numSegments
                    break;
                end
                if sign(obj.segmentAcceleration(i)) ~= 0
                    F = [F (sos(sign(obj.segmentAcceleration(i))*s_t(i))):['SOS constrained acceleration segment ' num2str(i)]];
                    F = [F (sos(sign(obj.segmentAcceleration(i))*t_t(i))):['SOS constrained acceleration segment ' num2str(i)]];
                    obj.segmentType(i) = segmentTypeEnum.sosConstrained;
                end

                % Constraint velocity at end of segment
                F = [F -obj.vMax <= replace(p(i,2), t, dt(i)) <= obj.vMax];
            end

            opt = sdpsettings;
            opt.removeequalities = 1;
            % SSOS, DSOS, SDSOS options from https://github.com/yalmip/YALMIP/issues/505
            % 2=Image model, 4=reduced nonlinear(SSOS?), 5=DSOS,6=SDSOS
            opt.sos.model = 2;
            opt.solver = 'mosek';
            opt.mosek.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1e-6; % 1e-8 default
            opt.mosek.MSK_DPAR_INTPNT_CO_TOL_DFEAS = 1e-6; % 1e-8 default
            opt.mosek.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = 1e-5; % 1e-7 default
            opt.verbose = verbosity;
            opt.showprogress = verbosity>0;
            opt.cachesolvers = 0;
            opt.sedumi.eps = 1e-3; % SOS optimisation can yield better solutions by decreasing sedumi eps tolerance, see https://geekeeway.blogspot.com/2013/06/yalmip-with-mosek.html


            % Perform optimization
            diag = optimize(F,J,opt);

            % Check for silly solution and run again without removing
            % equalities if found
            if any(isnan(value(coefficients(p(:,1),t))))
                if verbosity>0
                    warning('Optimizing with constraint elmination yielded NaN, running again without eliminating constraints');
                end
                opt.removeequalities = 0;
                diag = optimize(F,J,opt);
            end


            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.setPolyCoefs(i, flipud([value(coefficients(p(i,1),t)); zeros(obj.config.polyDegree+1-numel(coefficients(p(i,1),t)),1)]));
            end

            % Get final cost
            J = value(J);

            if diag.problem == 1
                % Infeasible problem
                J = inf;
                if verbosity
                    disp('Solver reported infeasible problem')
                end
            end


            t_derive = toc;

            if verbosity>0
                diag
                disp(['Polynomial coefficients optimised in ' num2str(diag.solvertime) ' seconds.']);
                disp(['Derivation & solution completed in ' num2str(t_derive) ' seconds']);
            end

            % Set optimised flag
            obj.optimisedByMethod = optimisationTypeEnum.SOS;

            % Set outputs
            out.J = J;
            out.vMax = [];
            out.solveTime = diag.solvertime;
            for i = 2:3:obj.numSegments
                p = obj.getPolyCoefs(i);
                out.vMax = abs([out.vMax; p(end-1)]);
            end

            % Store parameters and results for reuse
            obj.prevOut = out;
        end
        
        function out = optimiseFlatOutputYALMIPVelocitySOS(obj, verbosity, durations)
            % Defines and optimises problem using YALMIP. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            % SOS constraints are enforced on full polyDegree segments,
            % velocity inequalities are enforced on all segment boundaries.
            tic
            forceRegen = true;
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations);
                end
            end 
            
            % Shortcut if optimisation parameters haven't changed and we've
            % already optimised
            if (obj.optimisedByMethod == optimisationTypeEnum.SOS) && ~forceRegen
                if verbosity
                    disp('Reusing existing solution');
                end
                out = obj.prevOut;
                return;
            end
            % Prevents accumulation of junk in memory, giving a massive performance boost in gradient descent
            yalmip('clear');

            % Define independent time variable
            sdpvar t;
            F = []; % Clear constraints
            c = {}; % Clear coefficients

            p = sdpvar(obj.numSegments, max([obj.config.conDerivDeg, 6]));
            q = sdpvar(obj.numSegments, 2);
            v = sdpvar(obj.numSegments, 2);

            % Define durations variable
            dt = durations;

            % Define velocity polynomials, their integrals, and their derivatives
            for i=1:obj.numSegments
                if numel(obj.segmentAcceleration) == obj.numSegments
                    if obj.segmentAcceleration(i) == 0 &&  obj.config.polyDegreeVelSeg <= 2
                        p(i,2) = 0;
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;
                    else 
                        if (obj.segmentAcceleration(i) == 0)
                            degree = obj.config.polyDegreeVelSeg;
                        else
                            degree = obj.config.polyDegree;
                        end
                        
                        % Full polyDegree segment
                        p(i,2) = polynomial(t,degree-1);
                        if mod(degree-1,2) == 0
                            d = (degree-1)/2;
                            [q(i,1), c{i,1}] = polynomial(t, (2*d)-2);
                            [q(i,2), c{i,2}] = polynomial(t, (2*d)-2);
                            F = [F sos(q(i,1)) sos(q(i,2))];
                            F = [F sos(obj.vMax - p(i,2) - t*(dt(i)-t)*q(i,1))];
                            F = [F sos(obj.vMax + p(i,2) - t*(dt(i)-t)*q(i,2))];
                        else
                            d = (degree-2)/2;
                            [q(i,1), c{i,1}] = polynomial(t, 2*d);
                            [q(i,2), c{i,2}] = polynomial(t, 2*d);
                            F = [F sos(q(i,1)) sos(q(i,2))];
                            F = [F sos((obj.vMax - p(i,2) - (dt(i)-t)*q(i,1))/t)];
                            F = [F sos((obj.vMax + p(i,2) - (dt(i)-t)*q(i,2))/t)];
                        end
                        obj.segmentType(i) = segmentTypeEnum.sosConstrained;
                    end
                else
                    % Trapezoidal optimisation not performed, all
                    % segments are full polyDegree
                    degree = obj.config.polyDegree;
                    p(i,2) = polynomial(t,degree-1);
                    if mod(degree-1,2) == 0
                        d = (degree-1)/2;
                        [q(i,1), c{i,1}] = polynomial(t, (2*d)-2);
                        [q(i,2), c{i,2}] = polynomial(t, (2*d)-2);
                        F = [F sos(q(i,1)) sos(q(i,2))];
                        F = [F sos(obj.vMax - p(i,2) - t*(dt(i)-t)*q(i,1))];
                        F = [F sos(obj.vMax + p(i,2) - t*(dt(i)-t)*q(i,2))];
                    else
                        d = (degree-2)/2;
                        [q(i,1), c{i,1}] = polynomial(t, 2*d);
                        [q(i,2), c{i,2}] = polynomial(t, 2*d);
                        F = [F sos(q(i,1)) sos(q(i,2))];
                        F = [F sos((obj.vMax - p(i,2) - (dt(i)-t)*q(i,1))/t)];
                        F = [F sos((obj.vMax + p(i,2) - (dt(i)-t)*q(i,2))/t)];
                    end
                    obj.segmentType(i) = segmentTypeEnum.sosConstrained;
                end

                % Generate higher derivatives
                for j=3:max([obj.config.conDerivDeg, 6])
                    p(i,j) = jacobian(p(i,j-1),t);
                end
                
                % and lower derivatives
                p(i,1) = int(p(i,2),t) + sdpvar;
            end

            % Cost function
            for i=1:obj.numSegments
                J(i) = int(p(i,obj.config.derivToMin+1)^2,t,0,dt(i));
            end
            J = sum(J);

            % Define segment initial constraints if the waypoint defines position
            for i=1:obj.numSegments
                if ismember(1, obj.getDerivativesDefinedByType(obj.waypoints(i).type))
                    F = [F (replace(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0) == obj.waypoints(i).val'):['Position constraint waypoint ' num2str(i) ' of type ' char(obj.waypoints(i).type)]];
                end
            end

            % Define final segment terminal constraint
            F = [F (replace(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end)) == obj.waypoints(end).val'):['Position constraint waypoint ' num2str(obj.numWaypoints) ' of type ' char(obj.waypoints(end).type)]];

            % Define intermediary equivalence constraints
            for i=1:obj.numSegments-1
                F = [F (replace(p(i,1:(obj.config.conDerivDeg+1)),t,dt(i)) == replace(p(i+1,1:(obj.config.conDerivDeg+1)),t,0)):['Derivative equivalence segment ' num2str(i) ' to ' num2str(i+1)]];
            end

            opt = sdpsettings;
            opt.cachesolvers = 1;
            opt.removeequalities = 0; % 0 appears far quicker!
            % SSOS, DSOS, SDSOS options from https://github.com/yalmip/YALMIP/issues/505
            % 2=Image model, 4=reduced nonlinear(SSOS?), 5=DSOS,6=SDSOS
            opt.sos.model = 0;
%             opt.solver = 'mosek';
%             opt.mosek.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1e-6; % 1e-8 default
%             opt.mosek.MSK_DPAR_INTPNT_CO_TOL_DFEAS = 1e-6; % 1e-8 default
%             opt.mosek.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = 1e-5; % 1e-7 default
            opt.verbose = verbosity; % Massively slows mosek if on
            opt.showprogress = verbosity>0;
            opt.cachesolvers = 0;

            % Perform optimization
            if ~isempty(c)
                diag = optimize(F,J,opt,vertcat(c{:}));
            else
                diag = optimize(F,J,opt);
            end

            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.setPolyCoefs(i, flipud([value(coefficients(p(i,1),t)); zeros(obj.config.polyDegree+1-numel(coefficients(p(i,1),t)),1)]));
            end

            % Get final cost
            J = value(J);

            if diag.problem == 1
                % Infeasible problem
                J = inf;
                if verbosity
                    disp('Solver reported infeasible problem')
                end
            end


            t_derive = toc;

            if verbosity>0
                diag
                disp(['Polynomial coefficients optimised in ' num2str(diag.solvertime) ' seconds.']);
                disp(['Derivation & solution completed in ' num2str(t_derive) ' seconds']);
            end

            % Set optimised flag
            obj.optimisedByMethod = optimisationTypeEnum.SOS;

            % Set outputs
            out.J = J;
            out.vMax = [];
            out.solveTime = diag.solvertime;
            for i = 2:3:obj.numSegments
                p = obj.getPolyCoefs(i);
                out.vMax = abs([out.vMax; p(end-1)]);
            end

            % Store parameters and results for reuse
            obj.prevOut = out;
        end
        
        function out = optimiseFlatOutputYALMIPQPRecursiveVelocityInequalities(obj, verbosity, durations)
            % Defines and optimises problem using YALMIP. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            % The time indices of velocity maximums are found by examining
            % the roots of the acceleration polynomials. Velocity
            % inequalities are then recursively inserted at these time
            % indices until the all peak velocities are within the
            % constraint tolerance.
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations);
                end
            end 
            
            % Shortcut if optimisation parameters haven't changed and we've
            % already optimised
            forceRegen = false;
            if (obj.optimisedByMethod == optimisationTypeEnum.recursive_vel_ineqs_YALMIP) && ~forceRegen
                disp('Reusing existing solution');
                out = obj.prevOut;
                return
            end
            tic;

            % Prevents accumulation of junk in memory, giving a massive performance boost in gradient descent
            yalmip('clear');

            % Define independent time variable
            sdpvar t;

            p = sdpvar(obj.numSegments, max([obj.config.conDerivDeg, 6]));

            % Define durations variable
            dt = durations;

            % Define polynomials and their derivatives
            for i=1:obj.numSegments
                if numel(obj.segmentAcceleration) == obj.numSegments
                    if obj.segmentAcceleration(i) == 0
                        % Constant velocity segment
                        p(i,1) = polynomial(t,obj.config.polyDegreeVelSeg);
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;
                    else
                        % Full polyDegree acceleration segment
                        p(i,1) = polynomial(t,obj.config.polyDegree);
                        obj.segmentType(i) = segmentTypeEnum.free;                        
                    end
                else
                    % Trapezoidal optimisation not performed, all
                    % segments are full polyDegree
                    p(i,1) = polynomial(t,obj.config.polyDegree);
                    obj.segmentType(i) = segmentTypeEnum.free;    
                end

                for j=2:max([obj.config.conDerivDeg, 6])
                    p(i,j) = jacobian(p(i,j-1),t);
                end
            end

            % Cost function
            for i=1:obj.numSegments
                J(i) = int(p(i,obj.config.derivToMin+1)^2,t,0,dt(i));
            end
            J = sum(J)/1e6;

            % Define segment initial constraints if the waypoint defines position
            F = [];
            for i=1:obj.numSegments
                if ismember(1, obj.getDerivativesDefinedByType(obj.waypoints(i).type))
                    F = [F (replace(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0) == obj.waypoints(i).val'):['Position constraint waypoint ' num2str(i) ' of type ' char(obj.waypoints(i).type)]];
                end
            end

            % Define final segment terminal constraint
            F = [F (replace(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end)) == obj.waypoints(end).val'):['Position constraint waypoint ' num2str(obj.numWaypoints) ' of type ' char(obj.waypoints(end).type)]];

            % Define intermediary equivalence constraints
            for i=1:obj.numSegments-1
                F = [F (replace(p(i,1:obj.config.conDerivDeg),t,dt(i)) == replace(p(i+1,1:obj.config.conDerivDeg),t,0)):['Derivative equivalence segment ' num2str(i) ' to ' num2str(i+1)]];
            end

            useMosekQuadprog = 0;
            if ~useMosekQuadprog
                % Remove MOSEK quadprog from path
                rmpath('D:\Program Files\Mosek\8\toolbox\r2014a\');
            end

            opt = sdpsettings;
            opt.removeequalities = 0;
            opt.verbose = verbosity;
            opt.showprogress = verbosity>0;
            opt.cachesolvers = 0;
            opt.solver = 'quadprog';


            for n=1:1e3

%                     % Warm start if possible - not supported (or recommended) with MOSEK
%                     if n>1
%                         assign(coefficients(p,t), value(coefficients(p,t)));
%                         opt.usex0 = 1;
%                     end

                % Perform optimization
                diag = optimize(F,J,opt);
                tExec(n) = diag.solvertime;

                % Set constraints satisfied flag
                constraintsSatisfied = true;

                % Find real roots of polynomial segments, and insert
                % velocity inequalities there, if this is at a
                % violation.
                for i=1:obj.numSegments
                    if obj.config.polyDegreeVelSeg <= 2
                        if obj.segmentType == segmentTypeEnum.constantVelocity
                            continue;
                        end
                    end

                    % Find all roots
                    coefs = flipud(value(coefficients(p(i,3),t)));
                    tic; 
                    accelRoots = roots(coefs);
                    tExec(n) = tExec(n) + toc;

                    % Keep only real within t=[0,dt]
                    accelRoots(imag(accelRoots)~=0) = [];
                    accelRoots(accelRoots<0) = [];
                    accelRoots(accelRoots>dt(i)) = [];
                    accelRoots = unique(accelRoots);

                    % Velocity constraint tolerance
                    velConTol = 1e-2;
%                         velConTol = 0;

                    for j=1:numel(accelRoots)
                        % Insert inequalities at these times if velocity
                        % constraint is violated
                        if value(replace(p(i,2), t, accelRoots(j))) > obj.vMax + velConTol
                            F = [F replace(p(i,2), t, accelRoots(j)) <= obj.vMax];
                            constraintsSatisfied = false;
                        elseif value(replace(p(i,2), t, accelRoots(j))) < -obj.vMax - velConTol
                            F = [F -obj.vMax <= replace(p(i,2), t, accelRoots(j))];
                            constraintsSatisfied = false;
                        end
                    end
                end

                if constraintsSatisfied
                    break;
                end
            end

            % Check for silly solution and run again without removing
            % equalities if found
            if any(isnan(value(coefficients(p(:,1),t))))
                if verbosity>0
                    warning('Optimizing with constraint elmination yielded NaN, running again without eliminating constraints');
                end
                opt.removeequalities = 0;
                diag = optimize(F,J,opt);
            end


            if ~useMosekQuadprog
                % Return MOSEK to path
                addpath('D:\Program Files\Mosek\8\toolbox\r2014a\');
            end

            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.setPolyCoefs(i, flipud([value(coefficients(p(i,1),t)); zeros(obj.config.polyDegree+1-numel(coefficients(p(i,1),t)),1)]));
            end

            % Get final cost
            J = value(J);

            if diag.problem == 1
                % Infeasible problem
                J = inf;
            end


            t_derive = toc;

            if verbosity>0
                disp(['Polynomial coefficients optimised in ' num2str(sum(tExec)) ' seconds.']);
                disp(['Derivation & solution completed in ' num2str(t_derive) ' seconds']);
            end

            % Set optimised flag
            obj.optimisedByMethod = optimisationTypeEnum.recursive_vel_ineqs_YALMIP;

            % Set outputs
            out.J = J;
            out.vMax = [];
            out.solveTime = sum(tExec);
            for i = 2:3:obj.numSegments
                p = obj.getPolyCoefs(i);
                out.vMax = abs([out.vMax; p(end-1)]);
            end

            % Store parameters and results for reuse
            obj.prevOut = out;
        end
        
        function out = optimiseFlatOutputFastQPRecursiveVelocityInequalities(obj, verbosity, durations)
            % Defines and optimises problem using quadprog, successively
            % adding velocity inequalities until constraint satisfaction is
            % achieved. Problem is precompiled for a given set of
            % waypoints and polynomial polyDegree, with durations as parameters
            % for quick evaluation.
            % This cannot be (quickly) performed in YALMIP due to changing
            % constraint matrices.
                   
            forceSolutionRegen = false;
            forceCodeRegen = false;
            
            % Velocity constraint tolerance
%             velConTol = 5e-2;
            velConTol = 0;
            
            if ~exist('verbosity', 'var')
                verbosity=0;
            end
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations);
                end
            end                 
            
            % Shortcut if optimisation parameters haven't changed and we've
            % already optimised
            if (obj.optimisedByMethod == optimisationTypeEnum.recursive_vel_ineqs_fast) && ~forceSolutionRegen
                if verbosity
                    disp('Reusing existing solution');
                end
                            
                out = obj.prevOut;    
                out.solveTime = 0;
                return
            end           
            if ~isprop(obj,'precompiled') ...
                || ~isequal(obj.precompiled.waypointTypes, vertcat(obj.waypoints(:).type)) ...
                || ~isequal(obj.precompiled.config, obj.config) ...
                || forceCodeRegen
                % Define time variable
                syms t real;
                dt = sym('dt', [1 numel(durations)], 'Real');
                assumeAlso(dt>0);

                % Define polynomials and their derivatives, plus waypoint
                % value variables
                for i=1:obj.numSegments
                    % Define polycoefs
                    if obj.waypoints(i).type ~= waypointTypeEnum.velocityConstraint || ...
                            obj.waypoints(i+1).type ~= waypointTypeEnum.velocityConstraint
                        % Full polyDegree polynomial segment
                        pCoefs{i} = sym(['polyCoefs_' num2str(i) '_'], [obj.config.polyDegree+1 1], 'real');
                        obj.segmentType(i) = segmentTypeEnum.free;  
                    else
                        % Constant velocity segment
                        pCoefs{i} = sym(['polyCoefs_' num2str(i) '_'], [obj.config.polyDegreeVelSeg+1 1], 'real');
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;  
                    end

                    p(i,1) = poly2sym(pCoefs{i},t);

                    for j=2:max([obj.config.conDerivDeg, obj.config.derivToMin, 6])
                        p(i,j) = diff(p(i,1),t,j-1);
                    end
                end

                % Define waypoint value variables
                for i=1:obj.numWaypoints
                    val{i} = sym(['val' num2str(i) '_'], [numel(obj.getDerivativesDefinedByType(obj.waypoints(i).type)), 1]);
                end

                % Cost function
                for i=1:obj.numSegments
                    J(i) = int(p(i,obj.config.derivToMin+1)^2,t,0,dt(i));
                end
                J = sum(J) / 1e6;

                %% Build parameterised equality constraint vector.
                Feq = []; % Constraints in form Feq(x)=0

                % Define segment initial constraints
                for i=1:obj.numSegments
                    if obj.waypoints(i).type ~= waypointTypeEnum.velocityConstraint
                        Feq = [Feq; subs(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0)' - val{i}];
                    end
                end

                % Define final segment terminal constraint
                Feq = [Feq; subs(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end))' - val{end}];

                % Define intermediary equivalence constraints
                for i=1:obj.numSegments-1
                    Feq = [Feq; subs(p(i,1:obj.config.conDerivDeg+1),t,dt(i))' - subs(p(i+1,1:obj.config.conDerivDeg+1),t,0)'];
                end

                % Create optimisation matrices
                x = vertcat(pCoefs{:});
                Aeq = jacobian(Feq,x);
                beq = -simplify(Feq - Aeq*x);
                H = hessian(J,x);

                obj.precompiled.waypointTypes = vertcat(obj.waypoints(:).type);   
                obj.precompiled.config = obj.config;
                obj.precompiled.Aeq = matlabFunction(Aeq, 'Vars', {dt}, 'Sparse',true);
                obj.precompiled.beq = matlabFunction(beq, 'Vars', {vertcat(val{:})},'Sparse',true);
                obj.precompiled.H = matlabFunction(H, 'Vars', {dt},'Sparse',true);
                obj.precompiled.segmentType = obj.segmentType;

                for i=1:obj.numSegments
                    obj.precompiled.polyCoefsIndices{i} = 1:numel(pCoefs{i});
                end

                for i=2:obj.numSegments
                    obj.precompiled.polyCoefsIndices{i} = obj.precompiled.polyCoefsIndices{i} + obj.precompiled.polyCoefsIndices{i-1}(end);
                end
            end

        %% Optimisation
        start = tic; 
        % Calculate optimisation variables for given durations
        Aeq = obj.precompiled.Aeq(durations);
        beq = obj.precompiled.beq(vertcat(obj.waypoints(:).val));
        H = obj.precompiled.H(durations);
        obj.segmentType = obj.precompiled.segmentType;

        % PERFORMANCE STATS
        % mosek w/ multithreading 32 runs - 8.8051s per iteration
        % quadprog 32 runs - 9.7s per iteration
        % mosek without multithreading 32 runs - 7.1s per iteration

        if exist('mskoptimset', 'file') <= 0
            opt = optimoptions('quadprog');
        else
            opt = mskoptimset;
%             opt = mskoptimset('MSK_DPAR_INTPNT_QO_TOL_DFEAS', 1e-10); % MOSEK STALL error for 1e-12 or below
%             opt = mskoptimset(opt, 'MSK_IPAR_INTPNT_MULTI_THREAD', 0); % In a 32 run parallel test multithreading managed 8.8s per run, without multithreading got 7.1s per iteration.
        end
        if verbosity == 0
            opt.Diagnostics = 'off';
            opt.Display = 'off';
        else
            opt.Display = 'iter';
        end

        A = []; b = [];

        J = inf; worstVMaxViolation = inf*ones(obj.numSegments,1); 
        numIter = 100;
        for n=1:numIter

            % Perform optimization
            [x,Jnew,exitFlag] = quadprog(H,zeros(1,size(H,1)),A,b,Aeq,beq,[],[],[],opt); % Timed and found warm starting to be slower

            % Package polynomial coefficients
            tempPolyCoefs = zeros(obj.config.polyDegree+1,obj.numSegments);
            for i=1:obj.numSegments
                tempPolyCoefs(:,i) = [zeros(obj.config.polyDegree+1-numel(obj.precompiled.polyCoefsIndices{i}),1); x(obj.precompiled.polyCoefsIndices{i})];
            end

            if exitFlag > 0

                J = Jnew;

                % Reset constraints satisfied flag
                constraintsSatisfied = true;                    

                % Find velocity violations at segment boundaries and
                % constrain
                for i=1:obj.numSegments
                    
                    worstVMaxViolation(i) = 0;
                    
                    if polyval(polyder(tempPolyCoefs(:,i)),durations(i)) > obj.vMax + velConTol
                        AnewRow = zeros(1,size(H,1));
                        AnewRow(1,obj.precompiled.polyCoefsIndices{i}) = [durations(i).^((numel(obj.precompiled.polyCoefsIndices{i})-2):-1:0) .* polyder(ones(1,numel(obj.precompiled.polyCoefsIndices{i}))) 0];
                        A = [A; AnewRow];
                        b = [b; obj.vMax];
                        constraintsSatisfied = false;
                        worstVMaxViolation(i) = max([worstVMaxViolation(i), abs(polyval(polyder(tempPolyCoefs(:,i)),durations(i)))-obj.vMax-velConTol]);
                    elseif polyval(polyder(tempPolyCoefs(:,i)),durations(i)) < -obj.vMax - velConTol
                        AnewRow = zeros(1,size(H,1));
                        AnewRow(1,obj.precompiled.polyCoefsIndices{i}) = -[durations(i).^((numel(obj.precompiled.polyCoefsIndices{i})-2):-1:0) .* polyder(ones(1,numel(obj.precompiled.polyCoefsIndices{i}))) 0];
                        A = [A; AnewRow];
                        b = [b; obj.vMax];
                        constraintsSatisfied = false;
                        worstVMaxViolation(i) = max([worstVMaxViolation(i), abs(polyval(polyder(tempPolyCoefs(:,i)),durations(i)))-obj.vMax-velConTol]);
                    end
                end

                % Find real roots of polynomial segments, and insert
                % velocity inequalities there if this is at a
                % violation.
                for i=1:obj.numSegments

                    % Find all roots of acceleration polynomials
                    accelRoots = roots(polyder(polyder(tempPolyCoefs(:,i))));

                    % Keep only real within t=[0,dt]
                    accelRoots(imag(accelRoots)~=0) = [];
                    accelRoots(accelRoots<0) = [];
                    accelRoots(accelRoots>durations(i)) = [];
                    accelRoots = unique(accelRoots);

                    for j=1:numel(accelRoots)
                        % Insert inequalities at these times if velocity
                        % constraint is violated
                        if polyval(polyder(tempPolyCoefs(:,i)),accelRoots(j)) > obj.vMax + velConTol
                            AnewRow = zeros(1,numel(x));
                            AnewRow(1,obj.precompiled.polyCoefsIndices{i}) = [accelRoots(j).^((numel(obj.precompiled.polyCoefsIndices{i})-2):-1:0) .* polyder(ones(1,numel(obj.precompiled.polyCoefsIndices{i}))) 0];
                            A = [A; AnewRow];
                            b = [b; obj.vMax];
                            constraintsSatisfied = false;
                            worstVMaxViolation(i) = max([worstVMaxViolation(i), abs(polyval(polyder(tempPolyCoefs(:,i)),accelRoots(j)))-obj.vMax-velConTol]);
                        elseif polyval(polyder(tempPolyCoefs(:,i)),accelRoots(j)) < -obj.vMax - velConTol
                            AnewRow = zeros(1,numel(x));
                            AnewRow(1,obj.precompiled.polyCoefsIndices{i}) = -[accelRoots(j).^((numel(obj.precompiled.polyCoefsIndices{i})-2):-1:0) .* polyder(ones(1,numel(obj.precompiled.polyCoefsIndices{i}))) 0];
                            A = [A; AnewRow];
                            b = [b; obj.vMax];
                            constraintsSatisfied = false;
                            worstVMaxViolation(i) = max([worstVMaxViolation(i), abs(polyval(polyder(tempPolyCoefs(:,i)),accelRoots(j)))-obj.vMax-velConTol]);
                        end
                    end
                end % End of loop through all velocity violations
            else % exitFlag<=0
                if verbosity > 0
                    warning('Bad exit flag');
                end
                J = inf;
                break;
            end

            if constraintsSatisfied
                if verbosity > 0
                    disp(['Num iterations = ' num2str(n)]);
                end
                break;
            elseif ~constraintsSatisfied && n==numIter
                if verbosity > 0
                    warning('Failed to iteratively constrain solution');
                end
            end
        end % End of constraint iterations

        t_exec = toc(start);

        if verbosity>0
            disp(['Polynomial coefficients optimised in ' num2str(t_exec) ' seconds for durations ' num2str(durations)]);
        end

        if verbosity>0
            if J == inf || any(worstVMaxViolation == inf)                
                warning('Infeasible unconstrained problem');
            end
        end

        % Set optimised flag
        obj.optimisedByMethod = optimisationTypeEnum.recursive_vel_ineqs_fast;

        % Set outputs
        out.J = J;
        out.vMax = worstVMaxViolation;
        out.solveTime = t_exec;
        out.durations = durations;
        out.polyCoefs = tempPolyCoefs;

        % Write polynomial coefficients to object
        for i=1:obj.numSegments
            obj.setPolyCoefs(i,tempPolyCoefs(:,i));
        end

        % Store parameters and results for reuse
        obj.prevOut = out;

        end
        
        function out = optimiseFlatOutputYALMIPQPGriddingVelocityInequalities(obj, verbosity, durations)
            % Defines and optimises problem using YALMIP. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            % Velocity inequalities are enforced at regular intervals on
            % all segments.
            
            if ~exist('durations', 'var')
                durations = obj.getDurationsByIndex;
            else
                if isempty(durations)
                    durations = obj.getDurationsByIndex;
                else
                    obj.setDurationsByIndex(durations);
                end
            end 
            
            % Shortcut if optimisation parameters haven't changed and we've
            % already optimised
            if (obj.optimisedByMethod == optimisationTypeEnum.gridded_vel_ineqs_YALMIP) && ~forceRegen
                if verbosity
                    disp('Reusing existing solution');
                end
                out = obj.prevOut;
                return
            end
                
            tic;

            % Prevents accumulation of junk in memory, giving a massive performance boost in gradient descent
            yalmip('clear');

            % Define independent time variable
            sdpvar t;

            p = sdpvar(obj.numSegments, max([obj.config.conDerivDeg, 6]));

            % Define durations variable
            dt = durations;

            % Define polynomials and their derivatives
            for i=1:obj.numSegments
                if numel(obj.segmentAcceleration) == obj.numSegments
                    if obj.segmentAcceleration(i) == 0
                        % Constant velocity segment
                        p(i,1) = polynomial(t,1);
                        obj.segmentType(i) = segmentTypeEnum.constantVelocity;
                    else
                        % Full polyDegree acceleration segment
                        p(i,1) = polynomial(t,obj.config.polyDegree);
                        obj.segmentType(i) = segmentTypeEnum.free;                        
                    end
                else
                    % Trapezoidal optimisation not performed, all
                    % segments are full polyDegree
                    p(i,1) = polynomial(t,obj.config.polyDegree);
                    obj.segmentType(i) = segmentTypeEnum.free;    
                end

                for j=2:max([obj.config.conDerivDeg, 6])
                    p(i,j) = jacobian(p(i,j-1),t);
                end
            end

            % Cost function
            for i=1:obj.numSegments
                J(i) = int(p(i,6)^2,t,0,dt(i));
%                     J(i) = J(i) + 1e5*int(p(i,2)^2,t,0,dt(i)); % Velocity cost
            end
            J = sum(J)/1e6;

            % Define segment initial constraints if the waypoint defines position
            F = [];
            for i=1:obj.numSegments
                if ismember(1, obj.getDerivativesDefinedByType(obj.waypoints(i).type))
                    F = [F (replace(p(i,obj.getDerivativesDefinedByType(obj.waypoints(i).type)),t,0) == obj.waypoints(i).val'):['Position constraint waypoint ' num2str(i) ' of type ' char(obj.waypoints(i).type)]];
                end
            end

            % Define final segment terminal constraint
            F = [F (replace(p(end,obj.getDerivativesDefinedByType(obj.waypoints(end).type)),t,dt(end)) == obj.waypoints(end).val'):['Position constraint waypoint ' num2str(obj.numWaypoints) ' of type ' char(obj.waypoints(end).type)]];

            % Define intermediary equivalence constraints
            for i=1:obj.numSegments-1
                F = [F (replace(p(i,1:obj.config.conDerivDeg),t,dt(i)) == replace(p(i+1,1:obj.config.conDerivDeg),t,0)):['Derivative equivalence segment ' num2str(i) ' to ' num2str(i+1)]];
            end

            % Define velocity constraint inequalities
            nGrid = 10;
            for i=1:obj.numSegments
                ts = 0:dt(i)/(nGrid-1):dt(i);
                for k=1:numel(ts)
                    F = [F -obj.vMax <= replace(p(i,2),t,ts(k)) <= obj.vMax];
                end
            end

            opt = sdpsettings;
            opt.removeequalities = 0;
            opt.verbose = verbosity;
            opt.showprogress = verbosity>0;
            opt.cachesolvers = 1;
            opt.quadprog.MaxIter = 1e6;

            % Perform optimization
            diag = optimize(F,J,opt);
            tExec = diag.solvertime;


            % Check for silly solution and run again without removing
            % equalities if found
            if any(isnan(value(coefficients(p(:,1),t))))
                if verbosity>0
                    warning('Optimizing with constraint elmination yielded NaN, running again without eliminating constraints');
                end
                opt.removeequalities = 0;
                diag = optimize(F,J,opt);
            end


            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.setPolyCoefs(i, flipud([value(coefficients(p(i,1),t)); zeros(obj.config.polyDegree+1-numel(coefficients(p(i,1),t)),1)]));
            end

            % Get final cost
            J = value(J);

            if diag.problem == 1
                % Infeasible problem
                J = inf;
            end


            t_derive = toc;

            if verbosity>0
                disp(['Polynomial coefficients optimised in ' num2str(sum(tExec)) ' seconds.']);
                disp(['Derivation & solution completed in ' num2str(t_derive) ' seconds']);
            end

            % Set optimised flag
            obj.optimisedByMethod = optimisationTypeEnum.gridded_vel_ineqs_YALMIP;

            % Set outputs
            out.J = J;
            out.vMax = [];
            for i = 2:3:obj.numSegments
                p = obj.getPolyCoefs(i);
                out.vMax = abs([out.vMax; p(end-1)]);
            end
            out.solveTime = tExec;

            % Store parameters and results for reuse
            obj.prevOut = out;
        end
         
        %% Utility functions
        
        function SDerivatives = getSDerivatives(obj, t)
            % GETFLATDERIVATIVES Returns the value of the first
            % obj.config.conDerivDeg+1 of the flat output defined by polyCoefs.
            
            if obj.optimisedByMethod == optimisationTypeEnum.none
                error('Polynomial coefficients must be optimised');
            end
            
            if isempty(obj.SDerivativesFun)
                pCoefs = sym('polyCoefs_', [obj.polyDegree+1 1], 'Real');
                syms T real;

                p = poly2sym(pCoefs,T);

                % Derivatives of polynomial
                SDerivatives = [];
                for i=0:obj.polyDegree
                    SDerivatives = [SDerivatives; diff(p,T,i)];
                end
        
                obj.SDerivativesFun = matlabFunction(SDerivatives, 'Vars', {T pCoefs});
            end
            
            if ~isscalar(t)
                error('Expected t to be a scalar');
            end
            
            if t<0 || t>(obj.waypoints(end).t + 1e-10)
                error('Invalid time index');
            end
            
            % Find segment index idx for given t
            for idx = 1:obj.numSegments
                if t>=obj.waypoints(idx).t && t<obj.waypoints(idx+1).t
                    break;
                end
            end
            
            % t relative to start of the section t lies within
            trel = t-obj.waypoints(idx).t;
            
            SDerivatives = obj.SDerivativesFun(trel, obj.polyCoefs(:,idx));
        end
              
        function position = getPosition(obj, t)
            % GETPOSITION Returns the position of the flat output at times
            % t[]
            position = [];
            for i=1:numel(t)
                SDerivatives = obj.getSDerivatives(t(i));
                position(i) = SDerivatives(1);
            end
        end
        
        function derivatives = getDerivativesDefinedByType(obj, type)
            %  GETINDICESDEFINEDBYWAYPOINTS Returns the indices of 
            % SDerivatives defined by waypoints of type type
            
            switch type
                case waypointTypeEnum.position
                    derivatives = 1;
                case waypointTypeEnum.velocity
                    derivatives = 2;
                case waypointTypeEnum.acceleration
                    derivatives = 3;
                case waypointTypeEnum.velocityConstraint
                    derivatives = [];%3:obj.config.conDerivDeg;
                case waypointTypeEnum.velocityConstraintPlusPosition
                    derivatives = [1 3:obj.config.conDerivDeg+1];
                case waypointTypeEnum.boundary
                    derivatives = 1:obj.config.conDerivDeg+1;
                case waypointTypeEnum.velocityBoundary
                    derivatives = 2:obj.config.conDerivDeg+1;      
                case waypointTypeEnum.unconstrained
                    derivatives = [];
                otherwise
                    error('Unhandled waypoint type');                    
            end
        end
        
        function addWaypoint(obj, val, t, type)
            % ADDWAYPOINT Adds a single waypoint to obj.waypoints
                        
            if ~isa(type, 'waypointTypeEnum')
                % Convert char to enum
                type = waypointTypeEnum(type);
            end
            
            % Check first waypoint requirements
            if obj.numWaypoints == 0
                if t ~= 0
                    error('First waypoint time index must be zero');
                elseif type ~= waypointTypeEnum.boundary
                    error('First waypoint must be of the boundary type');
                end
            end
            
            % Check for duplicate waypoints - technically only needs to
            % check if not a velocity waypoint
            if any(ismember(obj.getTimeIndicesByIndex, t))
                % warning('A waypoint already exists at this time index');
            end
                        
            if  numel(val) > numel(obj.getDerivativesDefinedByType(type))
                error('Too many elements specified for waypoint of this type');
            end
            
            % Pad val to correct size
            val = [val zeros(1, numel(obj.getDerivativesDefinedByType(type)) - numel(val))];

            idx = obj.numWaypoints+1;
            obj.waypoints(idx).val = val(:);
            obj.waypoints(idx).t = t;
            obj.waypoints(idx).type = type;
            
            % Sort waypoints by time index
            obj.waypoints = sortStruct(obj.waypoints, 't');
            
            % Clear optimised flag
            obj.optimisedByMethod = 'none';
        end
        
        function removeWaypointByTimeIndex(obj, t)
            % @TODO
        end
        
        function removeWaypointsByType(obj, type)
            % removeWaypointsByType Removes all waypoints of type type.
            toRemove = [];
            for i=1:obj.numWaypoints
                if obj.waypoints(i).type == waypointTypeEnum(type)
                    toRemove(end+1) = i;
                end
            end
            
            obj.waypoints(toRemove) = [];
            
            % Clear optimised flag
            obj.optimisedByMethod = 'none';
        end
        
        function trimWaypoints(obj, verbosity)
            dtSmall = 1e-2;
            numWaypointsInitial = obj.numWaypoints;
            
            if ~exist('verbosity', 'var')
                verbosity=0;
            end
            
            % Find any velocityConstraint -> velocityConstraint
            % segments of 0 duration and replace them with unconstrained 
            % waypoints.
            dt = [];
            while(numel(dt) ~= obj.numSegments)
                dt = obj.getDurationsByIndex;
                for i=1:obj.numSegments
                    if dt(i) < dtSmall
                        if obj.waypoints(i).type == waypointTypeEnum.velocityConstraint ...
                                && obj.waypoints(i+1).type == waypointTypeEnum.velocityConstraint
                            
                            obj.waypoints(i).t = mean([obj.waypoints(i).t obj.waypoints(i+1).t]);
                            obj.waypoints(i).type = waypointTypeEnum.unconstrained;
                            obj.waypoints(i).val = [];
                            
                            % Delete remaining velocityConstraint waypoint
                            obj.waypoints(i+1) = [];
                            obj.segmentType(i) = [];
                            obj.segmentAcceleration(i) = [];
                            obj.segmentInitialVelocity(i) = [];
                            obj.polyCoefs(:,i) = [];
                            break;
                        end
                    end
                end  
            end
            
            % Find any unconstrained -> position or position ->
            % unconstrained segments of 0 duration and remove them
            % and the unconstrained waypoint
            dt = [];
            while(numel(dt) ~= obj.numSegments)
                dt = obj.getDurationsByIndex;
                for i=1:obj.numSegments
                    if dt(i) < dtSmall
                        if (obj.waypoints(i).type == waypointTypeEnum.unconstrained ...
                                && obj.waypoints(i+1).type == waypointTypeEnum.position)
                            
                            % Delete segment and unconstrained waypoint
                            obj.waypoints(i) = [];
                            obj.segmentType(i) = [];
                            obj.segmentAcceleration(i) = [];
                            obj.segmentInitialVelocity(i) = [];
                            obj.polyCoefs(:,i) = [];
                            break;
                        elseif (obj.waypoints(i).type == waypointTypeEnum.position ...
                                && obj.waypoints(i+1).type == waypointTypeEnum.unconstrained)
                            
                            % Delete segment and unconstrained waypoint
                            obj.waypoints(i+1) = [];
                            obj.segmentAcceleration(i) = [];
                            obj.segmentInitialVelocity(i) = [];
                            obj.segmentType(i) = [];
                            obj.polyCoefs(:,i) = [];
                            break;
                        end
                    end
                end  
            end
            
            if verbosity > 0
                disp(['Trimmed ' num2str(numWaypointsInitial) ' waypoints to ' num2str(obj.numWaypoints)]);
            end
        end
              
        function recalculateTrapzoidalPolyCoefs(obj)
            
            dt = obj.getDurationsByIndex;
            for i=1:obj.numSegments-1
                % p0 and p1 are fixed by intial conditions - we only need
                % to recalculate p2
                dx = obj.polyCoefs(i+1,1) - obj.polyCoefs(i,1);
                obj.polyCoefs(i,3) = 0.5*(dx - obj.polyCoefs(i,2)*dt(i))/dt(i)^2;
            end
            dx = obj.waypoints(end).val(1) - obj.polyCoefs(end,1);
            obj.polyCoefs(end,3) = 0.5*(dx - obj.polyCoefs(end,2)*dt(end))/dt(end)^2;
        end
        
        function numWaypoints = get.numWaypoints(obj)
            % NUMWAYPOINTS Getter to return number of waypoints in
            % obj.waypoints
            numWaypoints = numel(obj.waypoints);
        end
        
        function numSegments = get.numSegments(obj)
            % NUMWAYPOINTS Getter to return number of waypoints in
            % obj.waypoints
            numSegments = numel(obj.waypoints)-1;
        end     
        
        function tend = get.tend(obj)
            % getter for tend
            tend = obj.waypoints(end).t;
        end   
        
        function polyDegree = get.polyDegree(obj)
            polyDegree = obj.config.polyDegree;
        end
        
        function duration = getDurationsByIndex(obj, idx)
            % GETDURATION Returns the duration of the segments specified in
            % idx. If idx is unspecified all durations are returned.
            
            if ~exist('idx','var')
                idx = 1:obj.numSegments;
            end
            
            for i=1:numel(idx)                        
                duration(i) = obj.waypoints(idx(i)+1).t - obj.waypoints(idx(i)).t;
            end
        end
        
        function setDurationsByIndex(obj, durations, idxSeg)
            % SETDURATIONS Sets the duration of segments idx[] by shifting all
            % waypoints from idx+1. If idx is unspecified all durations are
            % modified
            
            if ~exist('idxSeg','var')
                idxSeg = 1:obj.numSegments;
            end            
            
            if numel(durations) ~= numel(idxSeg)
                error('Differing numbers of durations and idx');
            end            
            
            % Check durations are positive
            if any(durations < 0)
                error('Cannot set negative segment duration');
            end
            
            % Skip if durations don't change
            if all(abs(durations - obj.getDurationsByIndex(idxSeg)) < 1e-14)
                return;
            end
            
            % Clear optimised property
            obj.optimisedByMethod = 'none';
                        
%             if any(durations == 0)
%                 warning('One or more durations are zero');
%             end
            
            % Check idx is monotonic
            if any(sort(idxSeg) ~= idxSeg)
                error('idx is not monotonic');
            end
            
            % Move through array of segment indexes to modify
            for i=1:numel(idxSeg)
                % How much is this segment changing?
                shift =  durations(i) - obj.getDurationsByIndex(idxSeg(i));
                
                % Waypoint indices to shift
                waypointIndicesToShift = idxSeg(i)+1:obj.numWaypoints;
                
                % Get current time indices of these waypoints
                currentTimeIndices = obj.getTimeIndicesByIndex(waypointIndicesToShift);
                
                % Add shift to all future waypoints
                obj.setTimeIndicesByIndex(waypointIndicesToShift, currentTimeIndices + shift);
            end
            
        end
        
        function durations = getDurationsByType(obj, type)
            % getDurationsByType Returns a list of durations between the
            % waypoints of type type[].
            durations = [];
            for i=1:obj.numWaypoints-1
                if all(ismember(obj.getDerivativesDefinedByType(type), obj.getDerivativesDefinedByType(obj.waypoints(i).type)))
                    for k=i+1:obj.numWaypoints
                        if all(ismember(obj.getDerivativesDefinedByType(type), obj.getDerivativesDefinedByType(obj.waypoints(k).type)))
                            durations = [durations (obj.waypoints(k).t-obj.waypoints(i).t)];
                        end
                    end
                end
            end
        end
        
        function setDurationsByType(obj, type, durations)
            % setDurationsByType Sets the durations of all periods between
            % waypoints of type type[].
                        
            % Get indices of waypoints of this type
            idx = obj.getIndicesByType(type);
            
            if numel(idx) ~= numel(durations)+1
                error('Differing number of segments between waypoints of this type and elements in durations[]');
            end
                        
            obj.setDurationsByIndex(durations, idx);
            
            % Clear optimised flag
            obj.optimisedByMethod = 'none';
        end
        
        function t = getTimeIndicesByType(obj, type)
            % getTimeIndicesByType Returns an ascending list of the time indices of
            % obj.waypoints, optionally filtered by type to return only
            % waypoints that define these derivatves of S.
            t = [];
            if ~exist('type', 'var')
                if ~isempty(obj.waypoints)
                    t = [obj.waypoints(:).t];
                end
            else
                for i=1:obj.numWaypoints
                    if all(ismember(obj.getDerivativesDefinedByType(type), obj.getDerivativesDefinedByType(obj.waypoints(i).type)))
                        t = [t obj.waypoints(i).t];
                    end
                end
            end            
        end
        
        function setTimeIndicesByType(obj, type, t)
            % setTimeIndicesByType Sets the time indices of the waypoints
            % of type type. The number of waypoints of this type must equal
            % the size of t[].
            
            % Get indexes of waypoints of type type in obj.waypoints[]
            idx = obj.getIndicesByType(type);
            
            if numel(idx) ~= numel(t)
                error('Differing numbers of waypoints of this type and elements in t');
            end
            
            % Set time indices
            obj.setTimeIndicesByIndex(idx, t);
            
            % Clear optimised flag
            obj.optimisedByMethod = 'none';
        end
        
        function t = getTimeIndicesByIndex(obj, idx)
            % getTimeIndicesByIndex Returns the time indices of waypoints
            % idx. If idx is unspecified all waypoint time indices are
            % returned.
            
            if ~exist('idx','var')
                idx=1:obj.numWaypoints;
            end
            
            if obj.numWaypoints > 0
                t = [obj.waypoints(idx).t];
            else
                t=[];
            end
        end
        
        function setTimeIndicesByIndex(obj, idx, t)
            % setTimeIndicesByIndex Sets time indices of waypoints idx[] to
            % t[]
            for i=1:numel(idx)
                obj.waypoints(idx(i)).t = t(i);
            end
            
            % Clear optimised flag
            obj.optimisedByMethod = false;
        end
        
        function idx = getIndicesByTime(obj, t)
            % GETINDEXBYTIME Returns the indices of the waypoints in waypoints[]
            % that have time indices t
            for i=1:numel(t)
                match = false;
                for j=1:obj.numWaypoints
                    if obj.waypoints(j).t == t
                        idx(i) = j;
                        match = true;
                        break;
                    end
                end
                if match == false
                    % Error if no match
                    error(['No waypoint found in obj.waypoints with time index ' num2str(t(i))]);
                end
            end            
        end
        
        function idx = getIndicesByType(obj, type, strict)
            % GETINDEXBYTYPE Returns the indices of the waypoints in waypoints[]
            % that have type type. If strict is true an exact match is
            % required, otherwise a match occurs for any type that defines
            % the derivatives given in type.
            idx = [];
            if ~exist('type', 'var')
                error('Type must be provided');
            end
            if ~exist('strict', 'var')
                strict = false;
            end
            
            for i=1:obj.numWaypoints
                if strict                       
                    if type == obj.waypoints(i).type
                        idx = [idx i];
                    end
                else                        
                    if all(ismember(obj.getDerivativesDefinedByType(type), obj.getDerivativesDefinedByType(obj.waypoints(i).type)))
                        idx = [idx i];
                    end
                end
            end        
        end
        
        function values = getValuesByType(obj, type, strict)
            % GETVALUES Returns a list of waypoint values, optionally filtered by type to return only
            % waypoints that define these derivatves of S. If strict is true an exact match is
            % required, otherwise a match occurs for any type that defines the derivatives given in type.
            values = [];
            if ~exist('type', 'var')
                if ~isempty(obj.waypoints)
                    values = {obj.waypoints(:).values};
                end
            else                
                if ~exist('strict', 'var')
                    strict = false;
                end
            
                for i=1:obj.numWaypoints
                    if (strict == false && all(ismember(obj.getDerivativesDefinedByType(type), obj.getDerivativesDefinedByType(obj.waypoints(i).type)))) ...
                            || obj.waypoints(i).type == type
                        wholeWaypoint = zeros(obj.config.conDerivDeg+1,1);
                        wholeWaypoint(obj.getDerivativesDefinedByType(obj.waypoints(i).type)) = obj.waypoints(i).val;
                        values(:,end+1) = wholeWaypoint(obj.getDerivativesDefinedByType(type));
                    end
                end
            end
        end
        
        function p = getPolyCoefs(obj, idx)
            p = obj.polyCoefs(:,idx);
        end
    end
    
    methods (Access = private)
        function setPolyCoefs(obj, idx, p)
            obj.polyCoefs(:,idx) = p;
        end
    end
end

