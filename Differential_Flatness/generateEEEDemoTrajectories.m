
close all;
clearvars -except modelData trajectory


%% Ensure we are in the correct path
% cd('D:\Google_Drive\Matlab\CMD');

addpath('../nestedSortStruct');
addpath(genpath('../YALMIP-master/'));
addpath(genpath('../SeDuMi_1_3'));
addpath(genpath('../matlab2tikz'));

rmpath('D:\Program Files\Mosek\8\toolbox\r2014a');
% addpath('D:\Program Files\Mosek\8\toolbox\r2014a');


% Create modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(true);
end

%% Polynomial degree requirements
% It appears degree requirements change when constant velocity segments are added. For single boundary to boundary
% polynomials its found that deg(p)>=2*conDerivDeg+1, whereas with constant velocity segments it is found that
% deg(p)>=2*conDerivDeg-1. This makes sense, as extra DoF are added by making intermediary waypoints free.

%% Setup
config(1).polyDegree = 9;
config(1).polyDegreeVelSeg = 9; 
config(1).derivToMin = 5;
config(1).conDerivDeg = 4; 

config(2) = config(1);

config(3).polyDegree = 7;
config(3).polyDegreeVelSeg = 7; 
config(3).derivToMin = 4;
config(3).conDerivDeg = 3; 

numWaypointSets = 11;

% scale factor
% s = 0.9; % arena
s = 0.25; % EEE

for i=1:numWaypointSets
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
    waypointSet = i;
    switch(waypointSet)  
        case 1
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0,-s,0,1,'position');
            trajectory.addWaypoint(0,s,0,2,'position');
            trajectory.addWaypoint(0,0,0,5,'boundary');
            fileName = 'forward_back';
        case 2
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(-s,0,0,1,'position');
            trajectory.addWaypoint(s,0,0,2,'position');
            trajectory.addWaypoint(0,0,0,5,'boundary');
            fileName = 'sideways';
        case 3
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0.5*-s,0.5*-s,0,1,'position');
            trajectory.addWaypoint(-s,0,0,2,'position');
            trajectory.addWaypoint(0.5*-s,0.5*s,0,2.5,'position');
            trajectory.addWaypoint(0.5*s,0.5*-s,0,3,'position');
            trajectory.addWaypoint(s,0,0,3.5,'position');
            trajectory.addWaypoint(0.5*s,0.5*s,0,4,'position');
            trajectory.addWaypoint(0,0,0,5,'boundary');
            fileName = 'figure8_1';
        case 4
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0.5*-s,0.5*-s,-pi/2,1,'position');
            trajectory.addWaypoint(-s,0,-pi,1.5,'position');
            trajectory.addWaypoint(0.5*-s,0.5*s,-3*pi/2,2,'position');
            trajectory.addWaypoint(0,0,-7*pi/4,2.5,'position');
            trajectory.addWaypoint(0.5*s,0.5*-s,-3*pi/2,3,'position');
            trajectory.addWaypoint(s,0,-pi,3.5,'position');
            trajectory.addWaypoint(0.5*s,0.5*s,-pi/2,4,'position');
            trajectory.addWaypoint(0,0,0,5,'boundary');
            fileName = 'figure8_2';
        case 5
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0.5*-s,0.5*-s,0,1,'position');
            trajectory.addWaypoint(-s,0,-pi/2,1.5,'position');
            trajectory.addWaypoint(0.5*-s,0.5*s,-pi,2,'position');
            trajectory.addWaypoint(0,0,-5*pi/4,2.5,'position');
            trajectory.addWaypoint(0.5*s,0.5*-s,-pi,3,'position');
            trajectory.addWaypoint(s,0,-pi/2,3.5,'position');
            trajectory.addWaypoint(0.5*s,0.5*s,0,4,'position');
            trajectory.addWaypoint(0,0,0,5,'boundary');
            fileName = 'figure8_3';
        case 6
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0,-s,-pi,2,'position');
            trajectory.addWaypoint(0,s,pi,4,'position');
            trajectory.addWaypoint(0,0,0,6,'boundary');
            fileName = 'pirouette';
        case 7
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0,-s,0,2,'position');
            trajectory.addWaypoint(0,-0.5*s,pi/2,3,'position');
            trajectory.addWaypoint(0,0,pi/2,3.5,'position');
            trajectory.addWaypoint(0,0.5*s,pi/2,4,'position');
            trajectory.addWaypoint(0,s,0,5,'position');
            trajectory.addWaypoint(0,0,0,6,'boundary');
            fileName = 'gap1';

        case 8 % Gap navigation
            trajectory.addWaypoint(0,0,0,0,'boundary');
            trajectory.addWaypoint(0.4*s,0,0,1,'position');
            trajectory.addWaypoint(1.2*s,s,0,2,'position');
            trajectory.addWaypoint(0.4*s,0,0,3,'position');
            trajectory.addWaypoint(-0.4*s,0,0,4,'position');
            trajectory.addWaypoint(-1.2*s,-s,0,5,'position');
            trajectory.addWaypoint(-0.4*s,0,0,6,'position');
            trajectory.addWaypoint(0,0,0,7,'boundary');
            fileName = 'gap2';

        case 9 % Pirouetting square, starting in center
            trajectory.addWaypoint(0,0,0*pi,0,'boundary');
            trajectory.addWaypoint(-0.75*s,0.75*s,0.75*pi,1,'position');
            trajectory.addWaypoint(0.75*s,0.75*s,1.5*pi,2,'position');
            trajectory.addWaypoint(0.75*s,-0.75*s,2.25*pi,3,'position');
            trajectory.addWaypoint(-0.75*s,-0.75*s,3*pi,4,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,3.75*pi,5,'position');
            trajectory.addWaypoint(0.75*s,0.75*s,4.5*pi,6,'position');
            trajectory.addWaypoint(0.75*s,-0.75*s,5.25*pi,7,'position');
            trajectory.addWaypoint(0,0,6*pi,8,'boundary');
            fileName = 'circle';

        case 10 % Pirouetting square, starting in center, constant vx
            trajectory.addWaypoint(0,0,0*pi,0,'boundary');
            %trajectory.addWaypoint(0,0.75*s,0.75*pi,1,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,1.25*pi,2,'position');
            trajectory.addWaypoint(-0.75*s,-0.75*s,1.75*pi,3,'position');
            trajectory.addWaypoint(0.75*s,-0.75*s,2.25*pi,4,'position');
            trajectory.addWaypoint(0.75*s,0.75*s,2.75*pi,5,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,3.25*pi,6,'position');
            trajectory.addWaypoint(-0.75*s,-0.75*s,3.75*pi,7,'position');
            trajectory.addWaypoint(0.75*s,-0.75*s,4.25*pi,8,'position');
            trajectory.addWaypoint(0.75*s,0.75*s,4.75*pi,9,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,5.25*pi,10,'position');
            %trajectory.addWaypoint(-0.75*s,0,5.75*pi,11,'position');
            trajectory.addWaypoint(0,0,6*pi,12,'boundary');
            fileName = 'circle2';

        case 11 % Pirouetting square, starting in center, constant vy
            trajectory.addWaypoint(0,0,0*pi,0,'boundary');
            %trajectory.addWaypoint(0,0.75*s,0.25*pi,1,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,0.75*pi,2,'position');
            trajectory.addWaypoint(-0.75*s,-0.75*s,1.25*pi,3,'position');
            trajectory.addWaypoint(0.75*s,-0.75*s,1.75*pi,4,'position');
            trajectory.addWaypoint(0.75*s,0.75*s,2.25*pi,5,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,2.75*pi,6,'position');
            trajectory.addWaypoint(-0.75*s,-0.75*s,3.25*pi,7,'position');
            trajectory.addWaypoint(0.75*s,-0.75*s,3.75*pi,8,'position');
            trajectory.addWaypoint(0.75*s,0.75*s,4.25*pi,9,'position');
            trajectory.addWaypoint(-0.75*s,0.75*s,4.75*pi,10,'position');
            %trajectory.addWaypoint(-0.75*s,0,5.25*pi,11,'position');
            trajectory.addWaypoint(0,0,6*pi,12,'boundary');
            fileName = 'circle3';
    end


    verbosity = 1;

    %% Set constraints
%     trajectory.setConstraints(1,0.75,4,2); % Arena demos
    trajectory.setConstraints(1,0.75,4,2); % EEE demos

    %% Perform timing optimisation
    trajectory.addConstantVelocityWaypoints;

    trajectory.optimiseSectionsTimingsIncVelocityConstraints;
    % trajectory.optimiseSectionTimingsQRDecomp(verbosity); % Perform gradient descent optimisation of timings w/o velocity constraints
%     trajectory.optimiseTrapezoidalTimings(1);
%     trajectory.trimWaypoints;
%     trajectory.plotFlatOutputs(false, true);

    %% Optimistion Methods:
    % QR_decomp - QP method using quadprog or QR decomposition
    % QP_YALMIP - QP method using YALMIP 
    % SOS - Bounded SOS acceleration constraints
    % recursive_vel_ineqs_YALMIP - Recursively added velocity inequalities on QP
    % gridded_vel_ineqs_YALMIP - Gridded velocity inequalities on QP
    % recursive_vel_ineqs_fast - Recursively constrained QP, fast method used for gradient descent optimisation of timings
    method = optimisationTypeEnum.recursive_vel_ineqs_fast;
    trajectory.optimiseFlatOutputs(method, verbosity);

    trajectory.writeDiscretisedTrajectoryToFile(['Differential_Flatness/EEE_demo_trajectories/' fileName '.trj']);


    %% Plotting
%     trajectory.plotStateTrajectories;
    % trajectory.plotFlatOutputs(false, true);
    trajectory.plotCartesianTrajectory;
    
    [pvdv,u,S,t] = trajectory.getStateTrajectories(0.005);
    pv0 = pvdv(1:8,1);
    tend = trajectory.tend;
    pvdv(:,end) = pvdv(:,end) .* (abs(pvdv(:,end))>1e-2); % Ensures end velocities are zero if they are supposed to be
    u(:,end) = u(:,end) .* (abs(u(:,end))>1e-2);
    traj.pvdv = timeseries(pvdv,t);
    traj.u = timeseries(u,t);


    % Calculate feedback gain K for simulink simulation
    Q = diag([1 1 1 0.1 0 0 0 0]);
    R = 0.5*eye(4);
    K = lqr(modelData.linsys,Q,R);
    
    % Calculate feedback gain k with integral action for simulink simulation
    Q = diag([1 1 1 1 1 1 0 0 0 0 0]);
    R = 1*eye(4);
    K_int = lqr([zeros(3,3) eye(3) zeros(3,5); zeros(8,3) modelData.linsys.A], [zeros(3,4); modelData.linsys.B], Q, R);


end
