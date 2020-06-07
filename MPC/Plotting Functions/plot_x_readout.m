function [ ] = plot_x_readout( res, constraints, saveFigure, varargin )

if saveFigure == true
    if nargin < 4
        error('Path not specified for figure');
    else
        path = varargin{1};        
    end
end

figure('pos',[680 42 560 316]);
subplot(2,2,1); plot_u(res, constraints);
% subplot(2,2,2); plot_c(res, constraints);
% subplot(2,2,3); plot_c_inf(res, constraints);
% subplot(2,2,4); plot_cost(res, constraints);
subplot(2,2,2); plot_y(res, constraints);
subplot(2,2,3); plot_x(res, constraints);
subplot(2,2,4); plot_x_dot(res, constraints);

all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );


xlim([0 3]);

if saveFigure
    matlab2Tikz2ColumnWrapper(path);
end

end

