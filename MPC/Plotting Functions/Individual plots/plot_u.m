function [  ] = plot_u( res, constraints )

y_lim_scale = 1.3;

stairs(res.MPC.t, res.MPC.u'); 
hold on; 
plot([res.MPC.t(1),res.MPC.t(end); res.MPC.t(1),res.MPC.t(end)]',constraints.u_max*[1 -1; 1 -1], '-.','Color',[0.8500, 0.3250, 0.0980]); 
title('$u \ (\si{\newton\meter})$'); 
ylim([-1 1]*constraints.u_max*y_lim_scale);

end

