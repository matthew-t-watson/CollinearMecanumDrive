
% close all;
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

nr_range = [10 30];

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
        , 'MAS', 'minimal' ...
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
    pv0 = [-1 -1 0 0 0 0 0 0]';
    runtime = 10;
    steps = round(runtime/MPC.Ts);

    %% Generate reference profiles
    % Figure of 8
    figure8 = [];
    a = 1;
    lapDuration = 10;
    stepsPerLap = round(lapDuration/MPC.Ts);
    for i = 0:steps
        figure8 = [figure8 [a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
            a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)*sin(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
            0]
            ];
    end
    figure8 = [figure8 repmat([0 0 0]', [1 steps-stepsPerLap+MPC.nr])];


    %% Select reference
    ref = figure8;
    previewing = true;

    %% Run simulation
    res{j} = run_single_simulation(modelData, MPC, 'Nonlinear', 'qpOASES', pv0, ref, previewing);
end

constraints.u_max = MPC.umax(1);
constraints.x_dot_max = MPC.v_x_max;
constraints.y_dot_max = MPC.v_y_max;
constraints.phi_dot_max = MPC.phi_dot_max;
constraints.theta_p_max = MPC.theta_p_max;

figure;
plot(res{1}.state.x, res{1}.state.y, res{2}.state.x, res{2}.state.y, res{1}.ref.x, res{1}.ref.y, '--');
axis equal;
xlim(xlim*1.1);
cleanfigure;
legend('\(n_c=10\)', '\(n_c=30\)', '\(y_r\)', 'Location', 'SouthEast');
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\simulated_figure_8_infeasible_start_cartesian.tex', 'width', '0.7\linewidth', 'parseStrings', false, 'extraTikzpictureOptions', 'trim axis left, trim axis right')


figure('pos',[680 42 560 800]);
subplot(5,2,1); plot_u(res{1}, constraints);
subplot(5,2,2); plot_c(res{1}, constraints);
subplot(5,2,3); plot_c_inf(res{1}, constraints);
subplot(5,2,4); plot_cost(res{1}, constraints);
subplot(5,2,5); plot_x(res{1}, constraints);
subplot(5,2,6); plot_y(res{1}, constraints);
subplot(5,2,7); plot_theta_p(res{1}, constraints);
subplot(5,2,8); plot_x_dot(res{1}, constraints);
subplot(5,2,9); plot_y_dot(res{1}, constraints);
subplot(5,2,10); plot_t_exec(res{1}, constraints);


all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\simulated_figure_8_infeasible_start.tex', 'width', '0.9\linewidth', 'height', '0.8\textheight', 'parseStrings', false)


figure('pos',[680 42 560 800]);
subplot(5,2,1); plot_u(res{2}, constraints);
subplot(5,2,2); plot_c(res{2}, constraints);
subplot(5,2,3); plot_c_inf(res{2}, constraints);
subplot(5,2,4); plot_cost(res{2}, constraints);
subplot(5,2,5); plot_x(res{2}, constraints);
subplot(5,2,6); plot_y(res{2}, constraints);
subplot(5,2,7); plot_theta_p(res{2}, constraints);
subplot(5,2,8); plot_x_dot(res{2}, constraints);
subplot(5,2,9); plot_y_dot(res{2}, constraints);
subplot(5,2,10); plot_t_exec(res{2}, constraints);


all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );