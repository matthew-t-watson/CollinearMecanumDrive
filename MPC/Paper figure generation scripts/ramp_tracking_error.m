
close all;
clearvars -except modelData trajectory;

%% Ensure we are in the correct path
cd('D:\Google_Drive\Matlab\CMD');

%% Configure environment
addpath(genpath('../qpOASES-3.2.1/'));
rmpath('D:\Program Files\Mosek\8\toolbox\r2014a');


%% Create modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(true);
end

nr_range = [1 2 3 5 8 12 18 25 35];
C = linspecer(numel(nr_range), 'sequential')*0.8; 
% C = parula(numel(nr_range));
figure; 

for j=1:numel(nr_range)

    %% Derive MPC
    MPC = Derive_MPC_Reference_Previewing(modelData ...
        , 'Ts', 0.035... Increasing this allows greater access to the constrained set for an equivalent nc
        , 'nc', nr_range(j) ...
        , 'nr', nr_range(j) ...  Surprisingly nr>nc gives good results on figure 8 simulation - yields infeasibility on step reference though
        , 'Q', diag([1 1 1 0 0 0 0 0.0]) ...
        , 'R', 0.1*eye(4) ... 
        , 'umax', 0.1*ones(4,1) ... 0.05 reduces peak theta_p, 0.065 is same as 0.1
        , 'theta_p_max', 0.3 ...
        , 'v_y_max', 1 ...
        , 'v_x_max', 1 ...
        , 'phi_dot_max', 4 ...
        , 'MAS', 'lazy' ...
        , 'MAS_tolerance', 1E-3 ... % 3E-3 seems to cause instability, 1E-3 seems ok
        , 'removeConstraints', 0 ...
        , 'slackType', 'individualToNiThenShared' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
        ... , 'slackType', 'individualToNiThenShared' ...
        , 'ni', 3 ... 3 appears to be optimal for smooth transitions between constrained and unconstrained regions
        , 'cinf_weighting', 1E-20 ...
        , 's_weight', 1e-2*[1E4 1E3 1 1] ...[1E-3 1E-3 1E-5 1E-3] ...
        , 's_weight_inf' , [1E4 1E2 2E1 1E1] ... % 1E3 for theta_p gives willingful violation, 1E4 gives a small overshoot on theta_p, 1E5 gives tight constraint tracking
        , 'generateCode', false ...
        , 'verbosity', 2 ...
        , 'forceRegen', true ...
        );

    %% Simulation Setup
    pv0 = [0 0 0 0 0 0 0 0]';
    runtime = 20;
    steps = round(runtime/MPC.Ts);

    %% Generate reference profiles
    % Linear ramp
    ramp = zeros(3,1);
    for i=2:steps
        ramp(2,i) = ramp(2,i-1) + 0.03;
    end

    %% Select reference
    ref = ramp;
    previewing = true;

    traj.pvdv = timeseries(ref, 0:MPC.Ts:(MPC.Ts*(size(ref,2)-1)));
    traj.u = timeseries([0;0;0;0]);

    %% Run simulation
    res_nl = run_single_simulation(modelData, MPC, 'Nonlinear', 'qpOASES', pv0, ref, previewing);

    constraints.u_max = MPC.umax(1);
    constraints.x_dot_max = MPC.v_x_max;
    constraints.y_dot_max = MPC.v_y_max;
    constraints.phi_dot_max = MPC.phi_dot_max;
    constraints.theta_p_max = MPC.theta_p_max;

    %% Plot readouts
    % plot_full_readout(res_lin, constraints);
    % plot_full_readout(res_nl, constraints);


    % y position error
    t = res_nl.state.t;
    y = res_nl.state.y;
    yref = interp1(res_nl.MPC.t, res_nl.ref.y, res_nl.state.t);
    subplot(2,1,1); p = plot(t, yref-y); p.Color = C(j,:); hold on; 
    subplot(2,1,2); p = plot(t, y); p.Color = C(j,:); hold on; 

end

for i=1:numel(nr_range)
    legendStrings{i} = ['\(n_r=' num2str(nr_range(i)) '\)'];
end

subplot(2,1,1); legend(flipud(legendStrings), 'Location', 'NorthEastOutside'); xlim([0 5]); ylabel('\(r_y-y\)');
ax = gca; width = ax.Position(3);

subplot(2,1,2); hold on; ax = gca; ax.ColorOrderIndex = 1; plot(t, yref, '--'); xlim([0 5]); ylabel('\(y\)');
ax.Position(3) = width;

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\tracking_performance_over_nr.tex', 'width', '0.8\linewidth', 'height', '0.4\textheight', 'parseStrings', false, 'extraTikzpictureOptions', 'trim axis left, trim axis right')
