classdef trapezoidalTrajectoryGenerator
    %TRAPEZOIDALTRAJECTORYGENERATOR A generic trapezoidal trajectory
    %generation class for generating synchronised trajectories in n
    %dimensions between m waypoints.
    
    properties
        numDim
        numWaypoints
        w % waypoints
%         x % segment positions at start and end
%         v % segment velocities at start and end
        a % accelerations between waypoints
        dt % segment durations
        vMax
        aMax
    end
    
    methods
        function obj = trapezoidalTrajectoryGenerator(waypoints, vMax, aMax)
            
            obj.numDim = size(waypoints,1);
            obj.numWaypoints = size(waypoints,2);
            obj.w = waypoints;
            obj.vMax = vMax;
            obj.aMax = aMax;
%             obj.v = zeros(obj.numDim, obj.numWaypoints);
            obj.a = zeros(obj.numDim, obj.numWaypoints-1); 
            obj.dt = zeros(obj.numDim, obj.numWaypoints-1);            
            
        end
        
        function NLPfun = generateNonlinearOptimistionFunctions(obj)
            
            nd = obj.numDim;
            ns = obj.numWaypoints-1;
            
            a = sym('a',[nd,ns]);
            dt = sym('dt',[nd,ns]);
            w = sym('w',[nd,ns]);
            
            for i=1:nd
                v
                for j=1:ns
                    
                end                
            end
            
        end
        
        function nonlinearTrapezoidalOptimisation(obj)
            % Optimises n synchronised trajectories for minimum time, under
            % |a|<aMax constraints, and with either no constant velocity
            % segment, or a segment with constant velocity +-vMax.
        end
        
        
        
        function calculateUnsynchronisedMinimumTimeTrajectories(obj)
            % Generates the minimum time trapezoidal trajectory in 
            % a single dimension through n waypoints under velocity
            % and acceleration constraints.
            
            for n=1:obj.numDim
                      
                % Get waypoints for just this dimension
                wi = obj.w(n,:);

                dt = [];
                wcheck = wi(1);
                dwi = 0;%obj.waypoints(1).val(2); % Functionality to be added if needed
                dwicheck = dwi;
                segAccel = [];

                i=1;
                % Trajectories are built by producing trapezoidal profiles over
                % sets of monotonic position waypoints
                while i<numel(wi)                
                    % Find next inflection waypoint
                    for nextInflect=i:numel(wi)
                        if ~(all(diff(wi(i:nextInflect))>=0) || all(diff(wi(i:nextInflect))<=0))
                            nextInflect = nextInflect-1;
                            break;
                        end
                    end

                    % Direction of this trapezoid
                    trapSign = sign(wi(nextInflect)-wi(i));

                    % Catch stationary trajectory case
                    if trapSign == 0
                        trapSign = 1;
                    end

                    % Is there sufficient distance in this set of monotonic
                    % waypoints to reach vMax?
                    if abs(wi(i) - wi(nextInflect)) > obj.vMax^2/obj.aMax

                        % If yes, then calculate total required timing for this
                        % monotonic section, and place interior waypoints
                        % wherever they lie on this trajectory.

                        t_a = obj.vMax/obj.aMax;
                        t_v = (abs(wi(i) - wi(nextInflect)) - obj.vMax^2/obj.aMax) / obj.vMax;
                        t_tot = 2*t_a + t_v;

                        % Calculate trapezoid dx's
                        dx1 = trapSign * 0.5 * obj.aMax * t_a^2;
                        dx2 = trapSign * obj.vMax * t_v;
                        dx3 = dx1;

                        if dx1+dx2+dx3 ~= wi(nextInflect) - wi(i)
                            error('Something went wrong');
                        end                    

                        for j=i:(nextInflect-1)
                            baseIdx = (j-1)*3+1; % Precalculate the base index for referencing this trio of segments

                            if abs(wi(j+1)-wi(i)) <= abs(dx1 + 1e-10)
                                % Waypoint j+1 lies within the acceleration
                                % section of the trapezoidal profile.
                                durations(baseIdx) = -(dwi(baseIdx) - sqrt(dwi(baseIdx)^2 + 2*obj.aMax*abs(wi(j+1)-wi(j))))/obj.aMax;
                                segAccel(baseIdx) = obj.aMax * trapSign;
                                dwi(baseIdx+1) = dwi(baseIdx) + durations(baseIdx)*segAccel(baseIdx);

                                durations(baseIdx + (1:2)) = 0;
                                segAccel(baseIdx+1) = 0;
                                segAccel(baseIdx+2) = -trapSign * obj.aMax; % Should be moot
                                dwi(baseIdx+(2:3)) = dwi(baseIdx+1);

                            elseif abs(wi(j+1)-wi(nextInflect)) > abs(dx3)
                                % Waypoint j lies within the constant velocity
                                % section of the trapezoidal profile.

                                % Calculate any required acceleration to reach
                                % vMax
                                if abs(dwi(baseIdx)) ~= obj.vMax
                                    durations(baseIdx) = abs(dwi(baseIdx)-obj.vMax) / obj.aMax;
                                else
                                    durations(baseIdx) = 0;
                                end

                                segAccel(baseIdx) = trapSign * obj.aMax;
                                dwi(baseIdx+1) = dwi(baseIdx) + durations(baseIdx)*segAccel(baseIdx);

                                % Calculate time required in constant velocity
                                % segment to reach position constraint
                                dxj1 = dwi(baseIdx)*durations(baseIdx) + 0.5*segAccel(baseIdx)*durations(baseIdx)^2;
                                durations(baseIdx+1) = (wi(j+1)-wi(j) - dxj1) / dwi(baseIdx+1);
                                segAccel(baseIdx+1) = 0;
                                dwi(baseIdx+2) = dwi(baseIdx+1) + durations(baseIdx+1)*segAccel(baseIdx+1);

                                % No deceleration required
                                durations(baseIdx+2) = 0;
                                segAccel(baseIdx+2) = 0;
                                dwi(baseIdx+3) = dwi(baseIdx+2);

                            elseif abs(wi(j+1)-wi(nextInflect)) <= abs(dx3)
                                % Waypoint j lies within the deceleration
                                % section of the trapezoidal profile.

                                % Calculate any required acceleration to reach
                                % vMax. Should only occur if these waypoint
                                % span all three trapezoid sections, otherwise
                                % should be zero.
                                if abs(wi(j)-wi(nextInflect)) > abs(dx3)
                                    durations(baseIdx) = (obj.vMax - abs(dwi(baseIdx))) / obj.aMax;
                                else
                                    durations(baseIdx) = 0;
                                end
                                segAccel(baseIdx) = trapSign * obj.aMax;
                                dwi(baseIdx+1) = dwi(baseIdx) + durations(baseIdx)*segAccel(baseIdx);

                                % Calculate any required constant velocity
                                % period
                                if abs(wi(j)-wi(nextInflect)) > abs(dx3)
                                    dxj1 = dwi(baseIdx)*durations(baseIdx) + 0.5*segAccel(baseIdx)*durations(baseIdx)^2;
                                    dxj2 = wi(nextInflect)-wi(j) - dxj1 - dx3;
                                    durations(baseIdx+1) = abs(dxj2) / obj.vMax;
                                else
                                    durations(baseIdx+1) = 0;
                                end
                                segAccel(baseIdx+1) = 0;
                                dwi(baseIdx+2) = dwi(baseIdx+1) + durations(baseIdx+1)*segAccel(baseIdx+1);


                                dxj1 = abs(dwi(baseIdx))*durations(baseIdx) + 0.5*segAccel(baseIdx)*durations(baseIdx)^2;
                                dxj2 = dwi(baseIdx+2)*durations(baseIdx+1);

                                % Calculate segment duration to decelerate to
                                % waypoint
                                segAccel(baseIdx+2) = -trapSign*obj.aMax;
                                durationsSols = [-(dwi(baseIdx+2) + sqrt(dwi(baseIdx+2)^2 + 2*segAccel(baseIdx+2)*(wi(j+1)-wi(j)-dxj1-dxj2)))/segAccel(baseIdx+2);
                                    -(dwi(baseIdx+2) - sqrt(dwi(baseIdx+2)^2 + 2*segAccel(baseIdx+2)*(wi(j+1)-wi(j)-dxj1-dxj2)))/segAccel(baseIdx+2)];
                                durations(baseIdx+2) = min(abs(real(durationsSols))); % We want the first (in time) solution 
                                dwi(baseIdx+3) = dwi(baseIdx+2) + segAccel(baseIdx+2)*durations(baseIdx+2);
                            else
                                error('Something went wrong');
                            end

                            % Generate check waypoint vector
                            for k=baseIdx:baseIdx+2
                                dwicheck(k+1) = dwicheck(k) + segAccel(k)*durations(k);
                                wcheck(k+1) = wcheck(k) + dwicheck(k)*durations(k) + 0.5*segAccel(k)*durations(k)^2;
                            end

                            if any(abs(wcheck(1:3:end) - wi(1:1+(numel(wcheck)-1)/3)) >= 1e-10)
                                error('Trapezoid does not match waypoints');
                            end
                        end
                    else
                        % If not, then recalculate vMax, set the total
                        % duration of the monotonic section, then place
                        % interior waypoints as above.

                        t_a = sqrt(abs(wi(nextInflect) - wi(i)) * obj.aMax)/obj.aMax;
                        %t_v = 0;
                        vMaxNew = t_a*obj.aMax;

                        % Calculate trapezoid dx's
                        dx1 = trapSign * 0.5 * obj.aMax * t_a^2;
                        dx2 = 0;
                        dx3 = dx1;

                        if abs((dx1+dx2+dx3) - (wi(nextInflect) - wi(i))) > 1e-10
                            error('Something went wrong');
                        end                    

                        for j=i:(nextInflect-1)
                            baseIdx = (j-1)*3+1; % Precalculate the base index for referencing this trio of segments

                            if abs(wi(j+1)-wi(i)) <= abs(dx1 + 1e-10)

                                segAccel(baseIdx) = obj.aMax * trapSign;

                                % Waypoint j+1 lies within the acceleration
                                % section of the trapezoidal profile.
                                durationsSols = [-(dwi(baseIdx) + sqrt(dwi(baseIdx)^2 + 2*segAccel(baseIdx)*(wi(j+1)-wi(j))))/segAccel(baseIdx);
                                    -(dwi(baseIdx) - sqrt(dwi(baseIdx)^2 + 2*segAccel(baseIdx)*(wi(j+1)-wi(j))))/segAccel(baseIdx)];
                                if any(abs(imag(durationsSols)) > 0)
                                    if all(abs(imag(durationsSols)) < 1e-6)
                                        durationsSols = real(durationsSols);
                                    else
                                        error('Substantially complex duration');
                                    end
                                end
                                durations(baseIdx) = min(abs(durationsSols)); % We want the first (in time) solution 

                                dwi(baseIdx+1) = dwi(baseIdx) + durations(baseIdx)*segAccel(baseIdx);

                                durations(baseIdx + (1:2)) = 0;
                                segAccel(baseIdx+1) = 0;
                                segAccel(baseIdx+2) = -trapSign * obj.aMax; % Should be moot
                                dwi(baseIdx+(2:3)) = dwi(baseIdx+1);

                            elseif abs(wi(j+1)-wi(nextInflect)) <= abs(dx3)
                                % Waypoint j lies within the deceleration
                                % section of the trapezoidal profile.

                                % Calculate any required acceleration to reach
                                % vMax. Should only occur if these waypoint
                                % span all three trapezoid sections, otherwise
                                % should be zero.
                                if abs(wi(j)-wi(nextInflect)) > abs(dx3)
                                    durations(baseIdx) = abs(dwi(baseIdx)-vMaxNew) / obj.aMax;
                                else
                                    durations(baseIdx) = 0;
                                end
                                segAccel(baseIdx) = trapSign * obj.aMax;
                                dwi(baseIdx+1) = dwi(baseIdx) + durations(baseIdx)*segAccel(baseIdx);

                                % Constant velocity period of 0
                                durations(baseIdx+1) = 0;
                                segAccel(baseIdx+1) = 0;
                                dwi(baseIdx+2) = dwi(baseIdx+1) + durations(baseIdx+1)*segAccel(baseIdx+1);


                                dxj1 = abs(dwi(baseIdx))*durations(baseIdx) + 0.5*segAccel(baseIdx)*durations(baseIdx)^2;

                                % Calculate segment duration to decelerate to
                                % waypoint
                                segAccel(baseIdx+2) = -trapSign*obj.aMax;
                                durationsSols = [-(dwi(baseIdx+2) + sqrt(dwi(baseIdx+2)^2 + 2*segAccel(baseIdx+2)*(wi(j+1)-wi(j)-dxj1)))/segAccel(baseIdx+2);
                                    -(dwi(baseIdx+2) - sqrt(dwi(baseIdx+2)^2 + 2*segAccel(baseIdx+2)*(wi(j+1)-wi(j)-dxj1)))/segAccel(baseIdx+2)];
                                if any(abs(imag(durationsSols)) > 0)
                                    if all(abs(imag(durationsSols)) < 1e-6)
                                        durationsSols = real(durationsSols);
                                    else
                                        error('Substantially complex duration');
                                    end
                                end
                                durations(baseIdx+2) = min(abs(durationsSols)); % We want the first (in time) solution 
                                dwi(baseIdx+3) = dwi(baseIdx+2) + segAccel(baseIdx+2)*durations(baseIdx+2);
                            else
                                error('It should not have been possible to end up here');
                            end

                            % Generate check waypoint vector
                            for k=baseIdx:baseIdx+2
                                dwicheck(k+1) = dwicheck(k) + segAccel(k)*durations(k);
                                wcheck(k+1) = wcheck(k) + dwicheck(k)*durations(k) + 0.5*segAccel(k)*durations(k)^2;
                            end

                            if any(abs(wcheck(1:3:end) - wi(1:1+(numel(wcheck)-1)/3)) >= 1e-10)
                                error('Trapezoid does not match waypoints');
                            end
                        end
                    end

                    i=nextInflect;
                end
                
                % Save results to class members
                obj.a(n,:) = segAccel;
                obj.v(n,:) = dwicheck;
                obj.x(n,:) = wcheck;
                obj.dt(n,:) = durations;
            end
        end
        
        function [t,x,v,a] = getTrajectories(obj, tStep)
            % Generates the trajectories resulting from segAccel and dt
            
            for i=1:obj.numDim
                a{i} = zeros(sum(obj.dt(i,:)/tStep)+1, 1);
                t{i} = zeros(sum(obj.dt(i,:)/tStep)+1, 1);
                for j=1:(obj.numWaypoints-1)
                    a = [a repmat(obj.a(i,j), [obj.dt(i,j)/tStep, 1])];
                    t = [t 0:tStep:(obj.dt(i,j)-tStep)];
                end
            end
        end
        
        function plot(obj)
            % Plots all trapezoidal trajectories
            
        end
    end
end

