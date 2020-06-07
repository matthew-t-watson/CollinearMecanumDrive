
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
x0 = [-1 -1 0 0 0 0 0 0]';
runtime = 12;
steps = round(runtime/MPC.Ts) + MPC.nr-1;

% Figure of 8
ref = [];
a = 1;
lapDuration = 10;
stepsPerLap = round(lapDuration/MPC.Ts);
for i = 0:stepsPerLap
    ref = [ref, ...
        [a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)*sin(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        0]
        ];
end
ref = [ref zeros(3,steps-stepsPerLap)];
previewing = true;

%% Run simulation
res = run_single_simulation(modelData, MPC, 'Linear', 'qpOASES', x0, ref, previewing);
% res = run_single_simulation(modelData, MPC, 'Nonlinear', 'qpOASES', x0, ref, previewing);


figure;
subplot(5,2,1); xlim([0 runtime]); stairs(res.MPC.t', res.MPC.u'); hold on; plot([min(res.MPC.t) max(res.MPC.t)], [MPC.umax(1) -MPC.umax(1); MPC.umax(1) -MPC.umax(1)], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.15 0.15]); legend('\(\tau_1\)', '\(\tau_2\)', '\(\tau_3\)', '\(\tau_4\)', '\(\pm\overline{\tau}\)');
subplot(5,2,2); xlim([0 runtime]); stairs(res.MPC.t', res.MPC.c(1:4,:)'); legend('\(c_{0,1}\)', '\(c_{0,2}\)', '\(c_{0,3}\)', '\(c_{0,4}\)', 'Location', 'SouthEast');
subplot(5,2,3); xlim([0 runtime]); stairs(res.MPC.t', res.MPC.c_inf'); legend('\(c_{\infty,1}\)', '\(c_{\infty,2}\)', '\(c_{\infty,3}\)', '\(c_{\infty,4}\)', 'Location', 'SouthEast');
subplot(5,2,4); xlim([0 runtime]); stairs(res.MPC.t', res.MPC.cost'); legend('\(J\)');
subplot(5,2,5); xlim([0 runtime]); plot(res.state.t, res.state.x); hold on; stairs(res.MPC.t', res.ref.x', '--'); legend('\(x\)', '\(r_x\)', 'Location', 'NorthEast'); 
subplot(5,2,6); xlim([0 runtime]); plot(res.state.t, res.state.y); hold on; stairs(res.MPC.t', res.ref.y', '--'); legend('\(y\)', '\(r_y\)', 'Location', 'NorthEast'); 
subplot(5,2,7); xlim([0 runtime]); plot(res.state.t, res.state.x_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_x_max -MPC.v_x_max; MPC.v_x_max -MPC.v_x_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_x\)', '\(\pm\overline{v}_x\)');
subplot(5,2,8); xlim([0 runtime]); plot(res.state.t, res.state.y_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_y_max -MPC.v_y_max; MPC.v_y_max -MPC.v_y_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_y\)', '\(\pm\overline{v}_y\)');
subplot(5,2,9); xlim([0 runtime]); plot(res.state.t, res.state.theta_p); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.theta_p_max -MPC.theta_p_max; MPC.theta_p_max -MPC.theta_p_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.4 0.4]); legend('\(\theta_p\)', '\(\pm\overline{\theta}_p\)');
subplot(5,2,10); xlim([0 runtime]); stairs(res.MPC.t', res.MPC.t_exec'); legend('\(t_{\text{exec}}\)');

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\simulated_figure_8_new.tex', 'height', '0.9\textheight', 'width', '0.95\linewidth', 'parseStrings', false)

