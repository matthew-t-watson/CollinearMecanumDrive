function [  ] = plot_t_exec( res, constraints )

stairs(res.MPC.t, res.MPC.t_exec), title('$t_{\text{exec}} \ (\unit{s})$');

end

