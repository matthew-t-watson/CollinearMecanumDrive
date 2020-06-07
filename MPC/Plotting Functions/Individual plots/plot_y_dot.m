function [  ] = plot_y_dot( res, constraints )

y_lim_scale = 1.2;
plot(res.state.t, res.state.y_dot);
title('\(\dot{y} \ (\si{\meter\per\second})\)');
hold on;
plot([res.state.t(1),res.state.t(end); res.state.t(1),res.state.t(end)]',constraints.y_dot_max*[1 -1; 1 -1], '-.','Color',[0.8500, 0.3250, 0.0980]);
ylim([-1 1]*y_lim_scale*max([constraints.y_dot_max max(abs(res.state.y_dot))]));
end

