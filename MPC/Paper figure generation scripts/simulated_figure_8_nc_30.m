
close all;
clear variables;

%% Derive MPC
MPC = Derive_MPC_Reference_Previewing(...
      'Ts', 0.035 ... Increasing this allows greater access to the constrained set for an equivalent nc
    , 'nc', 30 ...
    , 'nr', 30 ...  Surprisingly nr>nc gives good results on figure 8 simulation
    , 'Q', diag([1 1 1 0 0 0 0 1E-2]) ...
    , 'R', 0.1*eye(4) ... 
    , 'umax', 0.1*ones(4,1) ... 
    , 'theta_p_max', 0.3 ...
    , 'v_y_max', 1 ...
    , 'v_x_max', 1 ...
    , 'phi_dot_max', 4 ...
    , 'MAS', 'minimal' ...
    , 'MAS_tolerance', 1E-3 ... % 3E-3 seems to cause instability, 1E-3 seems ok
    , 'removeConstraints', 1 ...
    , 'slackType', 'individualToNiForThetaPAndVyThenShared' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
    ... , 'slackType', 'individualToNiThenShared' ...
    , 'ni', 2 ... 3 appears to be optimal for smooth transitions between constrained and unconstrained regions
    , 'cinf_weighting', 1E-18 ... Don't take below 1E-13 or weird stuff starts happening
    , 's_weight', [1E-5 1E-5 1E-5 1E-5] ...
    , 's_weight_inf' , [1E6 1E3 1E2 1E2] ... % 1E3 for theta_p gives willingful violation, 1E4 gives a small overshoot on theta_p, 1E5 gives tight constraint tracking
    , 'generateCode', false ...
    , 'verbosity', 2 ...
    , 'forceRegen', false ...
    );

%% Simulation Setup
x0 = [0 0 0 0 0 0 0 0]';
runtime = 15;
steps = round(runtime/MPC.Ts) + MPC.nr-1;

% Figure of 8
ref = [];
a = 1;
lapDuration = 15;
stepsPerLap = round(lapDuration/MPC.Ts);
for i = 0:steps
    ref = [ref, ...
        [a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)*sin(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        zeros(6,1)]
        ];
end
previewing = true;

%% Run simulation
% res_lin = run_single_simulation(MPC, 'Linear', 'qpOASES', x0, ref, previewing);
res_nl = run_single_simulation(MPC, 'Nonlinear', 'qpOASES', x0, ref, previewing);

constraints.u_max = MPC.umax(1);
constraints.x_dot_max = MPC.v_x_max;
constraints.y_dot_max = MPC.v_y_max;
constraints.phi_dot_max = MPC.phi_dot_max;
constraints.theta_p_max = MPC.theta_p_max;

% % plot_xy_readout(res_lin, constraints, true, 'Figures\linear_figure_8.tex');
% plot_xyphi_readout(res_nl, constraints, true, 'Figures\nonlinear_figure_8_nc=30.tex');
% % plot_xy(res_lin, constraints, true, 'Figures\linear_figure_8_trajectory.tex');
% plot_xy(res_nl, constraints, true, 'Figures\nonlinear_figure_8_trajectory_nc=30.tex');


% plot_xy_readout(res_lin, constraints, true, 'Figures\linear_figure_8.tex');
plot_xyphi_readout(res_nl, constraints, true, 'Figures\nonlinear_figure_8_nc_30.tex');
% plot_xy(res_lin, constraints, true, 'Figures\linear_figure_8_trajectory.tex');
plot_xy(res_nl, constraints, true, 'Figures\nonlinear_figure_8_trajectory_nc_30.tex');

% plot_full_readout(res_nl,constraints);
