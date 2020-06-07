function [ ] = plot_xyphi_readout_unconstrained_case( res, constraints, saveFigure, varargin )

if saveFigure == true
    if nargin < 4
        error('Path not specified for figure');
    else
        path = varargin{1};        
    end
end

figure('pos',[680 42 560 667]);
subplot(4,2,1); plot_u(res, constraints);
subplot(4,2,2); plot_x(res, constraints);
subplot(4,2,3); plot_y(res, constraints);
subplot(4,2,4); plot_theta_p(res, constraints);
subplot(4,2,5); plot_x_dot(res, constraints);
subplot(4,2,6); plot_y_dot(res, constraints);
subplot(4,2,7); plot_phi(res, constraints);
subplot(4,2,8); plot_phi_dot(res, constraints);

all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );

if saveFigure
    matlab2Tikz2ColumnWrapper(path);
end

end

