function [  ] = plot_c( res, constraints )

stairs(res.MPC.t, res.MPC.c(1:4,:)'), title('$c$');

end

