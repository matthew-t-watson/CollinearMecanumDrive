function [ ] = plot_xy( res, constraints, saveFigure, varargin  )

if saveFigure == true
    if nargin < 3
        error('Path not specified for figure');
    else
        path = varargin{1};        
    end
end

figure('pos',[500 500 300 200]);

plot(res.state.x, res.state.y, res.ref.x, res.ref.y, '--');
xlabel('\(x (\unit{m})\)');
ylabel('\(y (\unit{m})\)');

axis equal;
xlim(xlim*1.1);


if saveFigure  
    cleanfigure;
    
    matlab2tikz(path, 'width', '0.7\linewidth', 'parseStrings', false, ...
        'extraaxisoptions',['title style={font=\footnotesize},'...
        'title style={yshift=-1.5ex},' ...
        'xlabel style={font=\footnotesize},'...
        'ylabel style={font=\footnotesize, anchor=near ticklabel},' ...
        'every axis y label/.style={at={(ticklabel cs:0.5)},rotate=90,anchor=center},'  ... Attempts to shift ylabel in a bit
        'ticklabel style={font=\scriptsize},' ...
        ... 'height=0.3\linewidth,'...
        ...' scaled y ticks = false,' ...
        ...' y tick label style={/pgf/number format/fixed},' ...
        ]);
end

end

