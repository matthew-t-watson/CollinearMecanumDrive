function [  ] = plot_x( res, constraints )

y_lim_scale = 1.2;
plot(res.state.t, res.state.x, res.MPC.t, res.ref.x, '--'), title('$x \ (\si{\meter})$'); ylim([min(res.state.x) max(res.state.x)] + [-y_lim_scale*0.5*range(res.state.x) y_lim_scale*0.5*range(res.state.x)]);

end

