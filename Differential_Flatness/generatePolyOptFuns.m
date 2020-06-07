function [polyOptFuns] = generatePolyOptFuns(order,derivToMin,conDerivDeg)
%GENERATEPOLYNOMIALOPTIMISATIONFUNCTIONS Function used to generate cost and
%constraint functions for the optimisation of polynomials, performed using
%YALMIP.

polyCoefs = sym('polyCoefs_', [order+1, 1], 'Real');
syms t real;

S = poly2sym(polyCoefs,t);

%% Crackle cost function and hessian
intCrackleSquared = int(diff(S,t,derivToMin+1)^2);
H = hessian(intCrackleSquared, polyCoefs);

% %% Velocity setpoint MPC cost
% syms v real;
% vCost = int((diff(S,t,1) - v)^2);
% vH = hessian(vCost, polyCoefs);

%% Derivatives of polynomial
SDerivatives = [];
for i=0:conDerivDeg
    SDerivatives = [SDerivatives; diff(S,t,i)];
end

% Convert to form Aeq*p=SDiffs
Aeq = jacobian(SDerivatives,polyCoefs);

%% Velocity crossings with vmax
polyOptFuns.findIntersectionOfVelocityConstraint = @(p,vMax) roots(polyder(p) - [zeros(1,order-1) vMax]);


%% Generate optimised functions
polyOptFuns.H = matlabFunction(H, 'Vars', t, 'File', 'generatedFunctions/HFun');
% polyOptFuns.vH = matlabFunction(vH, 'Vars', {t,v}, 'File', 'generatedFunctions/vHFun');
polyOptFuns.Aeq = matlabFunction(Aeq, 'Vars', t, 'File', 'generatedFunctions/AeqFun');
polyOptFuns.SDerivatives = matlabFunction(SDerivatives, 'Vars', {t polyCoefs}, 'File', 'generatedFunctions/SDerivativesFun');
polyOptFuns.numVar = numel(polyCoefs);

end

