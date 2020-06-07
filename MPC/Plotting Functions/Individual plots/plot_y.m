function [  ] = plot_y( res, constraints )

y_lim_scale = 1.2;
plot(res.state.t, res.state.y, res.MPC.t, res.ref.y, '--'), title('$y \ (\si{\meter})$'); ylim([min(res.state.y) max(res.state.y)] + [-y_lim_scale*0.5*range(res.state.y) y_lim_scale*0.5*range(res.state.y)]);

end

