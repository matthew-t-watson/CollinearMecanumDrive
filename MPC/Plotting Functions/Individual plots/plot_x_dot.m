function [  ] = plot_x_dot( res, constraints )

y_lim_scale = 1.2;
plot(res.state.t, res.state.x_dot), title('\(\dot{x} \ (\si{\meter\per\second})\)'), hold on, plot([res.state.t(1),res.state.t(end); res.state.t(1),res.state.t(end)]',constraints.x_dot_max*[1 -1; 1 -1], '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-1 1]*constraints.x_dot_max*y_lim_scale);
end

