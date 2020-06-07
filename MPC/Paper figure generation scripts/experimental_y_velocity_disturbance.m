
close all;

% % data = import_data('data_190418_0917 velocity constraint violations Q=1 1 1 0 R=0.5 nc=3.csv');
% % data = trim_data(data, 127.8, 131.8);
% 
% data = import_data('data_190418_1331 y disturbances.csv');
% data = trim_data(data, 151, 155);
% 
% % data = import_data('data_190418_1615 y disturbances lab.csv');

data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_260119_1352.csv');
data.MPC.u = struct2array(data.tau)';
data.state.t = data.t;
data.MPC.t = data.t;

data = trim_data(data, 133.8, 133.8+6);
data.MPC.u = [data.tau.tau_1 data.tau.tau_2 data.tau.tau_3 data.tau.tau_4];

res = data;

figure;
subplot(2,2,1); stairs(res.MPC.t', res.MPC.u); hold on; plot([min(res.MPC.t) max(res.MPC.t)], [MPC.umax(1) -MPC.umax(1); MPC.umax(1) -MPC.umax(1)], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.15 0.15]); legend('\(\tau_1\)', '\(\tau_2\)', '\(\tau_3\)', '\(\tau_4\)', '\(\pm\overline{\tau}\)');
% subplot(2,2,2); stairs(res.MPC.t', res.MPC.c(1:4,:)'); legend('\(c_{0,1}\)', '\(c_{0,2}\)', '\(c_{0,3}\)', '\(c_{0,4}\)', 'Location', 'SouthEast');
% subplot(4,2,3); stairs(res.MPC.t', res.MPC.c_inf'); legend('\(c_{\infty,1}\)', '\(c_{\infty,2}\)', '\(c_{\infty,3}\)', '\(c_{\infty,4}\)', 'Location', 'SouthEast');
% subplot(4,2,4); stairs(res.MPC.t', res.MPC.cost'); legend('\(J\)');
subplot(2,2,2); plot(res.state.t, res.state.y); hold on; stairs(res.MPC.t', res.ref.y', '--'); legend('\(y\)', '\(r_y\)', 'Location', 'NorthEast'); 
subplot(2,2,3); plot(res.state.t, res.state.theta_p); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.theta_p_max -MPC.theta_p_max; MPC.theta_p_max -MPC.theta_p_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.4 0.4]); legend('\(\theta_p\)', '\(\pm\overline{\theta}_p\)');
subplot(2,2,4); plot(res.state.t, res.state.y_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_y_max -MPC.v_y_max; MPC.v_y_max -MPC.v_x_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_y\)', '\(\pm\overline{v}_y\)');
% subplot(4,2,8); stairs(res.MPC.t', res.MPC.t_exec'); legend('\(t_{\text{exec}}\)');

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\experimental_y_velocity_disturbance_new.tex', 'height', '0.4\textheight', 'width', '0.95\linewidth', 'parseStrings', false)
