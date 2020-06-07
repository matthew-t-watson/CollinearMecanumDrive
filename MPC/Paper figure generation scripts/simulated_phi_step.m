
close all;
clear variables;

%% Derive MPC
MPC = get_simulation_controller;

%% Simulation Setup
x0 = [0 0 0 0 0 0 0 0]';
runtime = 3;
steps = round(runtime/MPC.Ts);

%% Generate reference profiles
% Step changes
stepIndex = round(1/MPC.Ts);
step = [
    repmat([0 0 0 0 0 0 0 0]', [1 stepIndex]) ...
    repmat([0 0 pi 0 0 0 0 0]', [1 steps-stepIndex+MPC.nr])
    ];

%% Select reference
ref = step;
previewing = true;

%% Run simulation
% res_lin = run_single_simulation(MPC, 'Linear', 'qpOASES', x0, ref, previewing);
res_nl = run_single_simulation(MPC, 'Nonlinear', 'qpOASES', x0, ref, previewing);

constraints.u_max = MPC.umax(1);
constraints.x_dot_max = MPC.v_x_max;
constraints.y_dot_max = MPC.v_y_max;
constraints.phi_dot_max = MPC.phi_dot_max;
constraints.theta_p_max = MPC.theta_p_max;

% plot_phi_readout(res_lin, constraints, true, 'Figures\linear_phi_step.tex');
plot_phi_readout(res_nl, constraints, true, 'Figures\nonlinear_phi_step.tex');

% plot_full_readout(res_nl, constraints)
