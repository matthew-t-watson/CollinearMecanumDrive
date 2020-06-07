function [  ] = plot_phi( res, constraints )

plot(res.state.t, res.state.phi, res.MPC.t, res.ref.phi, '--'), title('$\phi \ (\si{\radian})$');

end

