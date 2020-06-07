close all;
clearvars -except modelData trajectory MPC


%% Ensure we are in the correct path
cd('D:\Google_Drive\Matlab\CMD');
rmpath('D:\Program Files\Mosek\8\toolbox\r2014a');

addpath('../nestedSortStruct');
addpath(genpath('../YALMIP-master/'));
addpath(genpath('../SeDuMi_1_3'));
addpath(genpath('../matlab2tikz'));

%% Create modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(true);
end

%% Derive MPC
MPC = Derive_MPC_Reference_Previewing(modelData ...
    , 'Ts', 0.04... Increasing this allows greater access to the constrained set for an equivalent nc
    , 'nc', 12 ...
    , 'nr', 12 ...  Surprisingly nr>nc gives good results on figure 8 simulation - yields infeasibility on step reference though
    , 'Q', diag([1 1 1 0 0 0 0 0]) ...
    , 'R', 0.5*eye(4) ... 
    , 'umax', 0.1*ones(4,1) ... 0.05 reduces peak theta_p, 0.065 is same as 0.1
    , 'theta_p_max', 0.3 ...
    , 'v_y_max', 1 ...
    , 'v_x_max', 1 ...
    , 'phi_dot_max', 4 ...
    , 'MAS', 'minimal' ...
    , 'MAS_tolerance', 1E-4 ... % 3E-3 seems to cause instability, 1E-3 seems ok
    , 'removeConstraints', 0 ...
    , 'slackType', 'individualToNiThenShared' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
    ... , 'slackType', 'individualToNiThenShared' ...
    , 'ni', 3 ... 3 appears to be optimal for smooth transitions between constrained and unconstrained regions
    , 'cinf_weighting', 1E-12 ...
    , 's_weight', [1E-5 1e-5 1e-5] ...
    , 's_weight_inf' , [1E2 1 1E1] ... % 1E3 for theta_p gives willingful violation, 1E4 gives a small overshoot on theta_p, 1E5 gives tight constraint tracking
    , 'generateCode', true ...
    , 'verbosity', 2 ...
    , 'forceRegen', true ...
    );

%% Setup
config(1).polyDegree = 9;
config(1).polyDegreeVelSeg = 8; 
config(1).derivToMin = 5;
config(1).conDerivDeg = 4; 

config(2) = config(1);

config(3).polyDegree = 7;
config(3).polyDegreeVelSeg = 1; 
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
waypointSet = 2;
switch(waypointSet)
    case 1
        trajectory.addWaypoint(0,0,0,0,'boundary');
        trajectory.addWaypoint(1,0,0,4,'position');
        trajectory.addWaypoint(0,0,0,8,'boundary');
        
        % Configure polycoefs as step trajectories
        trajectory.makeStepTrajectory;

    case 2
        figure8 = [];
        runtime = 10;
        steps = round(runtime/MPC.Ts);
        a = 1;
        lapDuration = 10;
        stepsPerLap = round(lapDuration/MPC.Ts);
        for i = 0:steps
            figure8 = [figure8 [a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
                a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)*sin(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
                0]
                ];
        end
        % figure8 = [figure8 repmat([0 0 0]', [1 steps-stepsPerLap+MPC.nr])];
        
%         % Flip figure 8 axes
%         figure8(1:2,:) = flipud(figure8(1:2,:));

        % Shift figure-of-8 by (1,1)
        figure8 = figure8 + repmat([1; 1; 0], [1 size(figure8,2)]);
        

        [p,durations] = fit_polynomials_to_trajectory(figure8,MPC.Ts,MPC.Ts*30,[trajectory.config.polyDegree]);
        durations = durations + MPC.Ts; % No idea why this line is necessary, but it works #dontbitethehand
        trajectory.setTrajectoryFromPolyCoefs(p,durations);    
end


trajectory.plotFlatOutputs(false, false);
trajectory.plotCartesianTrajectory;

% %% Send trajectory to robot
% trajectory.getROSTrajectoryMessage

%% Run simulation
pv0 = zeros(8,1);
ref = figure8;
res_nl = run_single_simulation(modelData, MPC, 'Nonlinear', 'qpOASES', pv0, ref, true);

constraints.u_max = MPC.umax(1);
constraints.x_dot_max = MPC.v_x_max;
constraints.y_dot_max = MPC.v_y_max;
constraints.phi_dot_max = MPC.phi_dot_max;
constraints.theta_p_max = MPC.theta_p_max;

%% Plot readouts
plot_xy_readout(res_nl, constraints, false, '');
plot_xy(res_nl, constraints, false, '');
