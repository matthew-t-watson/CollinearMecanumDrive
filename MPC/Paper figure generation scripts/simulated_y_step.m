
close all;
clearvars -except modelData;

rmpath('D:\Program Files\Mosek\8\toolbox\r2014a');

% Create modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(true);
end

%% Derive MPC
MPC = get_simulation_controller(modelData);

%% Simulation Setup
x0 = [0 0 0 0 0 0 0 0]';
runtime = 6;
steps = round(runtime/MPC.Ts);

%% Generate reference profiles
% Step changes
stepIndex = round(2/MPC.Ts);
step = [
    repmat([0 0 0]', [1 stepIndex]) ...
    repmat([0 1 0]', [1 steps-stepIndex+MPC.nr])
    ];

%% Select reference
ref = step;
previewing = true;

%% Run simulation
res = run_single_simulation(modelData, MPC, 'Linear', 'qpOASES', x0, ref, previewing);
% res = run_single_simulation(modelData, MPC, 'Nonlinear', 'qpOASES', x0, ref, previewing);

constraints.u_max = MPC.umax(1);
constraints.x_dot_max = MPC.v_x_max;
constraints.y_dot_max = MPC.v_y_max;
constraints.phi_dot_max = MPC.phi_dot_max;
constraints.theta_p_max = MPC.theta_p_max;

% plot_y_readout(res_lin, constraints, true, 'Figures\linear_y_step.tex');
% plot_y_readout(res, constraints, false, 'Figures\nonlinear_y_step.tex');

figure;
subplot(4,2,1); stairs(res.MPC.t', res.MPC.u'); hold on; plot([min(res.MPC.t) max(res.MPC.t)], [MPC.umax(1) -MPC.umax(1); MPC.umax(1) -MPC.umax(1)], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.15 0.15]); legend('\(\tau_1\)', '\(\tau_2\)', '\(\tau_3\)', '\(\tau_4\)', '\(\pm\overline{\tau}\)');
subplot(4,2,2); stairs(res.MPC.t', res.MPC.c(1:4,:)'); legend('\(c_{0,1}\)', '\(c_{0,2}\)', '\(c_{0,3}\)', '\(c_{0,4}\)', 'Location', 'SouthEast'); ylim([-0.5 0.2]);
subplot(4,2,3); stairs(res.MPC.t', res.MPC.c_inf'); legend('\(c_{\infty,1}\)', '\(c_{\infty,2}\)', '\(c_{\infty,3}\)', '\(c_{\infty,4}\)', 'Location', 'SouthEast');
subplot(4,2,4); stairs(res.MPC.t', res.MPC.cost'); legend('\(J\)');
subplot(4,2,5); plot(res.state.t, res.state.y); hold on; stairs(res.MPC.t', res.ref.y', '--'); legend('\(y\)', '\(r_y\)', 'Location', 'SouthEast'); ylim([-0.2 1.2]);
subplot(4,2,6); plot(res.state.t, res.state.theta_p); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.theta_p_max -MPC.theta_p_max; MPC.theta_p_max -MPC.theta_p_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.4 0.4]); legend('\(\theta_p\)', '\(\pm\overline{\theta}_p\)');
subplot(4,2,7); plot(res.state.t, res.state.y_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_y_max -MPC.v_y_max; MPC.v_y_max -MPC.v_y_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-1.5 1.5]); legend('\(v_y\)', '\(\pm\overline{v}_y\)');
subplot(4,2,8); stairs(res.MPC.t', res.MPC.t_exec'); legend('\(t_{\text{exec}}\)');

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\simulated_y_step_new.tex', 'height', '0.8\textheight', 'width', '0.95\linewidth', 'parseStrings', false)

