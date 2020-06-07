
close all;

data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_060219_1803_good_x_steps.csv');
data.state.t = data.t;
data.MPC.t = data.t;
data = trim_data(data, 101.781, 101.781+5);

data.MPC.u = [data.tau.tau_1 data.tau.tau_2 data.tau.tau_3 data.tau.tau_4]';
data.MPC.c = data.MPC.c;
data.MPC.c_inf = data.MPC.c_inf;
data.state.y_dot = -data.state.y_dot;
data.state.theta_p = -data.state.theta_p;
data.state.theta_p_dot = -data.state.theta_p_dot;
res = data;

figure;
subplot(5,2,1); stairs(res.MPC.t, res.MPC.u'); hold on; plot([min(res.MPC.t) max(res.MPC.t)], [MPC.umax(1) -MPC.umax(1); MPC.umax(1) -MPC.umax(1)], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.15 0.15]); legend('\(\tau_1\)', '\(\tau_2\)', '\(\tau_3\)', '\(\tau_4\)', '\(\pm\overline{\tau}\)');
subplot(5,2,2); stairs(res.MPC.t, res.MPC.c(1:4,:)'); legend('\(c_{0,1}\)', '\(c_{0,2}\)', '\(c_{0,3}\)', '\(c_{0,4}\)', 'Location', 'SouthEast'); 
subplot(5,2,3); stairs(res.MPC.t', res.MPC.c_inf'); legend('\(c_{\infty,1}\)', '\(c_{\infty,2}\)', '\(c_{\infty,3}\)', '\(c_{\infty,4}\)', 'Location', 'SouthEast');
subplot(5,2,4); stairs(res.MPC.t', res.MPC.cost'); legend('\(J\)');
subplot(5,2,5); plot(res.state.t, res.state.x); hold on; stairs(res.MPC.t', res.ref.x', '--'); legend('\(x\)', '\(r_x\)', 'Location', 'SouthEast'); 
subplot(5,2,7); plot(res.state.t, res.state.x_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_x_max -MPC.v_x_max; MPC.v_x_max -MPC.v_x_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_x\)', '\(\pm\overline{v}_x\)');
subplot(5,2,6); plot(res.state.t, res.state.y); hold on; stairs(res.MPC.t', res.ref.y', '--'); legend('\(y\)', '\(r_y\)', 'Location', 'SouthEast'); 
subplot(5,2,8); plot(res.state.t, res.state.y_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_y_max -MPC.v_y_max; MPC.v_y_max -MPC.v_y_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_y\)', '\(\pm\overline{v}_y\)');
subplot(5,2,9); plot(res.state.t, res.state.theta_p); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.theta_p_max -MPC.theta_p_max; MPC.theta_p_max -MPC.theta_p_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(\theta_p\)', '\(\pm\overline{\theta}_p\)');
subplot(5,2,10); stairs(res.MPC.t', res.MPC.t_exec'); legend('\(t_{\text{exec}}\)');

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\experimental_x_step_new.tex', 'height', '0.8\textheight', 'width', '0.95\linewidth', 'parseStrings', false)
