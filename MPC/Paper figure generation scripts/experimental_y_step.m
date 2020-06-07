
close all;


% data = import_data('data_190418_1021 lovely y steps with Ts=0.04.csv');
% data = trim_data(data, 130, 136);


% data = import_data('data_190418_1614 y steps lab.csv');

data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_250119_1315.csv');
data.state.t = data.t;
data.MPC = data.MPC_Info;
data.ref = data.reference;
data = trim_data(data, 170.78, 176.78);
data.MPC.u = [-data.tau.tau_1 -data.tau.tau_2 -data.tau.tau_3 -data.tau.tau_4];
data.MPC.c = -data.MPC.c;
data.MPC.c_inf = -data.MPC.c_inf;
data.state.y = -data.state.y + 1;
data.state.y_dot = -data.state.y_dot;
data.state.theta_p = -data.state.theta_p;
data.state.theta_p_dot = -data.state.theta_p_dot;
data.ref.y = -data.ref.y + 1;

res = data;

figure;
subplot(4,2,1); stairs(res.MPC.t, res.MPC.u); hold on; plot([min(res.MPC.t) max(res.MPC.t)], [MPC.umax(1) -MPC.umax(1); MPC.umax(1) -MPC.umax(1)], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.15 0.15]); legend('\(\tau_1\)', '\(\tau_2\)', '\(\tau_3\)', '\(\tau_4\)', '\(\pm\overline{\tau}\)');
subplot(4,2,2); stairs(res.MPC.t', res.MPC.c(1:4,:)'); legend('\(c_{0,1}\)', '\(c_{0,2}\)', '\(c_{0,3}\)', '\(c_{0,4}\)', 'Location', 'SouthEast'); 
subplot(4,2,3); stairs(res.MPC.t', res.MPC.c_inf'); legend('\(c_{\infty,1}\)', '\(c_{\infty,2}\)', '\(c_{\infty,3}\)', '\(c_{\infty,4}\)', 'Location', 'SouthEast');
subplot(4,2,4); stairs(res.MPC.t', res.MPC.cost'); legend('\(J\)');
subplot(4,2,5); plot(res.state.t, res.state.y); hold on; stairs(res.MPC.t', res.ref.y', '--'); legend('\(y\)', '\(r_y\)', 'Location', 'SouthEast'); 
subplot(4,2,6); plot(res.state.t, res.state.theta_p); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.theta_p_max -MPC.theta_p_max; MPC.theta_p_max -MPC.theta_p_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(\theta_p\)', '\(\pm\overline{\theta}_p\)');
subplot(4,2,7); plot(res.state.t, res.state.y_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_y_max -MPC.v_y_max; MPC.v_y_max -MPC.v_y_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_y\)', '\(\pm\overline{v}_y\)');
subplot(4,2,8); stairs(res.MPC.t', res.MPC.t_exec'); legend('\(t_{\text{exec}}\)');

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\experimental_y_step_new.tex', 'height', '0.8\textheight', 'width', '0.95\linewidth', 'parseStrings', false)

