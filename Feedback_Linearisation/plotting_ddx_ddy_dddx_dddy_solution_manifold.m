
% Create modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(false);
end

% Goal of this script is to derive functions for ddx ddy d3x d3y for a system of constant dx dy. If we can find 
% solutions for ddx=ddy=dddx=dddy=0 then it IS possible to perfectly follow exact dx dy trajectories, PROVIDING
% there exists a solution in which theta_p evolves with zero mean over a full phi rotation.
syms  w2(t) w3(t) dx(t) dy(t) phi(t) theta_p(t) vx(t) vy(t) dphi(t) dtheta_p(t)
assumeAlso(phi(t), 'real');

R_EB = [cos(phi) -sin(phi);
            sin(phi) cos(phi)];
        
        
syms dx(t) dy(t)
syms dvx dvy real
dxdy = formula(R_EB*[vx;vy]);
ddxddy = diff(dxdy,t);
ddxddy = subs(ddxddy, [diff(vx) diff(vy)], [dvx dvy]);

vxvy = formula(R_EB'*[dx;dy]);
dvxdvy = formula(diff(vxvy,t));


% Substitute vx vy dvx
ddxddy = subs(ddxddy, [vx; vy; dvx], [vxvy; dvxdvy(1)]);
% Substitute dvy option 1
ddxddy = subs(ddxddy, dvy, subs(modelData.substituteParameters(modelData.pv.dvy), [vx; vy], vxvy));

% Substitute dvy option 2
% syms a b c d e f g h i real;
% dvyFun = a*w3 - vx*dphi - b*sin(theta_p)*dphi^2 + (c*w3 - d*vy + sin(theta_p)*(e*dphi^2 - f*dtheta_p^2 - g) + h*vx*dphi)/(cos(theta_p) + i);
% ddxddy = subs(ddxddy, dvy, subs(dvyFun, [vx; vy], vxvy));

ddxddy = subs(ddxddy, diff(phi(t)), dphi(t));

syms ddx ddy real;
sol = solve(subs([ddx;ddy] == ddxddy, [diff(dx); diff(dy)], [ddx; ddy]), [ddx; ddy]);
ddx = simplify(sol.ddx, 1000);
ddy = simplify(sol.ddy, 1000);
eqns = [ddx; ddy];


% Now need to find solutions for ddx(t)=0, ddy(t)=0.

% Make dx dy dphi time invariant, i.e. in steady state
syms Dx Dy Dphi t real;
eqns = subs(eqns, [dx dy dphi phi], [Dx Dy Dphi Dphi*t]);

% and equate to zero acceleration, i.e. ddx=0, ddy=0.
eqns = [0;0] == eqns;

% Extract Gamma
Gamma = rhs(eqns(1)/-sin(Dphi*t));

% Extract numerator, as it is this that must equal zero
[GammaNum,~] = numden(Gamma);


syms W3 real
% w3Fun = simplify(solve(GammaNum, w3)) % For method 1
% w3Fun = simplify(solve(subs(GammaNum, w3, W3), W3)) % For method 2

% Plot phase portrait of 2nd order ODE? Does this need to be 3D to include
% time?

syms w3 real;
[V] = odeToVectorField(subs(GammaNum, [dtheta_p w3], [diff(theta_p,t) diff(theta_p,t,2)]));

fun = matlabFunction(V);
toSolve = @(t,x) fun(0,1,1,x,t);

thetap_range = linspace(-0.1,0.1,50);
dthetap_range = linspace(-0.1,0.1,50);

opt = odeset;
opt.RelTol = 1e-12;
opt.Events = @thetapCrossingEventsFcn;

figure; hold on;
minMaxThetap = 2*pi;    
for i=1:numel(thetap_range)
    for j=1:numel(dthetap_range)
        [tout,yout] = ode45(toSolve, [0 2*pi], [thetap_range(i) dthetap_range(j)]);
%         plot(yout(:,1), yout(:,2));
        plot3(yout(:,1), yout(:,2),tout);
%         plot(tout,yout(:,1));
        minMaxThetap = min([minMaxThetap max(abs(yout(:,1)))]);
    end
end
minMaxThetap

xlim([-pi/2 pi/2]);
% ylim([-pi/2 pi/2]);


function [value,isterminal,direction] = thetapCrossingEventsFcn(t,y)
    value = abs(y(1)) - pi; % The value that we want to be zero
    isterminal = 1;  % Halt integration 
    direction = 0;   % The zero can be approached from either direction
end