function [  ] = plot_phi_dot( res, constraints )

y_lim_scale = 1.2;
plot(res.state.t, res.state.phi_dot), title('\(\dot{\phi} \ (\unit{rad s^{-1}})\)'), hold on, plot([res.state.t(1),res.state.t(end); res.state.t(1),res.state.t(end)]',constraints.phi_dot_max*[1 -1; 1 -1], '-.','Color',[0.8500, 0.3250, 0.0980]); ylim([-1 1]*constraints.phi_dot_max*y_lim_scale);
end

