function [ ] = plot_y_readout( res, constraints, saveFigure, varargin )

if saveFigure == true
    if nargin < 4
        error('Path not specified for figure');
    else
        path = varargin{1};        
    end
end

figure('pos',[680 42 560 667]);

subplot(4,2,1); plot_u(res, constraints);
subplot(4,2,2); plot_c(res, constraints);
subplot(4,2,3); plot_c_inf(res, constraints);
subplot(4,2,4); plot_cost(res, constraints);
subplot(4,2,5); plot_y(res, constraints);
subplot(4,2,6); plot_theta_p(res, constraints);
subplot(4,2,7); plot_y_dot(res, constraints);
subplot(4,2,8), plot_t_exec(res, constraints);

all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );

xlim([0 5]);

if saveFigure
    matlab2Tikz2ColumnWrapper(path);
end

end

