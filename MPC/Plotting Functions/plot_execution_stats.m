function [ output_args ] = plot_execution_stats( varargin )

if nargin == 1
    res1 = varargin{1};
    
    figure;
    subplot(2,2,1), stairs(res1.t_exec), title('Execution time');
    subplot(2,2,2), stairs(res1.iterations), title('Iterations');
    subplot(2,2,3), histogram(res1.t_exec), title([res1.model ' model execution time distribution']);
    subplot(2,2,4), histogram(res1.iterations), title([res1.model ' model iteration distribution']);

    
elseif nargin == 2
    res1 = varargin{1};
    res2 = varargin{2};
    
    figure;
    subplot(3,2,1), stairs([res1.t_exec' res2.t_exec']), title('Execution time'), legend([res1.model ' Model'], [res2.model ' Model']);
    subplot(3,2,2), stairs([res1.iterations' res2.iterations']), title('Iterations'), legend([res1.model ' Model'], [res2.model ' Model']);
    subplot(3,2,3), histogram(res1.t_exec), title([res1.model ' model execution time distribution']);
    subplot(3,2,4), histogram(res1.iterations), title([res1.model ' model iteration distribution']);
    subplot(3,2,5), histogram(res2.t_exec), title([res2.model ' model execution time distribution']);
    subplot(3,2,6), histogram(res2.iterations), title([res2.model ' model iteration distribution']);
end

end

