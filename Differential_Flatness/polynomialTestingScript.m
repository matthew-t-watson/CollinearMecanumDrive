
close all;
clearvars -except modelData trajectory

% Ensure these are installed and on the path
addpath('../nestedSortStruct');
addpath(genpath('../YALMIP-master/'));
addpath(genpath('../SeDuMi_1_3'));
addpath(genpath('../matlab2tikz'));

% Optionally use MOSEK solvers
rmpath('C:\Program Files\Mosek\9.1\toolbox\r2015a');
% addpath('C:\Program Files\Mosek\9.1\toolbox\r2015a');


% Derive modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(true);
end

%% Setup
% Configure xy polynomials
config(1).polyDegree = 9;       % Degree of 1st and 3rd polynomials between waypoints
config(1).polyDegreeVelSeg = 9; % Degree of middle polynomial between waypoints
config(1).derivToMin = 5;       % Derivative to least-squares minimise
config(1).conDerivDeg = 4;      % Derivative to which to enforce continuity

config(2) = config(1); % Make xy configs equal

% Configure yaw polynomials
config(3).polyDegree = 7;
config(3).polyDegreeVelSeg = 7; 
config(3).derivToMin = 4;
config(3).conDerivDeg = 3; 

if ~exist('trajectory', 'var')
    trajectory = trajectoryClass(modelData, config);
else
    if ~isequal(trajectory.config, config)
        trajectory = trajectoryClass(modelData, config);
    else
        trajectory.reinitialise;
    end
end


%% Specify waypoints
waypointSet = 4;
switch(waypointSet)  
    case 1
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(10,10,20*pi,4,'boundary');
    case 2
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(0,0.6,pi/2,2,'position');
        trajectory.addWaypoint(0,1,pi/2,3,'position');
        trajectory.addWaypoint(0,1.4,pi/2,4,'position');
        trajectory.addWaypoint(0,2,0,6,'boundary');
    case 3
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(1,1,0,1,'position');
        trajectory.addWaypoint(2,1,0,2,'position');
        trajectory.addWaypoint(3,1,0,3,'position');
        trajectory.addWaypoint(4,2,0,4,'boundary');
    case 4 % Pirouetting square
%         trajectory.addWaypoint(0,0,0*pi,0,'boundary');
%         trajectory.addWaypoint(0,1.5,1*pi,2,'position');
%         trajectory.addWaypoint(1.5,1.5,2*pi,4,'position');
%         trajectory.addWaypoint(1.5,0,3*pi,6,'position');
%         trajectory.addWaypoint(0,0,4*pi,8,'position');
%         trajectory.addWaypoint(0,1.5,5*pi,10,'position');
%         trajectory.addWaypoint(1.5,1.5,6*pi,12,'position');
%         trajectory.addWaypoint(1.5,0,7*pi,14,'position');
%         trajectory.addWaypoint(0,0,8*pi,16,'boundary');
        trajectory.addWaypoint(0,0,0*pi,0,'boundary');
        trajectory.addWaypoint(0,1.5,1.5*pi,2,'position');
        trajectory.addWaypoint(1.5,1.5,3*pi,4,'position');
        trajectory.addWaypoint(1.5,0,4.5*pi,6,'position');
        trajectory.addWaypoint(0,0,6*pi,8,'boundary');
    case 5 % Pirouetting square reverse
        trajectory.addWaypoint(0,0,8*pi,0,'boundary');
        trajectory.addWaypoint(0,1.5,7*pi,2,'position');
        trajectory.addWaypoint(1.5,1.5,6*pi,4,'position');
        trajectory.addWaypoint(1.5,0,5*pi,6,'position');
        trajectory.addWaypoint(0,0,4*pi,8,'position');
        trajectory.addWaypoint(0,1.5,3*pi,10,'position');
        trajectory.addWaypoint(1.5,1.5,2*pi,12,'position');
        trajectory.addWaypoint(1.5,0,1*pi,14,'position');
        trajectory.addWaypoint(0,0,0*pi,16,'boundary');
    case 6
        rng(4);
        trajectory.addWaypoint(0,0,0,0,'boundary');
        newWaypoint = [0 0 0];
        numWaypoints = 8;
        for i=1:numWaypoints
%             newWaypoint = newWaypoint + [2 2 10].*[(2*rand-1),(2*rand-1),(2*rand-1)];
%             newWaypoint = newWaypoint + [2*(rand),2*(rand),2*(rand)];
            newWaypoint = [(randn),(randn),2*(randn)];
            if i < numWaypoints
                trajectory.addWaypoint(newWaypoint(1),newWaypoint(2),newWaypoint(3),i,'position');
            else
                trajectory.addWaypoint(newWaypoint(1),newWaypoint(2),newWaypoint(3),i,'boundary');
            end
        end
        
    case 7
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(0.2,1,0,2,'position');
        trajectory.addWaypoint(-1,-1,0,4,'position');
        trajectory.addWaypoint(0,0,0,6,'boundary');
        
    case 8 % Gap navigation
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(0.4,0,0,1,'position');
        trajectory.addWaypoint(1.2,1,0,2,'position');
        trajectory.addWaypoint(0.4,0,0,3,'position');
        trajectory.addWaypoint(-0.4,0,0,4,'position');
        trajectory.addWaypoint(-1.2,-1,0,5,'position');
        trajectory.addWaypoint(-0.4,0,0,6,'position');
        trajectory.addWaypoint(0,0,0,7,'boundary');
        
    case 9 % Circle
        n=10;
        r = 1;
        for i=0:n
            trajectory.addWaypoint(r*cos(2*pi*i/n),r*sin(2*pi*i/n),0,i,'boundary');            
        end
    case 10
        trajectory.addWaypoint(0,1,0,0,'boundary');
        trajectory.addWaypoint(0.25,-0.25,0,1,'position');
        trajectory.addWaypoint(0.5,0.25,0,2,'position');
        trajectory.addWaypoint(0.75,-0.25,0,3,'position');
        trajectory.addWaypoint(1,0.25,0,4,'position');
        trajectory.addWaypoint(1.25,-0.25,0,5,'position');
        trajectory.addWaypoint(1.5,0.25,0,6,'position');
        trajectory.addWaypoint(1.75,-1,0,7,'boundary');      
    case 11 % Pirouetting square, starting in center
        trajectory.addWaypoint(0,0,0*pi,0,'boundary');
        trajectory.addWaypoint(-0.75,0.75,1*pi,1,'position');
        trajectory.addWaypoint(0.75,0.75,2*pi,2,'position');
        trajectory.addWaypoint(0.75,-0.75,3*pi,3,'position');
        trajectory.addWaypoint(-0.75,-0.75,4*pi,4,'position');
        trajectory.addWaypoint(-0.75,0.75,5*pi,5,'position');
        trajectory.addWaypoint(0.75,0.75,6*pi,6,'position');
        trajectory.addWaypoint(0.75,-0.75,7*pi,7,'position');
        trajectory.addWaypoint(0,0,7*pi,8,'position');
        trajectory.addWaypoint(0,0,0*pi,9,'boundary');
    case 12 % Pirouetting square, starting in center, constant vx
        trajectory.addWaypoint(0,0,0*pi,0,'boundary');
        trajectory.addWaypoint(-0.75,0.75,-0.75*pi,1,'position');
        trajectory.addWaypoint(0.75,0.75,-1.25*pi,2,'position');
        trajectory.addWaypoint(0.75,-0.75,-1.75*pi,3,'position');
        trajectory.addWaypoint(-0.75,-0.75,-2.25*pi,4,'position');
        trajectory.addWaypoint(-0.75,0.75,-2.75*pi,5,'position');
        trajectory.addWaypoint(0.75,0.75,-3.25*pi,6,'position');
        trajectory.addWaypoint(0.75,-0.75,-3.75*pi,7,'position');
        trajectory.addWaypoint(0,0,-4.25*pi,8,'position');
        trajectory.addWaypoint(0,0,0*pi,9,'boundary');
    case 13 % Pirouetting square, starting in center, constant vy
        trajectory.addWaypoint(0,0,0*pi,0,'boundary');
        trajectory.addWaypoint(-0.75,0.75,-0.25*pi,1,'position');
        trajectory.addWaypoint(0.75,0.75,-0.75*pi,2,'position');
        trajectory.addWaypoint(0.75,-0.75,-1.25*pi,3,'position');
        trajectory.addWaypoint(-0.75,-0.75,-1.75*pi,4,'position');
        trajectory.addWaypoint(-0.75,0.75,-2.25*pi,5,'position');
        trajectory.addWaypoint(0.75,0.75,-2.75*pi,6,'position');
        trajectory.addWaypoint(0.75,-0.75,-3.25*pi,7,'position');
        trajectory.addWaypoint(0,0,-3.75*pi,8,'position');
        trajectory.addWaypoint(0,0,0*pi,9,'boundary');
    case 14 % Square
        l=1;
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(0,l,0,2,'position');
        trajectory.addWaypoint(l,l,0,4,'position');
        trajectory.addWaypoint(l,0,0,6,'position');
        trajectory.addWaypoint(0,0,0,8,'position');
        trajectory.addWaypoint(0,l,0,10,'position');
        trajectory.addWaypoint(l,l,0,12,'position');
        trajectory.addWaypoint(l,0,0,14,'position');
        trajectory.addWaypoint(0,0,0,16,'boundary');
end


verbosity = 0;

%% Set velocity + acceleration constraints
trajectory.setConstraints(1,0.75,6,4);
% trajectory.setConstraints(1,1,4,2);
% trajectory.setConstraints(1,1,6,10);

%% Perform timing optimisation
trajectory.addConstantVelocityWaypoints;

trajectory.optimiseSectionsTimingsIncVelocityConstraints; % Global optimisation of polynomial segment timings
% trajectory.optimiseSectionTimingsQRDecomp(verbosity); % Perform gradient descent optimisation of timings w/o velocity constraints
% trajectory.optimiseTrapezoidalTimings(1);
% trajectory.optimiseTrapezoidalTimingsSubsegmentCoherence(1);
% trajectory.trimWaypoints;
trajectory.plotFlatOutputs(false, true);

%% Perform Polynomial Coefficient Optimistion:
% QR_decomp - QP method using quadprog or QR decomposition
% QP_YALMIP - QP method using YALMIP 
% SOS - Bounded SOS acceleration constraints
% recursive_vel_ineqs_YALMIP - Recursively added velocity inequalities on QP
% gridded_vel_ineqs_YALMIP - Gridded velocity inequalities on QP
% recursive_vel_ineqs_fast - Recursively constrained QP, fast method used for gradient descent optimisation of timings
[~,~,solveTimes] = trajectory.optimiseFlatOutputs(optimisationTypeEnum.SOS_velocity_circular, verbosity);

%% Plotting
trajectory.plotFlatOutputs(false, true);
trajectory.plotStateTrajectories;
trajectory.plotCartesianTrajectory;

%% Generate outputs for simulink 
[pvdv,u,S,t] = trajectory.getStateTrajectories(0.01);
pv0 = pvdv(1:8,1);
tend = trajectory.tend;
pvdv(:,end) = pvdv(:,end) .* (abs(pvdv(:,end))>1e-2); % Ensures end velocities are zero if they are supposed to be
u(:,end) = u(:,end) .* (abs(u(:,end))>1e-2);
traj.pvdv = timeseries(pvdv,t);
traj.u = timeseries(u,t);


% Calculate feedback gain K for simulink simulation using LQR
Q = diag([1 1 1 0.1 0 0 0 0]);
R = 0.5*eye(4);
K = lqr(c2d(modelData.linsys, 0.001),Q,R);

% Calculate feedback gain k with integral action for simulink simulation
Q = diag([1 1 1 1 1 1 0 0 0 0 0]);
R = 1*eye(4);
K_int = lqr([zeros(3,3) eye(3) zeros(3,5); zeros(8,3) modelData.linsys.A], [zeros(3,4); modelData.linsys.B], Q, R);


