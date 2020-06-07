
function pvdvuFun = generateDifferentialFlatnessFunctions(modelData)
%% Function to generate functions used for converting polynomials to state trajectories using flat variables x y phi

forceRegen = 1;

persistent pvdvuFunPrev modelDataPrev

if isequal(modelData,modelDataPrev) ...
        && ~isempty(pvdvuFunPrev) ...
        && ~forceRegen
    pvdvuFun = pvdvuFunPrev;
    return;
end

syms t real;
assumeAlso(t>=0);


syms phi(t);

syms lambda real;
syms theta_p_t(t);

syms S1_t(t) S2_t(t) S3_t(t);
assumeAlso(S3_t(t),'real');

phi_t = S3_t;
dphi_t = diff(phi_t);
ddphi_t = diff(dphi_t);

Rq = subs(modelData.pv.Rv(1:2,1:2),phi, phi_t);

x_t = S1_t - [1 0]*Rq*[0;1]*lambda*theta_p_t; % Small angle approximation of sin(theta_p)
dx_t = diff(x_t);
y_t = S2_t - [0 1]*Rq*[0;1]*lambda*theta_p_t;
dy_t = diff(y_t);


vx_t = [1 0]*transpose(Rq)*[dx_t; dy_t];
vy_t = [0 1]*transpose(Rq)*[dx_t; dy_t];

dvx_t = diff(vx_t);
dvy_t = diff(vy_t);
ddvx_t = diff(dvx_t);
ddvy_t = diff(dvy_t);



%% Solve internal dynamics for theta_p
syms ddtheta_p dtheta_p theta_p real;
subs(vy_t, {diff(theta_p_t,t,2), diff(theta_p_t,t), theta_p_t}, {ddtheta_p, dtheta_p, theta_p});
% assumeAlso(theta_p > -pi/2);
% assumeAlso(theta_p < pi/2);
internalDynamics = expand(simplify(expand(modelData.substituteParameters(modelData.stripTimeDependence(modelData.internalDynamics)))));

% Substitute for polynomials
syms(symvar(internalDynamics));
syms vy ddphi dvx real;
% if any(ismember(symvar(internalDynamics), vy))
    internalDynamics = subs(internalDynamics, {dphi, ddphi, dvx, dvy, vx, vy}, {dphi_t, ddphi_t, dvx_t, dvy_t, vx_t, vy_t});
% else
%     internalDynamics = subs(internalDynamics, {dphi, ddphi, dvx, dvy, vx}, {dphi_t, ddphi_t, dvx_t, dvy_t, vx_t});
% end


% Substitute differentials of theta_p_t for syms
internalDynamics = subs(internalDynamics, {diff(theta_p_t,t,2), diff(theta_p_t,t), theta_p_t}, {ddtheta_p dtheta_p theta_p});

% Replace trig with small angle approximations about theta_p=0
internalDynamics = subs(internalDynamics,{sin(theta_p), cos(theta_p)}, {taylor(sin(theta_p), 'Order', 2), taylor(cos(theta_p), 'Order', 2)});

% Remove first differentials of theta_p - should only remove one dthetap^2*theta_p centripetal term
internalDynamics = subs(internalDynamics,{dtheta_p}, {0});

internalDynamics = simplify(internalDynamics,1000);

% Calculate lambda required to cancel ddtheta_p term
lambdaSolved = solve(simplify(equationsToMatrix(internalDynamics, ddtheta_p)==0), lambda);

% Subsitute for lambda in internal dynamics and simplify to cancel ddtheta_p
internalDynamics = simplify(subs(internalDynamics, lambda, lambdaSolved),50);


% Solve for theta_p_t and derivatives
theta_p_solved = solve(internalDynamics, theta_p, 'Real', true); % To perform this solution in mathematica use the regexpr cos\((.*?)\) and Cos[$1]
theta_p_solved = theta_p_solved(1);
dtheta_p_t = diff(theta_p_solved,t);
ddtheta_p_t = diff(dtheta_p_t,t);

% Substitute theta_p into lambda - from flawed method
% lambdaSolved = subs(lambdaSolved, theta_p, theta_p_solved);

% Substitute lambda and theta_p into other states
x_t = subs(x_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
y_t = subs(y_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
dx_t = subs(dx_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
dy_t = subs(dy_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
vx_t = subs(vx_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
vy_t = subs(vy_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
dvx_t = subs(dvx_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
dvy_t = subs(dvy_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
ddvx_t = subs(ddvx_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});
ddvy_t = subs(ddvy_t, {lambda, theta_p_t}, {lambdaSolved, theta_p_solved});

generatePerturbationFunctions = true;
if generatePerturbationFunctions
    % Remembering that dS1=dxr, dS2=dyr, remove all higher differentials,
    % as dxr and dyr are time invariant. However, if dS1=dxr, then why
    % doesnt dS1=dphir?
    syms dxr dyr phir dphir real
    dxp = subs(dx_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    dyp = subs(dy_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    vxp = subs(vx_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    vyp = subs(vy_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    dvxp = subs(dvx_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    dvyp = subs(dvy_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    ddvxp = subs(ddvx_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    ddvyp = subs(ddvy_t, [diff(S1_t,t) diff(S2_t,t) S3_t diff(S3_t,t)], [dxr dyr phir dphir]);
    
    % Remove remaining higher derivatives of S
    dxp = subs(formula(dxp), formula([S1_t S2_t S3_t]), [0 0 0]);
    dyp = subs(formula(dyp), formula([S1_t S2_t S3_t]), [0 0 0]);
    vxp = subs(formula(vxp), formula([S1_t S2_t S3_t]), [0 0 0]);
    vyp = subs(formula(vyp), formula([S1_t S2_t S3_t]), [0 0 0]);
    dvxp = subs(formula(dvxp), formula([S1_t S2_t S3_t]), [0 0 0]);
    dvyp = subs(formula(dvyp), formula([S1_t S2_t S3_t]), [0 0 0]);
    ddvxp = subs(formula(ddvxp), formula([S1_t S2_t S3_t]), [0 0 0]);
    ddvyp = subs(formula(ddvyp), formula([S1_t S2_t S3_t]), [0 0 0]);
    
    dxp = simplify(dxp,1000);
    dyp = simplify(dyp,1000);
    vxp = simplify(vxp,1000);
    vyp = simplify(vyp,1000);
    dvxp = simplify(dvxp,1000);
    dvyp = simplify(dvyp,1000);
    ddvxp = simplify(ddvxp,1000);
    ddvyp = simplify(ddvyp,1000);
    
    matlabFunction(dxp, dyp, vxp, vyp, dvxp, dvyp, ddvxp, ddvyp ...
        , 'Vars', [dxr dyr phir dphir] ...
        , 'File', 'Feedback_Linearisation/generatedFunctions/calculateInertialVelocityPerturbations.m');
end


% Finally overwrite theta_p_t sym now it has been fully substituted in other equations
clear theta_p_t;
theta_p_t = theta_p_solved;

%% Calculate input in flat outputs
u = modelData.stripTimeDependence(modelData.substituteParameters(modelData.pv.inverseDynamics)).';
syms(symvar(u))
u = subs(u, [vx vy dphi theta_p dtheta_p dvx dvy ddphi ddtheta_p], [vx_t vy_t dphi_t theta_p_t dtheta_p_t dvx_t, dvy_t, ddphi_t, ddtheta_p_t]);


%% Substitute differentials of S
S1 = sym('S1_', [10 1], 'Real');
S2 = sym('S2_', [10 1], 'Real');
S3 = sym('S3_', [10 1], 'Real');
Snew = [S1 S2 S3];
Sold = [];
for i=0:9
    Sold = [Sold; diff(S1_t,t,i) diff(S2_t,t,i) diff(S3_t,t,i)];
end
Sold = formula(Sold);


pvdv = [x_t y_t phi_t theta_p_t vx_t vy_t dphi_t dtheta_p_t dvx_t dvy_t ddphi_t ddtheta_p_t]';

% pvdv = simplify(subs(formula(pvdv), Sold, Snew), 1000);
% u = simplify(subs(formula(u), Sold, Snew), 100);
pvdv = simplify(subs(formula(pvdv), Sold, Snew));
u = subs(formula(u), Sold, Snew);

%% Convert symbolic expressions to matlab functions
pvdvuFun = matlabFunction(pvdv,u, 'Vars', {Snew(:,1), Snew(:,2), Snew(:,3)}, 'Outputs', {'pvdv','u'}, 'File', 'Differential_Flatness/generatedFunctions/pvdvu', 'Optimize', true);


%% Generate code
pvuFun = matlabFunction(pvdv(1:8),u, 'Vars', {Snew(:,1), Snew(:,2), Snew(:,3)}, 'Outputs', {'pv','u'}, 'File', 'Differential_Flatness/generatedFunctions/pvu', 'Optimize', true);
% codegen pvu -d ./Differential_Flatness/codegen/pvu -c -args {zeros(size(Snew(:,1))) zeros(size(Snew(:,2))) zeros(size(Snew(:,3)))}


pvdvuFunPrev = pvdvuFun;
modelDataPrev = modelData;
end
