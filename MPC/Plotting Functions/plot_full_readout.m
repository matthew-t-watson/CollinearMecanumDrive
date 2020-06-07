function [ ] = plot_full_readout( res, constraints )


figure;
subplot(4,4,1); plot_u(res, constraints);
subplot(4,4,2); plot_c(res, constraints);
subplot(4,4,3); plot_c_inf(res, constraints);
% subplot(4,4,4); plot(res.MPC.t, res.MPC.r_hat'), title('r hat');
subplot(4,4,5); stairs(res.MPC.t, res.MPC.cost), title('Cost');
subplot(4,4,6); plot_x(res, constraints);
subplot(4,4,7); plot_y(res, constraints);
subplot(4,4,8); plot_theta_p(res, constraints);
subplot(4,4,9); plot_x_dot(res, constraints);
subplot(4,4,10); plot_y_dot(res, constraints);
subplot(4,4,11); plot_phi(res, constraints);
subplot(4,4,12); plot_phi_dot(res, constraints);
subplot(4,4,13); plot_theta_p_dot(res, constraints);
subplot(4,4,14); plot(res.MPC.t, res.MPC.t_exec'); title('$t_{\text{exec}} \ (\unit{s})$');
if isfield(res.MPC, 's')
    subplot(4,4,15); plot(res.MPC.t, res.MPC.s); title('$s$');
end
subplot(4,4,16); plot(res.MPC.t, res.MPC.iter); title('iterations');

all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );

end

