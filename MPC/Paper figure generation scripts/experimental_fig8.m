
close all;

% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_070219_1322_figure_8_aggressive_control_10s.csv'); % old
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1508.csv'); % tauMax=0.1 nr=12 Q=[1 1 1 0.1] R=0.5
data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1548.csv'); % tauMax=0.08 nr=12 Q=[1 1 1 0.1] R=0.5
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1556.csv'); % tauMax=0.1 nr=12 Q=[1 1 1 0.1] R=0.5
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1625.csv'); % tauMax=0.1 nr=12 Q=[1 1 1 0] R=0.1
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1636.csv'); % tauMax=0.1 nr=12 Q=[1 1 1 0] R=0.2
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1638.csv'); % tauMax=0.1 nr=12 Q=[1 1 1 0] R=0.5
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1648.csv'); % tauMax=0.1 nr=25 Q=[1 1 1 0] R=0.5
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1658.csv'); % tauMax=0.1 nr=10 Q=[1 1 1 0] R=0.5 Ts=0.04
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_170719_1705.csv'); % tauMax=0.1 nr=12 Q=[1 1 1 0] R=0.5 Ts=0.04




data.state.x = data.state.x - 1;
data.state.y = data.state.y - 1;
data.ref.x = data.ref.x - 1;
data.ref.y = data.ref.y - 1;


data.MPC.ref = data.ref;
data.MPC.u = struct2array(data.tau)'*(0.1/0.08);
data.state.t = data.t;
data.MPC.t = data.t;
data = trim_data(data, 43.91, 43.91+12);
res = data;

figure;
subplot(5,2,1); stairs(res.MPC.t', res.MPC.u'); hold on; plot([min(res.MPC.t) max(res.MPC.t)], [MPC.umax(1) -MPC.umax(1); MPC.umax(1) -MPC.umax(1)], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.15 0.15]); legend('\(\tau_1\)', '\(\tau_2\)', '\(\tau_3\)', '\(\tau_4\)', '\(\pm\overline{\tau}\)');
subplot(5,2,2); stairs(res.MPC.t', res.MPC.c(1:4,:)'); legend('\(c_{0,1}\)', '\(c_{0,2}\)', '\(c_{0,3}\)', '\(c_{0,4}\)', 'Location', 'SouthEast');
subplot(5,2,3); stairs(res.MPC.t', res.MPC.c_inf'); legend('\(c_{\infty,1}\)', '\(c_{\infty,2}\)', '\(c_{\infty,3}\)', '\(c_{\infty,4}\)', 'Location', 'SouthEast');
subplot(5,2,4); stairs(res.MPC.t', res.MPC.cost'); legend('\(J\)');
subplot(5,2,5); plot(res.state.t, res.state.x); hold on; stairs(res.MPC.t', res.ref.x', '--'); legend('\(x\)', '\(r_x\)', 'Location', 'NorthEast'); 
subplot(5,2,6); plot(res.state.t, res.state.y); hold on; stairs(res.MPC.t', res.ref.y', '--'); legend('\(y\)', '\(r_y\)', 'Location', 'NorthEast'); 
subplot(5,2,7); plot(res.state.t, res.state.x_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_x_max -MPC.v_x_max; MPC.v_x_max -MPC.v_x_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_x\)', '\(\pm\overline{v}_x\)');
subplot(5,2,8); plot(res.state.t, res.state.y_dot); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.v_y_max -MPC.v_y_max; MPC.v_y_max -MPC.v_y_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); legend('\(v_y\)', '\(\pm\overline{v}_y\)');
subplot(5,2,9); plot(res.state.t, res.state.theta_p); hold on; plot([min(res.state.t) max(res.state.t)], [MPC.theta_p_max -MPC.theta_p_max; MPC.theta_p_max -MPC.theta_p_max], 'Linestyle', '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-0.4 0.4]); legend('\(\theta_p\)', '\(\pm\overline{\theta}_p\)');
subplot(5,2,10); stairs(res.MPC.t', res.MPC.t_exec'); legend('\(t_{\text{exec}}\)');

cleanfigure;
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\experimental_figure_8_new.tex', 'height', '0.9\textheight', 'width', '0.95\linewidth', 'parseStrings', false)


figure;
plot(data.state.x, data.state.y); hold on;
plot(data.ref.x, data.ref.y, '--');
legend('\(n_c=10\)', '\(r\)', 'Location', 'SouthEast');
axis equal
xlim([-1.5 1.5]);
matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\MPC\experimental_figure_8_infeasible_start_cartesian.tex', 'width', '0.7\linewidth', 'parseStrings', false, 'extraTikzpictureOptions', 'trim axis left, trim axis right')
