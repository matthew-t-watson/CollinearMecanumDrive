function [x,fx] = newtonRaphson(f,x0)


coder.extrinsic('warning');
x = x0;
for i=2:20
    [fx,Jx] = f(x);
    
    x = x - fx/Jx;
    
    if abs(fx) < 1e-12
        return
    end
end

%warning('Newton Raphson failed to converge to a solution');

x = inf;

end

