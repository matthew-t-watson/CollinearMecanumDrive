function [  ] = plot_c_inf( res, constraints )

stairs(res.MPC.t, res.MPC.c_inf'), title('$c_\infty$');

end

