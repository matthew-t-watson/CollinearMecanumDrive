function [  ] = plot_theta_p_dot( res, constraints )

plot(res.state.t, res.state.theta_p_dot), title('\(\dot{\theta}_p \ (\unit{rad s^{-1}})\)');

end

