classdef trajectoryClass < handle
    %TRAJECTORYCLASS Class to contain and manipulate three instances of
    %flatOutputClass, along with using them to define full state
    %trajectories.
    
    properties (Access = private)
        statesUFun
        S0Fun
        vMax
        aMax
        dphiMax
        ddphiMax
    end
    
    properties (Access = public)
        flatOutputs
        config
        tend
        numSegments
        numWaypoints
    end
    
    methods
        
        %% Optimisation functions        
        function obj = trajectoryClass(modelData, config)
            %TRAJECTORYCLASS Construct an instance of this class
            %   Detailed explanation goes here
            for i=1:3
                obj.flatOutputs{i} = flatOutputClass(config(i));
            end
            obj.statesUFun = generateDifferentialFlatnessFunctions(modelData);
            obj.config = config;
            obj.vMax = [];
            obj.aMax = [];
            obj.dphiMax = [];
            obj.ddphiMax = [];
        end
        
        function reinitialise(obj)
            % REINITIALISE Clears the waypoints data structures, but keeps
            % handles to generated functions
            obj.flatOutputs{1}.reinitialise;
            obj.flatOutputs{2}.reinitialise;
            obj.flatOutputs{3}.reinitialise;
        end
        
        function setConstraints(obj, vMax, aMax, dphiMax, ddphiMax)
            obj.vMax = vMax;
            obj.aMax = aMax;
            obj.dphiMax = dphiMax;
            obj.ddphiMax = ddphiMax;
            obj.flatOutputs{1}.setConstraints(vMax,aMax);
            obj.flatOutputs{2}.setConstraints(vMax,aMax);
            obj.flatOutputs{3}.setConstraints(dphiMax,ddphiMax);
        end
        
        function addWaypoint(obj, S1, S2, S3, t, type)
            %ADDWAYPOINT Adds waypoints to flatOutputs{1:3}
            obj.flatOutputs{1}.addWaypoint(S1, t, type);
            obj.flatOutputs{2}.addWaypoint(S2, t, type);
            obj.flatOutputs{3}.addWaypoint(S3, t, type);
        end
        
        function addConstantVelocityWaypoints(obj)
            % Inserts velocity constraint waypoints between position
            % waypoints. All flat outputs must have waypoints at the same
            % time indices.
            % Also updates flatOutputs{i}.segmentAccelerations
            
            % Get position waypoint indices
            t = obj.flatOutputs{1}.getTimeIndicesByIndex;
            
            % Check this is the same as the other two flat outputs
            if ~isequal(t, obj.flatOutputs{2}.getTimeIndicesByIndex) || ~isequal(t, obj.flatOutputs{3}.getTimeIndicesByIndex)
                error('Flat outputs must share the same waypoint time indices');
            end
            
            % Loop through position waypoints inserting constant velocity waypoints
            for i=1:numel(t)-1
                obj.addWaypoint([],[],[],mean(t(i:i+1)),waypointTypeEnum.velocityConstraint);
                obj.addWaypoint([],[],[],mean(t(i:i+1)),waypointTypeEnum.velocityConstraint);
            end
                        
            % Update flatOutputs{i}.segmentAcceleration
            for i=1:3
                for k=2:3:obj.flatOutputs{i}.numSegments
                    if obj.flatOutputs{i}.waypoints(k-1).val(1) < obj.flatOutputs{i}.waypoints(k+2).val(1)
                        obj.flatOutputs{i}.segmentAcceleration(k-1:k+1) = [1 0 -1];
                    elseif obj.flatOutputs{i}.waypoints(k-1).val(1) > obj.flatOutputs{i}.waypoints(k+2).val(1)                            
                        obj.flatOutputs{i}.segmentAcceleration(k-1:k+1) = [-1 0 1];
                    else
                        obj.flatOutputs{i}.segmentAcceleration(k-1:k+1) = [0 0 0];
                    end
                    obj.flatOutputs{i}.segmentType(k-1:k+1) = [segmentTypeEnum.free segmentTypeEnum.constantVelocity segmentTypeEnum.free];
                end
            end
        end
                
        function makeStepTrajectory(obj)
            for i=1:3
                obj.flatOutputs{i}.updatePolyCoefsForStepTrajectory;
            end
        end
        
        function setTrajectoryFromPolyCoefs(obj, p, dt)
            for i=1:3
                obj.flatOutputs{i}.setTrajectoryFromPolyCoefs(p{i},dt);
            end
        end
        
        function trimWaypoints(obj, verbosity)
            if ~exist('verbosity', 'var')
                verbosity=0;
            end
            for i=1:3
                obj.flatOutputs{i}.trimWaypoints(verbosity);
            end
        end
             
        function out = optimiseTrapezoidalTimings(obj, verbosity)
            % Function to simultaneously optimise three trapezoidal
            % profiles, whilst enforcing acceleration, sqrt(vx^2+vy^2)
            % constraints, and coherence of position constrained waypoints.
            
            if ~exist('verbosity', 'var')
                verbosity = 0;
            end
            
            yalmip('clear');
                        
            dt = sdpvar(3,obj.numSegments,'full');
            a = sdpvar(3,obj.numSegments,'full');
            sdpvar t;
            F = [];            
            for i=1:3
                x0(i,1) = obj.flatOutputs{i}.waypoints(1).val(1);
                v0(i,1) = 0;
            end
            
            % Define polynomials and their derivatives, plus waypoint
            % value variables
            for i=1:3
                for j=2:3:obj.numSegments
                    % Zero acceleration variables during constant velocity sections
                    a(i,j) = 0;
                    
                    if i<=2
                        aMaxTemp = obj.aMax;
                    else
                        aMaxTemp = obj.ddphiMax;
                    end
                    
                    
                    F = [F -aMaxTemp <= a(i,j-1) <= aMaxTemp];
                    F = [F -aMaxTemp <= a(i,j+1) <= aMaxTemp];
                        
%                     if obj.flatOutputs{i}.waypoints(j-1).val <= obj.flatOutputs{i}.waypoints(j+2).val
%                         F = [F 0 <= a(i,j-1) <= aMaxTemp];
%                         F = [F -aMaxTemp <= a(i,j+1) <= 0];
%                     else
%                         F = [F -aMaxTemp <= a(i,j-1) <= 0];
%                         F = [F 0 <= a(i,j+1) <= aMaxTemp];
%                     end
                        
                end
            end
            
            v = sdpvar(3,obj.numWaypoints,'full');
            x = sdpvar(3,obj.numWaypoints,'full');
            % Integrate
            for i=1:3
                v(i,1) = v0(i);
                x(i,1) = x0(i);
                for j=2:obj.numWaypoints
                    v(i,j) = int(a(i,j-1),t) + v(i,j-1);
                    x(i,j) = int(v(i,j),t) + x(i,j-1);
                    v(i,j) = replace(v(i,j),t,dt(i,j-1));
                    x(i,j) = replace(x(i,j),t,dt(i,j-1));
                end
            end
                             
            % Velocity inequality constraints
            for i=2:obj.numWaypoints
                F = [F v(1,i)^2 + v(2,i)^2 <= obj.vMax^2]; % Norm constraint
%                 F = [F -obj.vMax <= v(1:2,i) <= obj.vMax]; % Box constraint
                F = [F -obj.dphiMax <= v(3,i) <= obj.dphiMax];
            end
            
            
            % dt positivity constraint
            F = [F dt >= 0];
                        
            % Coherence of durations of position->position segments between flat outputs
            for i=1:3:obj.numSegments
                F = [F sum(dt(1,i:i+2)) == sum(dt(2,i:i+2))];
                F = [F sum(dt(1,i:i+2)) == sum(dt(3,i:i+2))];
            end
            
            % Cost
            J = sum(sum(dt(:,:))); % Faster than cost based on just one set of durations
            
            % Get position waypoints
            for i=1:3
                w(i,:) = obj.flatOutputs{i}.getValuesByType(waypointTypeEnum.position);
            end
            
            % Waypoint position constraints         
            for i=4:3:obj.numWaypoints
                F = [F x(:,i) == w(:,ceil(i/3))];
            end
            
            % Terminal velocity constraint
            F = [F v(:,obj.numWaypoints) == 0];
            
                                    
            % Solve
            opt = sdpsettings;
            opt.cachesolvers = 1;
            opt.removeequalities=0;
            opt.verbose = verbosity;
            opt.fmincon.UseParallel = 0; % Doesn't appear to give any speedup
            opt.showprogress = 0;
%             opt.fmincon.TolFun = 1e-2; % Minimum improvement in cost function
%             opt.fmincon.TolCon = 1e-3; % Minimum constraint violation

%             assign(dt, 4*ones(size(dt)));
%             assign(a, zeros(size(a)));
            
            diag = optimize(F,J,opt);
            
            if verbosity
                disp(['Trapezoidal profile optimised in ' num2str(diag.solvertime) ' seconds']);
            end
                        
            % Update polycoefs
            x = value(x);
            v = value(v);
            for i=1:3
                for j=1:obj.numSegments
                    p = zeros(obj.flatOutputs{i}.polyDegree+1,1);
                    p(end) = x(i,j);
                    p(end-1) = v(i,j);
                    p(end-2) = a(i,j)/2;
                    obj.flatOutputs{i}.manuallySetPolyCoefs(j,p);
                end
            end
            
            % Update durations
            for i=1:3
                durations = value(dt(i,:));
                durations(durations<1e-2) = 0;
                obj.flatOutputs{i}.setDurationsByIndex(durations);
            end
            
            % Update accelerations and velocities
            for i=1:3
                obj.flatOutputs{i}.segmentAcceleration = value(a(i,:));
                obj.flatOutputs{i}.segmentAcceleration(abs(obj.flatOutputs{i}.segmentAcceleration) < 1e-2) = 0;
                obj.flatOutputs{i}.segmentInitialVelocity = [v0(i) value(v(i,:))];
            end
            
            out.solveTime = diag.solvertime;
        end
        
        function out = optimiseTrapezoidalTimingsSubsegmentCoherence(obj, verbosity)
            % Function to simultaneously optimise three trapezoidal
            % profiles, whilst enforcing acceleration, sqrt(vx^2+vy^2)
            % constraints, coherence of position constrained waypoints, 
            % and subsegment coherence between S1 and S2.
            
            if ~exist('verbosity', 'var')
                verbosity = 0;
            end
            
            yalmip('clear');
                        
            dt = sdpvar(3,obj.numSegments,'full');
            a = sdpvar(3,obj.numSegments,'full');
            sdpvar t;
            F = [];            
            for i=1:3
                x0(i,1) = obj.flatOutputs{i}.waypoints(1).val(1);
                v0(i,1) = 0;
            end
            
            % Define polynomials and their derivatives, plus waypoint
            % value variables
            for i=1:3
                for j=2:3:obj.numSegments
                    % Zero acceleration variables during constant velocity sections
                    a(i,j) = 0;
                    
                    if i<=2
                        aMaxTemp = obj.aMax;
                    else
                        aMaxTemp = obj.ddphiMax;
                    end
                                        
                    F = [F -aMaxTemp <= a(i,j-1) <= aMaxTemp];
                    F = [F -aMaxTemp <= a(i,j+1) <= aMaxTemp];                        
                end
            end
            
            v = sdpvar(3,obj.numWaypoints,'full');
            x = sdpvar(3,obj.numWaypoints,'full');
            % Integrate
            for i=1:3
                v(i,1) = v0(i);
                x(i,1) = x0(i);
                for j=2:obj.numWaypoints
                    v(i,j) = int(a(i,j-1),t) + v(i,j-1);
                    x(i,j) = int(v(i,j),t) + x(i,j-1);
                    v(i,j) = replace(v(i,j),t,dt(i,j-1));
                    x(i,j) = replace(x(i,j),t,dt(i,j-1));
                end
            end
                             
            % Velocity inequality constraints
            for i=2:obj.numWaypoints
                F = [F v(1,i)^2 + v(2,i)^2 <= obj.vMax^2]; % Norm constraint
                F = [F -obj.dphiMax <= v(3,i) <= obj.dphiMax];
            end
            
            
            % dt positivity constraint
            F = [F dt >= 0];
                        
            % Coherence of durations of position->position segments between
            % flat outputs plus subsegment coherence for S1 S2
            for i=1:3:obj.numSegments
                F = [F dt(1,i:i+2) == dt(2,i:i+2)]; % Could be optimised by eliminating a column of dt
                F = [F sum(dt(1,i:i+2)) == sum(dt(3,i:i+2))];
            end
            
            % Cost
            J = sum(sum(dt(:,:))); % Faster than cost based on just one set of durations
            
            % Get position waypoints
            for i=1:3
                w(i,:) = obj.flatOutputs{i}.getValuesByType(waypointTypeEnum.position);
            end
            
            % Waypoint position constraints         
            for i=4:3:obj.numWaypoints
                F = [F x(:,i) == w(:,ceil(i/3))];
            end
            
            % Terminal velocity constraint
            F = [F v(:,obj.numWaypoints) == 0];
            
                                    
            % Solve
            opt = sdpsettings;
            opt.cachesolvers = 1;
            opt.removeequalities=0;
            opt.verbose = verbosity;
            opt.fmincon.UseParallel = 0; % Doesn't appear to give much speedup
            opt.showprogress = 0;
%             opt.fmincon.TolFun = 1e-2; % Minimum improvement in cost function
%             opt.fmincon.TolCon = 1e-3; % Minimum constraint violation


%             assign(dt, 4*ones(size(dt)));
%             assign(a, zeros(size(a)));
            
            diag = optimize(F,J,opt);
            
            if verbosity
                disp(['Trapezoidal profile optimised in ' num2str(diag.solvertime) ' seconds']);
            end
            
            % Update polycoefs
            x = value(x);
            v = value(v);
            for i=1:3
                for j=1:obj.numSegments
                    p = zeros(obj.flatOutputs{i}.polyDegree+1,1);
                    p(end) = x(i,j);
                    p(end-1) = v(i,j);
                    p(end-2) = a(i,j)/2;
                    obj.flatOutputs{i}.manuallySetPolyCoefs(j,p);
                end
            end
            
            % Update durations
            for i=1:3
                durations = value(dt(i,:));
                durations(durations<1e-2) = 0;
                obj.flatOutputs{i}.setDurationsByIndex(durations);
            end
            
            % Update accelerations and velocities
            for i=1:3
                obj.flatOutputs{i}.segmentAcceleration = value(a(i,:));
                obj.flatOutputs{i}.segmentAcceleration(abs(obj.flatOutputs{i}.segmentAcceleration) < 1e-2) = 0;
                obj.flatOutputs{i}.segmentInitialVelocity = [v0(i) value(v(i,:))];
            end
            
            out.solveTime = diag.solvertime;
        end
        
        function [J,vMax,solveTimes] = optimiseFlatOutputs(obj, method, verbosity, durations)
            
            % durations is a 3 element cell array of new segment durations
            % to be used
                     
            if ~exist('verbosity', 'var')
                verbosity = 0;
            end
            
            if ~exist('durations', 'var')
                durations = {[],[],[]};
            end            
            
            if ~iscell(durations)
                durations = {durations, durations, durations};
            end
            
            % Methods:
            % QR_decomp - QP method using quadprog or QR decomposition
            % QP_YALMIP - QP method using YALMIP 
            % SOS - Bounded SOS acceleration constraints
            % recursive_vel_ineqs_YALMIP - Recursively added velocity inequalities on QP
            % gridded_vel_ineqs_YALMIP - Gridded velocity inequalities on QP
            % recursive_vel_ineqs_fast - Recursively constrained QP, fast method used for gradient descent optimisation of timings
            switch method
                case optimisationTypeEnum.QR_decomp
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputQRDecomposition(verbosity, durations{1}) ...
                     obj.flatOutputs{2}.optimiseFlatOutputQRDecomposition(verbosity, durations{2}) ...
                     obj.flatOutputs{3}.optimiseFlatOutputQRDecomposition(verbosity, durations{3})];  
                case optimisationTypeEnum.QP_YALMIP
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputYALMIPQP(verbosity, durations{1}) ...
                     obj.flatOutputs{2}.optimiseFlatOutputYALMIPQP(verbosity, durations{2}) ...
                     obj.flatOutputs{3}.optimiseFlatOutputYALMIPQP(verbosity, durations{3})];  
                case optimisationTypeEnum.SOS
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputYALMIPAccelerationSOSBounded(verbosity, durations{1});
                        obj.flatOutputs{2}.optimiseFlatOutputYALMIPAccelerationSOSBounded(verbosity, durations{2});
                        obj.flatOutputs{3}.optimiseFlatOutputYALMIPAccelerationSOSBounded(verbosity, durations{3})];
                case optimisationTypeEnum.recursive_vel_ineqs_YALMIP
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputYALMIPQPRecursiveVelocityInequalities(verbosity, durations{1});
                        obj.flatOutputs{2}.optimiseFlatOutputYALMIPQPRecursiveVelocityInequalities(verbosity, durations{2});
                        obj.flatOutputs{3}.optimiseFlatOutputYALMIPQPRecursiveVelocityInequalities(verbosity, durations{3})];
                case optimisationTypeEnum.gridded_vel_ineqs_YALMIP
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputYALMIPQPGriddingVelocityInequalities(verbosity, durations{1});
                        obj.flatOutputs{2}.optimiseFlatOutputYALMIPQPGriddingVelocityInequalities(verbosity, durations{2});
                        obj.flatOutputs{3}.optimiseFlatOutputYALMIPQPGriddingVelocityInequalities(verbosity, durations{3})];
                case optimisationTypeEnum.recursive_vel_ineqs_fast
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputFastQPRecursiveVelocityInequalities(verbosity, durations{1});
                        obj.flatOutputs{2}.optimiseFlatOutputFastQPRecursiveVelocityInequalities(verbosity, durations{2});
                        obj.flatOutputs{3}.optimiseFlatOutputFastQPRecursiveVelocityInequalities(verbosity, durations{3})]; 
                case optimisationTypeEnum.SOS_velocity
                    temp = [obj.flatOutputs{1}.optimiseFlatOutputYALMIPVelocitySOS(verbosity, durations{1});
                        obj.flatOutputs{2}.optimiseFlatOutputYALMIPVelocitySOS(verbosity, durations{2});
                        obj.flatOutputs{3}.optimiseFlatOutputYALMIPVelocitySOS(verbosity, durations{3})]; 
                case optimisationTypeEnum.SOS_velocity_circular
                    temp = obj.optimiseFlatOutputsCircularVelocitySOS(verbosity, durations{1});
                otherwise
                    error('Invalid method');
            end
            J = sum([temp(:).J]);
            vMax = vertcat(temp(:).vMax);
            solveTimes = [temp(:).solveTime];
            
            if verbosity
                disp(['Final costs ' num2str(temp(1).J) ', ' num2str(temp(2).J) ', and ' num2str(temp(3).J) ' in ' num2str(sum(solveTimes)) ' seconds']);
            end
        end
        
        function out = optimiseFlatOutputsCircularVelocitySOS(obj, verbosity, durations)
            
            if ~exist('verbosity', 'var')
                verbosity=0;
            end
            
            tic            
            yalmip('clear');
            
            sdpvar t; % Define independent time variable
            F = []; % Clear constraints
            c = {}; % Clear coefficients
            q = {};
            dt = [obj.flatOutputs{1}.getDurationsByIndex; obj.flatOutputs{2}.getDurationsByIndex];
    
            % Define polynomials and their derivatives
            p = sdpvar(2, obj.numSegments, max([obj.config(1).conDerivDeg, 6]));
            for i=1:obj.numSegments
                p(:,i,1) = [polynomial(t, obj.config(1).polyDegree) polynomial(t, obj.config(1).polyDegree)];
            end           
            for i=2:size(p,3)
                for j=1:size(p,2)
                    for k=1:size(p,1)
                        p(k,j,i) = jacobian(p(k,j,i-1), t);
                    end
                end
            end
            
            % Define circular velocity SOS constraints
            for i=1:obj.numSegments
                
                % TO DO
                % Problem here is that the expression p1^2 + p2^2 is only
                % valid if p1 and p2 are defined over the same domain. In
                % this application these will differ, so we'd have to write
                % p1^2(t-d)+p2^2(t) to synchronise, which makes the problem
                % intractable. Can we instead enforce subsegment timing
                % coherence between these two flat outputs also?
                
                % Lets assume subsegment coherence
                a = 0;
                b = dt(1,i); 
                               
                % Approximating 2-Norm using linear inequalities                
                % Number of inequalities in approximation
                M = 8;
                if mod(obj.config(1).polyDegree-1,2) == 0
                    d = (obj.config(1).polyDegree-1)/2;
                    for m=1:M
                        Gamma = (p(2,i,2) - obj.vMax*sin(2*pi*m/M))*(cos(2*pi*(m+1)/M) - cos(2*pi*m/M)) ...
                            - (p(1,i,2) - obj.vMax*cos(2*pi*m/M))*(sin(2*pi*(m+1)/M) - sin(2*pi*m/M));
                        [q{end+1}, c{end+1}] = polynomial(t, (2*d)-2);
                        F = [F sos(q{end})];
                        F = [F sos(Gamma - t*(b-t)*q{end})];
                    end
                else
                    d = (obj.config(1).polyDegree-2)/2;
                    for m=1:M
                        m = m+0.5;
                        Gamma = (p(2,i,2) - sqrt(2)*obj.vMax*sin(2*pi*m/M))*(cos(2*pi*(m+1)/M) - cos(2*pi*m/M)) ...
                            - (p(1,i,2) - sqrt(2)*obj.vMax*cos(2*pi*m/M))*(sin(2*pi*(m+1)/M) - sin(2*pi*m/M));
                        [q{end+1}, c{end+1}] = polynomial(t, (2*d)-2);
                        F = [F sos(q{end})];
                        F = [F sos((Gamma - (b-t)*q{end})/t)];
                    end
                end
                
%                 % 2-Norm method
%                 if mod(2*(obj.config(1).polyDegree-1),2) == 0
%                     d = 2*(obj.config(1).polyDegree-1)/2;
%                     [q{end+1}, c{i}] = polynomial(t, (2*d)-2);
%                     F = [F sos(q{end})];
% %                     F = [F sos(obj.vMax^2 - cpower(p(1,i,2),2) - cpower(p(2,i,2),2) - (t-a)*(b-t)*q{end})];
%                     F = [F sos(obj.vMax^2 - p(1,i,2)^2 - p(2,i,2)^2 - (t-a)*(b-t)*q{end})];
%                 else % Should never occur, as squaring makes all degree even
%                 end
            end

            % Cost function
            for i=1:obj.numSegments
                J(i) = int(p(1,i,obj.config(1).derivToMin+1)^2,t,0,dt(1,i)) + int(p(2,i,obj.config(1).derivToMin+1)^2,t,0,dt(2,i));
            end
            J = sum(J);

            % Define segment initial constraints if the waypoint defines position
            for i=1:obj.numSegments
                for j=1:2
                    if ismember(1, obj.flatOutputs{j}.getDerivativesDefinedByType(obj.flatOutputs{j}.waypoints(i).type))
                        F = [F replace(squeeze(p(j,i,obj.flatOutputs{j}.getDerivativesDefinedByType(obj.flatOutputs{j}.waypoints(i).type))),t,0) == obj.flatOutputs{j}.waypoints(i).val];
                    end
                end
            end

            % Define final segment terminal constraint
            for j=1:2
                F = [F replace(squeeze(p(j,end,obj.flatOutputs{j}.getDerivativesDefinedByType(obj.flatOutputs{j}.waypoints(end).type))),t,dt(j,end)) == obj.flatOutputs{j}.waypoints(end).val];
            end

            % Define intermediary equivalence constraints
            for i=1:obj.numSegments-1
                for j=1:2
                    F = [F replace(squeeze(p(j,i,1:(obj.config(1).conDerivDeg+1))),t,dt(j,i)) == replace(squeeze(p(j,i+1,1:(obj.flatOutputs{j}.config.conDerivDeg+1))),t,0)];
                end
            end

            opt = sdpsettings;
            opt.verbose = verbosity; % Massively slows mosek if on
            opt.showprogress = verbosity>0;
            opt.cachesolvers = 0;

            % Perform optimization
            if ~isempty(c)
                diag = optimize(F,J,opt,[coefficients(p(:,:,:),t); vertcat(c{:})]);
            else
                diag = optimize(F,J,opt);
            end

            % Package polynomial coefficients
            for i=1:obj.numSegments
                obj.flatOutputs{1}.manuallySetPolyCoefs(i, flipud([value(coefficients(p(1,i,1),t)); zeros(obj.config(1).polyDegree+1-numel(coefficients(p(1,i,1),t)),1)]));
                obj.flatOutputs{2}.manuallySetPolyCoefs(i, flipud([value(coefficients(p(2,i,1),t)); zeros(obj.config(2).polyDegree+1-numel(coefficients(p(2,i,1),t)),1)]));
            end

            % Optimise heading
            headingOut = obj.flatOutputs{3}.optimiseFlatOutputYALMIPVelocitySOS(0);
            
            % Get final cost
            % J = value(J);

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

%             % Set optimised flag
%             obj.optimisedByMethod = optimisationTypeEnum.SOS;

            % Set outputs
            out.J = 0;%J;
            out.vMax = [];
            out.solveTime = diag.solvertime;
%             for i = 2:3:obj.numSegments
%                 p = obj.getPolyCoefs(i);
%                 out.vMax = abs([out.vMax; p(end-1)]);
%             end
            out = [out out headingOut];
        end
        
        function out = optimiseFlatOutputsSOCPVelocityConstraints(obj, verbosity, durations)
            % Defines and optimises problem using YALMIP. Only polynomial
            % coefficients are optimised. Optional argument durations[] can
            % be used to update all segment durations before optimsing.
            % The time indices of velocity maximums are found by examining
            % the roots of the acceleration polynomials. Velocity
            % inequalities are then recursively inserted at these time
            % indices until the all peak velocities are within the
            % constraint tolerance.
            
            if ~exist('durations', 'var')
                durations = {obj.flatOutputs{1}.getDurationsByIndex, ....
                    obj.flatOutputs{2}.getDurationsByIndex, ...
                    obj.flatOutputs{3}.getDurationsByIndex};
            else
                if isempty(durations)
                    durations = {obj.flatOutputs{1}.getDurationsByIndex, ....
                        obj.flatOutputs{2}.getDurationsByIndex, ...
                        obj.flatOutputs{3}.getDurationsByIndex};
                else
                    for i=1:3
                        obj.flatOutputs{i}.setDurationsByIndex(durations{i});
                    end
                end
            end 
            
            % Shortcut if optimisation parameters haven't changed and we've
            % already optimised
%             forceRegen = false;
%             if (obj.optimisedByMethod == optimisationTypeEnum.recursive_SOCP_vel_ineqs) && ~forceRegen
%                 disp('Reusing existing solution');
%                 out = obj.prevOut;
%                 return
%             end
            tic;

            % Prevents accumulation of junk in memory, giving a massive performance boost in gradient descent
            yalmip('clear');

            % Define independent time variable
            sdpvar t;

            p = sdpvar(2, obj.numSegments, max([obj.config.conDerivDeg, 6]));

            % Define durations variable
            dt = durations;

            % Define polynomials and their derivatives
            for i=1:2
                for j=1:obj.numSegments
                    p(i,j,1) = polynomial(t,obj.config(i).polyDegree);
                    for k=2:max([obj.config(i).conDerivDeg, 6])
                        p(i,j,k) = jacobian(p(i,j,k-1),t);
                    end
                end
            end

            % Cost function
            % This needs to consider that polynomial subsegemnt boundaries
            % may not be overlapping - ignored for now
%             dtCumSum = [cumsum(dt{i}); cumsum(dt{2})];
%             idx1=1; idx2=1;
%             
%             J = sdpvar(0);
%             while true
%                 if dtCumSum(1,idx1) < dtCumSum(2,idx2)
%                     J = J + int(p(1,i,obj.config(i).derivToMin+1)^2,t,0,dt(i)) ...
%                         + int(p(2,i,obj.config(i).derivToMin+1)^2,t,0,dt(i));
%                 end
%             end
            
            J = 0;
            for i=1:2
                for j=1:obj.numSegments
                    J = J + int(p(i,j,obj.config(i).derivToMin+1)^2,t,0,dt{i}(j));
                end
            end

            % Define segment initial constraints if the waypoint defines position
            F = [];
            for i=1:2
                for j=1:obj.numSegments
                    if ismember(1, obj.flatOutputs{i}.getDerivativesDefinedByType(obj.flatOutputs{i}.waypoints(j).type))
                        F = [F replace(squeeze(p(i,j,obj.flatOutputs{i}.getDerivativesDefinedByType(obj.flatOutputs{i}.waypoints(j).type))),t,0) == obj.flatOutputs{i}.waypoints(j).val];
                    end
                end
            end

            % Define final segment terminal constraint
            for i=1:2
                F = [F replace(squeeze(p(i,end,obj.flatOutputs{i}.getDerivativesDefinedByType(obj.flatOutputs{i}.waypoints(end).type))),t,dt{i}(end)) == obj.flatOutputs{i}.waypoints(end).val];
            end

            % Define intermediary equivalence constraints
            for i=1:2
                for j=1:obj.numSegments-1
                    F = [F replace(squeeze(p(i,j,1:obj.config(i).conDerivDeg)),t,dt{i}(j)) == replace(squeeze(p(i,j+1,1:obj.config(i).conDerivDeg)),t,0)];
                end
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
        
        %% Timing optimisation functions                
        function optimiseSectionsTimingsIncVelocityConstraints(obj)
            % Optimises all section timings with velocity waypoints whilst
            % maintaining coherence of position waypoints between flat
            % outputs. A softened inequality constraint is enforced on peak
            % velocity during velocity constrained sections.
            
            
            ns = obj.numSegments;
            Aeq = []; beq = [];
            
            kt = 5e-4;%1e-3; % Time cost
            
            dt0 = 2*[obj.flatOutputs{1}.getDurationsByIndex obj.flatOutputs{2}.getDurationsByIndex obj.flatOutputs{3}.getDurationsByIndex]; % Initial guess
            
            method = optimisationTypeEnum.recursive_vel_ineqs_fast;
            verbosity = 0;
            
            % Cost function - optimisation works much better when cost is normalised
            J = @(dt) (costFun(obj, dt, method, verbosity) + kt*sum(dt(1:ns)))/(kt*1e1);
            
            % Equality constraints to ensure coherency of
            % position->position timings between flat outputs
            for i=1:3:ns
                % flatOutput{1} == flatOutput{2}
                Aeq(end+1, i:i+2) = 1;
                Aeq(end, ns+(i:i+2)) = -1;
                % flatOutput{2} == flatOutput{3}
                Aeq(end+1, ns+(i:i+2)) = 1;
                Aeq(end, 2*ns+(i:i+2)) = -1;
            end            
            beq = zeros((ns/3)*2,1);
            
            % Peak velocity inequality constraints
            nlCon = @(dt) nlConFun(obj, dt, method, verbosity);
            
            % Constrain all durations to be positive (substantially so if not a
            % velocity constrained section - quickly runs into numerical issues)
            lb = 0.1*ones(ns*3,1);
            
            % Remove lower bound on constant velocity sections
            lb(2:3:ns) = 0;
            lb(ns+(2:3:ns)) = 0;
            lb(2*ns+(2:3:ns)) = 0;
            
            opt = optimoptions('fmincon','UseParallel',true);
            opt.Display = 'iter-detailed';
            opt.MaxFunctionEvaluations = 1e4;
            
            % Optimise
            [dtOpt,FVAL,EXITFLAG,OUTPUT] = fmincon(J,dt0,[],[],Aeq,beq,lb,[],nlCon,opt);
%             [dtOpt,FVAL,EXITFLAG,OUTPUT] = fmincon(J,dt0,[],[],[],[],lb,[],nlConFun,opt);
            
            % Update durations
            for i=1:numel(obj.flatOutputs)
                obj.flatOutputs{i}.setDurationsByIndex(dtOpt((i-1)*ns+(1:ns)));
            end
            
            function J = costFun(obj, dt, method, verbosity)            
                ns = obj.numSegments;

                durations = {dt(1:ns), dt(ns+(1:ns)), dt(2*ns+(1:ns))};

                J = obj.optimiseFlatOutputs(method, verbosity, durations);
            end

            function [C,Ceq] = nlConFun(obj, dt, method, verbosity)        
                ns = obj.numSegments;

                durations = {dt(1:ns), dt(ns+(1:ns)), dt(2*ns+(1:ns))};

                [J,vMaxViolation] = obj.optimiseFlatOutputs(method, verbosity, durations);

                C = -(vMaxViolation.^2); % Solves much faster than linear penalty
%                 C = -v;
                Ceq = [];
            end
        end
                
         
        % Old method, works with constant velocity sections
        function optimiseSectionTimings(obj, verbosity)
            % Optimises segment timings using gradient descent method            
            
            ns = obj.numSegments;
            kt = 0.1; % Time cost
            
            % Cost function
%             J = @(dt) costFun(obj, dt, 0);
            J = @(dt) costFun(obj, dt, verbosity) + kt*sum(dt);
            
            % Nonlinear constraints
            nlCon = @(dt) nlConFun(obj,dt,0);
            
            % Equality constraints to ensure coherency of
            % position->position timings between flat outputs
            Aeq = []; beq = [];
            for i=1:3:ns
                % flatOutput{1} == flatOutput{2}
                Aeq(end+1, i:i+2) = 1;
                Aeq(end, ns+(i:i+2)) = -1;
                % flatOutput{2} == flatOutput{3}
                Aeq(end+1, ns+(i:i+2)) = 1;
                Aeq(end, 2*ns+(i:i+2)) = -1;
            end            
            beq = zeros((ns/3)*2,1);
            
%             % Total duration constraint for comparison with trapezoidal cost
%             Aeq(end+1,1:ns) = 1;
%             beq(end+1) = sum([obj.flatOutputs{1}.getDurationsByIndex obj.flatOutputs{2}.getDurationsByIndex obj.flatOutputs{3}.getDurationsByIndex])/3;
                        
            % Constrain all durations to be positive (substantially so if not a
            % velocity constrained section - quickly runs into numerical issues)
            lb = 1e-2*ones(ns*3,1);
            ub = inf*ones(ns*3,1);
            
            A = []; b = [];
%             % waypoints->waypoint durations must be at least dx/vMax long
%             for i=1:3:ns
%                 A(end+1, i:i+2) = -1;
%                 b(end+1) = -(abs(obj.flatOutputs{1}.waypoints(i).val(1)-obj.flatOutputs{1}.waypoints(i+3).val(1))/obj.vMax) - lb(1)*2;
%                 A(end+1, ns+(i:i+2)) = -1;
%                 b(end+1) = -(abs(obj.flatOutputs{2}.waypoints(i).val(1)-obj.flatOutputs{2}.waypoints(i+3).val(1))/obj.vMax) - lb(1)*2;
%                 A(end+1, 2*ns+(i:i+2)) = -1;
%                 b(end+1) = -(abs(obj.flatOutputs{3}.waypoints(i).val(1)-obj.flatOutputs{3}.waypoints(i+3).val(1))/obj.vMax) - lb(1)*2;
%             end
            
            
%             dt0 = [obj.flatOutputs{1}.getDurationsByIndex obj.flatOutputs{2}.getDurationsByIndex obj.flatOutputs{3}.getDurationsByIndex]; % Initial guess
%             dt0 = ones(3*ns,1)'/sum([obj.flatOutputs{1}.getDurationsByIndex obj.flatOutputs{2}.getDurationsByIndex obj.flatOutputs{3}.getDurationsByIndex])/3;
            dt0 = ones(3*ns,1)';
            
            opt = optimoptions('fmincon');
            opt.FiniteDifferenceStepSize = 1e-2; % Appears superior to sqrt(eps)
            opt.UseParallel = true;
            if verbosity>0
                opt.Display = 'iter-detailed';
            else
                opt.Display = 'off';
            end
            opt.MaxFunctionEvaluations = 1e5;
%             opt.OptimalityTolerance = 1e-3;
%             opt.StepTolerance = 1e-10;
            
%             outputFun = @(x,optimValues,state) outputFunction(obj,x,optimValues,state);
%             opt.OutputFcn = outputFun;
            
            % Optimise
            [dtOpt,fval,exitFlag,output] = fmincon(J,dt0,A,b,Aeq,beq,lb,ub,nlCon,opt);          
            
            % Generate final trajectory
            ns = obj.numSegments;
            J = obj.optimiseFlatOutputs(8, verbosity, {dtOpt(1:ns), dtOpt(ns+(1:ns)), dtOpt(2*ns+(1:ns))});
            
            if verbosity > 0
                disp(['Final crackle cost ' num2str(J)]);
            end
            
            function J = costFun(obj, dt, verbosity)            
                ns = obj.numSegments; % Number of segments (including velocity constraints)

                [J,~] = obj.optimiseFlatOutputs(8, verbosity, {dt(1:ns), dt(ns+(1:ns)), dt(2*ns+(1:ns))});
            end
            
            function [C,Ceq] = nlConFun(obj, dt, verbosity)            
                ns = obj.numSegments; % Number of segments (including velocity constraints)

                [~,C] = obj.optimiseFlatOutputs(8, verbosity, {dt(1:ns), dt(ns+(1:ns)), dt(2*ns+(1:ns))});
%                 C = C.^2; % To create smooth barrier
                Ceq = [];
            end
            
            function stop = outputFunction(obj, dt,optimValues,state)
                obj.plotFlatOutputs(false,false);                
                stop = 0;
            end
        end
        
        function optimiseSectionTimingsQRDecomp(obj, verbosity)
            % Optimises segment timings using gradient descent method            
            
            ns = obj.numSegments;
            kt = 1e3; % Time cost
            
            % Cost function
            J = @(dt) costFun(obj, dt, 0) + kt*sum(dt);
            
                        
            % Constrain all durations to be positive (substantially so if not a
            % velocity constrained section - quickly runs into numerical issues)
            lb = 1e-2*ones(1,ns);
            ub = inf*ones(1,ns);
            
            dt0 = ones(1,ns);
            
            opt = optimoptions('fmincon');
            opt.FiniteDifferenceStepSize = 1e-2; % Appears superior to sqrt(eps)
            opt.UseParallel = false;
            if verbosity>0
                opt.Display = 'iter-detailed';
            else
                opt.Display = 'off';
            end
            opt.MaxFunctionEvaluations = 1e5;
%             opt.OptimalityTolerance = 1e-3;
%             opt.StepTolerance = 1e-10;
            
%             outputFun = @(x,optimValues,state) outputFunction(obj,x,optimValues,state);
%             opt.OutputFcn = outputFun;
            
            % Optimise
            [sol,fval,exitFlag,output] = fmincon(J,dt0,[],[],[],[],lb,ub,[],opt);          
            
            % Generate final trajectory
            J = obj.optimiseFlatOutputs(optimisationTypeEnum.QR_decomp, verbosity, sol);
            
            if verbosity > 0
                disp(['Final crackle cost ' num2str(J)]);
            end
            
            function J = costFun(obj, dt, verbosity)
                [J,~] = obj.optimiseFlatOutputs(optimisationTypeEnum.QR_decomp, verbosity, dt);
            end
        end
        
        
        %% Utility functions
        
        function intersectDurations(obj, dt)
            % Function to take n vectors of polynomial durations, returning
            % a vector of structs of starts and ends within each polynomial
            % representing sections of polynomials. All end-start should be
            % identical.
            
        end
        
        function [qvdv,u,S,t] = getStateTrajectories(obj,dt)
            %GETSTATETRAJECTORIES Performs polynomial optimisation, then
            %uses differentially flat model toconstruct state and input
            %trajectories at intervals of dt.
            
            % Check all flat outputs have their last waypoints at the same
            % time index
            if ~isequal(obj.flatOutputs{1}.tend, ...
                    obj.flatOutputs{2}.tend, ...
                    obj.flatOutputs{3}.tend)
                if any(abs(diff([obj.flatOutputs{1}.tend, obj.flatOutputs{2}.tend, obj.flatOutputs{3}.tend])) > 1e-1)
                    error(['Last waypoints of flat outputs are at different time indexes, maximum difference of ' ...
                        num2str(max(abs(diff([obj.flatOutputs{1}.tend, obj.flatOutputs{2}.tend, obj.flatOutputs{3}.tend])))) ...
                        ' seconds']);
                elseif any(abs(diff([obj.flatOutputs{1}.tend, obj.flatOutputs{2}.tend, obj.flatOutputs{3}.tend])) ~= 0)
                    warning('Small difference in flat outputs detected, replacing all with the mean');
                    tendNew = mean([obj.flatOutputs{1}.tend, obj.flatOutputs{2}.tend, obj.flatOutputs{3}.tend]);
                    obj.flatOutputs{1}.waypoints(end).t = tendNew;
                    obj.flatOutputs{2}.waypoints(end).t = tendNew;
                    obj.flatOutputs{3}.waypoints(end).t = tendNew;
                end
            end
            
            % Construct sampled state trajectories
            t = (0:dt:obj.tend);
            qvdv = zeros(12,numel(t));
            u = zeros(4,numel(t));
            S = zeros(max([obj.flatOutputs{1}.polyDegree, obj.flatOutputs{2}.polyDegree, obj.flatOutputs{3}.polyDegree])+1,3,numel(t));
            
            for i=1:numel(t)
                
                [qvdv(:,i),u(:,i)] = obj.statesUFun(obj.flatOutputs{1}.getSDerivatives(t(i)) ...
                    , obj.flatOutputs{2}.getSDerivatives(t(i)) ...
                    , obj.flatOutputs{3}.getSDerivatives(t(i)));
                
                for j=1:3
                    S(:,j,i) = [obj.flatOutputs{j}.getSDerivatives(t(i)); zeros(size(S,1) - (obj.flatOutputs{j}.polyDegree+1), 1)];
                end
            end            
        end
        
        function tend = get.tend(obj)
            tend = max([obj.flatOutputs{1}.tend, obj.flatOutputs{2}.tend, obj.flatOutputs{3}.tend]);
        end
        
        function numSegments = get.numSegments(obj)
            if ~isequal(obj.flatOutputs{1}.numSegments, obj.flatOutputs{2}.numSegments, obj.flatOutputs{3}.numSegments)
                error('Getting the number of segments of the trajectory object only makes sense if all three flat outputs have equal numbers of segments');
            end
            numSegments = obj.flatOutputs{1}.numSegments;
        end
        
        function numWaypoints = get.numWaypoints(obj)
            if ~isequal(obj.flatOutputs{1}.numWaypoints, obj.flatOutputs{2}.numWaypoints, obj.flatOutputs{3}.numWaypoints)
                error('Getting the number of waypoints of the trajectory object only makes sense if all three flat outputs have equal numbers of segments');
            end
            numWaypoints = obj.flatOutputs{1}.numWaypoints;
        end
                
        function msg = getROSTrajectoryMessage(obj)
                        
            msg = rosmessage('polynomial_msgs/PolynomialTrajectory');            
            
            for i=1:3
                for k=1:obj.flatOutputs{i}.numSegments
                    segMsgs{i}(k) = rosmessage('polynomial_msgs/PolynomialSegment');
                    segMsgs{i}(k).Degree = obj.flatOutputs{i}.config.polyDegree;
                    segMsgs{i}(k).SegmentTime = obj.flatOutputs{i}.getDurationsByIndex(k);
                    segMsgs{i}(k).Coefs = obj.flatOutputs{i}.polyCoefs(:,k);
                end
            end
            msg.X = segMsgs{1};
            msg.Y = segMsgs{2};
            msg.Phi = segMsgs{3};
        end
        
        function writeDiscretisedTrajectoryToFile(obj, path)
            [pvdv,u,~,~] = obj.getStateTrajectories(0.001);
            data = [pvdv(1:8,:); u]';
            csvwrite(path,data);
        end
                
        %% Plotting functions        
        function plotStateTrajectories(obj)
            
            [qvdv,u,S,t] = obj.getStateTrajectories(0.01);            
            
            figure;
            subplot(4,4,1); plot(t, qvdv(1,:)); title('x');
            subplot(4,4,2); plot(t, qvdv(2,:)); title('y');
            subplot(4,4,3); plot(t, qvdv(3,:)); title('phi');
            subplot(4,4,4); plot(t, qvdv(4,:)); title('theta_p');
            subplot(4,4,5); plot(t, qvdv(5,:)); title('vx');
            subplot(4,4,6); plot(t, qvdv(6,:)); title('vy');
            subplot(4,4,7); plot(t, qvdv(7,:)); title('dphi');
            subplot(4,4,8); plot(t, qvdv(8,:)); title('dtheta_p');
            subplot(4,4,9); plot(t, qvdv(9,:)); title('dvx');
            subplot(4,4,10); plot(t, qvdv(10,:)); title('dvy');
            subplot(4,4,11); plot(t, qvdv(11,:)); title('ddphi');
            subplot(4,4,12); plot(t, qvdv(12,:)); title('ddtheta_p');
            subplot(4,4,13:16); plot(t, u); title('u');
        end
        
        function patches = generateSegmentPatches(obj, height)
            
            for i=1:3
                for j=1:obj.flatOutputs{i}.numSegments
                    % Get waypoints times
                    t = obj.flatOutputs{i}.getTimeIndicesByIndex;
                    patches{i}.x(:,j) = [t(j); t(j); t(j+1); t(j+1)];
                    patches{i}.y(:,j) = [height; -height; -height; height];
                    
                    switch obj.flatOutputs{i}.segmentType(j)
                        case segmentTypeEnum.constantVelocity 
                            patches{i}.c(j,1,:) = [0.9290 0.6940 0.1250];
                        case segmentTypeEnum.sosConstrained
                            patches{i}.c(j,1,:) = [0.8500 0.3250 0.0980];
                        case segmentTypeEnum.free
                            patches{i}.c(j,1,:) = [0 0.4470 0.7410];
                    end
                end
            end            
        end
        
        function plotFlatOutputs(obj, plotStates, generatePatches)
            
            [qvdv,u,S,t] = obj.getStateTrajectories(0.01); 
            
            for i=1:3
                segmentLinesX{i} = repmat(obj.flatOutputs{i}.getTimeIndicesByIndex, [2 1]);
            end
            
            if exist('plotStates', 'var')
                if ~plotStates
                    qvdv = qvdv*0;
                end
            end
            
            if ~exist('generatePatches', 'var')
                generatePatches = false;
            end
            
            if generatePatches
                patches = obj.generateSegmentPatches(1);
                
                patchYScaleMax = ceil(max(S(:,:,:),[],3));
                patchYScaleMin = floor(min(S(:,:,:),[],3));
                
                for i=1:3
                    for j=1:size(S,1)
                        patchesy{i,j} = repmat([patchYScaleMax(j,i); patchYScaleMin(j,i); patchYScaleMin(j,i); patchYScaleMax(j,i)], [1 size(patches{i}.x,2)]);
                    end
                end
                
                figure;
                scatterSize = 25;
                subplot(6,3,1); patch(patches{1}.x,patchesy{1,1},patches{1}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(1,1,:))'; qvdv(1,:)]); scatter(obj.flatOutputs{1}.getTimeIndicesByType(waypointTypeEnum.position), obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.position),scatterSize); title('S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,2); patch(patches{2}.x,patchesy{2,1},patches{2}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(1,2,:))'; qvdv(2,:)]); scatter(obj.flatOutputs{2}.getTimeIndicesByType(waypointTypeEnum.position), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.position),scatterSize); title('S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,3); patch(patches{3}.x,patchesy{3,1},patches{3}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(1,3,:))'; qvdv(3,:)]); scatter(obj.flatOutputs{3}.getTimeIndicesByType(waypointTypeEnum.position), obj.flatOutputs{3}.getValuesByType(waypointTypeEnum.position),scatterSize); title('S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,4); patch(patches{1}.x,patchesy{1,2},patches{1}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(2,1,:))'; qvdv(5,:)]); scatter(obj.flatOutputs{1}.getTimeIndicesByType(waypointTypeEnum.velocity), obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.velocity),scatterSize); title('dS_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,5); patch(patches{2}.x,patchesy{2,2},patches{2}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(2,2,:))'; qvdv(6,:)]); scatter(obj.flatOutputs{2}.getTimeIndicesByType(waypointTypeEnum.velocity), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.velocity),scatterSize); title('dS_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,6); patch(patches{3}.x,patchesy{3,2},patches{3}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(2,3,:))'; qvdv(7,:)]); scatter(obj.flatOutputs{3}.getTimeIndicesByType(waypointTypeEnum.velocity), obj.flatOutputs{3}.getValuesByType(waypointTypeEnum.velocity),scatterSize); title('dS_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,7); patch(patches{1}.x,patchesy{1,3},patches{1}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(3,1,:))'; qvdv(9,:)]); scatter(obj.flatOutputs{1}.getTimeIndicesByType(waypointTypeEnum.acceleration), obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.acceleration),scatterSize); title('ddS_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,8); patch(patches{2}.x,patchesy{2,3},patches{2}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(3,2,:))'; qvdv(10,:)]); scatter(obj.flatOutputs{2}.getTimeIndicesByType(waypointTypeEnum.acceleration), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.acceleration),scatterSize); title('ddS_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,9); patch(patches{3}.x,patchesy{3,3},patches{3}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, [squeeze(S(3,3,:))'; qvdv(11,:)]); scatter(obj.flatOutputs{3}.getTimeIndicesByType(waypointTypeEnum.acceleration), obj.flatOutputs{3}.getValuesByType(waypointTypeEnum.acceleration),scatterSize); title('ddS_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,10); patch(patches{1}.x,patchesy{1,4},patches{1}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(4,1,:))'); title('d3S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,11); patch(patches{2}.x,patchesy{2,4},patches{2}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(4,2,:))');  title('d3S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,12); patch(patches{3}.x,patchesy{3,4},patches{3}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(4,3,:))'); title('d3S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,13); patch(patches{1}.x,patchesy{1,5},patches{1}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(5,1,:))'); title('d4S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,14); patch(patches{2}.x,patchesy{2,5},patches{2}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(5,2,:))');  title('d4S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,15); patch(patches{3}.x,patchesy{3,5},patches{3}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(5,3,:))'); title('d4S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,16); patch(patches{1}.x,patchesy{1,6},patches{1}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(6,1,:))'); title('d5S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,17); patch(patches{2}.x,patchesy{2,6},patches{2}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(6,2,:))');  title('d5S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,18); patch(patches{3}.x,patchesy{3,6},patches{3}.c,'FaceAlpha',.1,'LineStyle','none'); hold on; plot(t, squeeze(S(6,3,:))'); title('d5S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);

                % Synchronise scaling of related plots
                linkaxes([subplot(6,3,1) subplot(6,3,4) subplot(6,3,7)],'x');
                linkaxes([subplot(6,3,2) subplot(6,3,5) subplot(6,3,8)],'x');
                linkaxes([subplot(6,3,3) subplot(6,3,6) subplot(6,3,9)],'x');
            else
                figure;
                scatterSize = 25;
                subplot(6,3,1); hold on; plot(t, [squeeze(S(1,1,:))'; qvdv(1,:)]); scatter(obj.flatOutputs{1}.getTimeIndicesByType(waypointTypeEnum.position), obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.position),scatterSize); title('S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,2); hold on; plot(t, [squeeze(S(1,2,:))'; qvdv(2,:)]); scatter(obj.flatOutputs{2}.getTimeIndicesByType(waypointTypeEnum.position), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.position),scatterSize); title('S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,3); hold on; plot(t, [squeeze(S(1,3,:))'; qvdv(3,:)]); scatter(obj.flatOutputs{3}.getTimeIndicesByType(waypointTypeEnum.position), obj.flatOutputs{3}.getValuesByType(waypointTypeEnum.position),scatterSize); title('S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,4); hold on; plot(t, [squeeze(S(2,1,:))'; qvdv(5,:)]); scatter(obj.flatOutputs{1}.getTimeIndicesByType(waypointTypeEnum.velocity), obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.velocity),scatterSize); title('dS_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,5); hold on; plot(t, [squeeze(S(2,2,:))'; qvdv(6,:)]); scatter(obj.flatOutputs{2}.getTimeIndicesByType(waypointTypeEnum.velocity), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.velocity),scatterSize); title('dS_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,6); hold on; plot(t, [squeeze(S(2,3,:))'; qvdv(7,:)]); scatter(obj.flatOutputs{3}.getTimeIndicesByType(waypointTypeEnum.velocity), obj.flatOutputs{3}.getValuesByType(waypointTypeEnum.velocity),scatterSize); title('dS_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,7); hold on; plot(t, [squeeze(S(3,1,:))'; qvdv(9,:)]); scatter(obj.flatOutputs{1}.getTimeIndicesByType(waypointTypeEnum.acceleration), obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.acceleration),scatterSize); title('ddS_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,8); hold on; plot(t, [squeeze(S(3,2,:))'; qvdv(10,:)]); scatter(obj.flatOutputs{2}.getTimeIndicesByType(waypointTypeEnum.acceleration), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.acceleration),scatterSize); title('ddS_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,9); hold on; plot(t, [squeeze(S(3,3,:))'; qvdv(11,:)]); scatter(obj.flatOutputs{3}.getTimeIndicesByType(waypointTypeEnum.acceleration), obj.flatOutputs{3}.getValuesByType(waypointTypeEnum.acceleration),scatterSize); title('ddS_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,10); hold on; plot(t, [squeeze(S(4,1,:))])'; title('d3S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,11); hold on; plot(t, [squeeze(S(4,2,:))])';  title('d3S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,12); hold on; plot(t, [squeeze(S(4,3,:))])'; title('d3S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,13); hold on; plot(t, [squeeze(S(5,1,:))])'; title('d4S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,14); hold on; plot(t, [squeeze(S(5,2,:))])';  title('d4S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,15); hold on; plot(t, [squeeze(S(5,3,:))])'; title('d4S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,16); hold on; plot(t, [squeeze(S(6,1,:))])'; title('d5S_1'); line(segmentLinesX{1}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,17); hold on; plot(t, [squeeze(S(6,2,:))])';  title('d5S_2'); line(segmentLinesX{2}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);
                subplot(6,3,18); hold on; plot(t, [squeeze(S(6,3,:))])'; title('d5S_3'); line(segmentLinesX{3}, ylim,'Color',[0 0.4470 0.7410],'LineStyle',':'); xlim([0, obj.tend]);

                % Synchronise scaling of related plots
                linkaxes([subplot(6,3,1) subplot(6,3,4) subplot(6,3,7)],'x');
                linkaxes([subplot(6,3,2) subplot(6,3,5) subplot(6,3,8)],'x');
                linkaxes([subplot(6,3,3) subplot(6,3,6) subplot(6,3,9)],'x');
            end
        end
        
        function plotCartesianTrajectory(obj)
            
            [qvdv,u,S,t] = obj.getStateTrajectories(0.01); 
            
            % Cartesian plot
            figure;
            plot(qvdv(1,:), qvdv(2,:));
            hold on
            plot(squeeze(S(1,1,:)), squeeze(S(1,2,:)));
            axis equal
            scatter(obj.flatOutputs{1}.getValuesByType(waypointTypeEnum.position), obj.flatOutputs{2}.getValuesByType(waypointTypeEnum.position));            
            xlabel('x (m)');
            ylabel('y (m)');
            legend('Polynomial Trajectory', 'State Trajectory', 'Waypoints');
        end
        
    end
end

