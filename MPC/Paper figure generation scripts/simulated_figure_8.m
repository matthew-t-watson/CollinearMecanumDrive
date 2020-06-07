
% close all;

%% Simulation Setup
x0 = [0 0 0 0 0 0 0 0]';
runtime = 10;
steps = round(runtime/MPC.Ts) + MPC.nr-1;

% Figure of 8
ref = [];
a = 1;
lapDuration = 10;
stepsPerLap = round(lapDuration/MPC.Ts);
for i = 0:steps
    ref = [ref, ...
        [a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)*sin(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        zeros(6,1)]
        ];
end
previewing = true;

%% Run simulation
% res_lin = run_single_simulation(MPC, 'Linear', 'qpOASES', x0, ref, previewing);
res_nl = run_single_simulation(modelData, MPC, 'Nonlinear', 'qpOASES', x0, ref, previewing);

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
plot_xyphi_readout(res_nl, constraints, false, 'MPC\Figures\nonlinear_figure_8.tex');
% plot_xyphi_readout_unconstrained_case(res_nl, constraints, true, 'MPC\Figures\nonlinear_figure_8.tex');
% plot_xy(res_lin, constraints, true, 'Figures\linear_figure_8_trajectory.tex');
plot_xy(res_nl, constraints, false, 'MPC\Figures\nonlinear_figure_8_trajectory.tex');

% plot_full_readout(res_nl,constraints);
