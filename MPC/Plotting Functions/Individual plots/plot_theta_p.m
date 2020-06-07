function [  ] = plot_theta_p( res, constraints )

y_lim_scale = 1.2;
plot(res.state.t, res.state.theta_p);
title('$\theta_p \ (\si{\radian})$');
hold on;
plot([res.MPC.t(1),res.MPC.t(end); res.MPC.t(1),res.MPC.t(end)]',constraints.theta_p_max*[1 -1; 1 -1], '-.','Color',[0.8500, 0.3250, 0.0980]); 
ylim([-1 1]*y_lim_scale*constraints.theta_p_max);
end

