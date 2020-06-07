function [  ] = plot_c( res, constraints )

stairs(res.MPC.t, res.MPC.cost);
title('$J$')

end

