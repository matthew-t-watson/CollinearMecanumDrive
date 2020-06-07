

function [ out ] = model_derivation( generateBlocks )

syms t real;
syms m_p m_w I_pbx I_pby I_pbz I_wx I_wyz h_p l_1 l_2 l_3 l_4 r_w r_r g alpha_1 alpha_2 alpha_3 alpha_4 k_vr k_vw K_rw real;
syms x(t) y(t) phi(t) theta_p(t) theta_1(t) theta_2(t) theta_3(t) theta_4(t) omega_1(t) omega_2(t) omega_3(t) omega_4(t);
syms dx(t) dy(t) dtheta_p(t) dphi(t) dtheta_1(t) dtheta_2(t) dtheta_3(t) dtheta_4(t) domega_1(t) domega_2(t) domega_3(t) domega_4(t);
syms vx(t) vy(t);
syms ddx ddy ddphi ddtheta_p ddtheta_1 ddtheta_2 ddtheta_3 ddtheta_4 ddomega_1 ddomega_2 ddomega_3 ddomega_4 real;
syms dvx dvy real;
syms tau_1 tau_2 tau_3 tau_4 real;

assumeAlso(x(t), 'real');
assumeAlso(y(t), 'real');
assumeAlso(phi(t), 'real');
assumeAlso(theta_p(t), 'real');
assumeAlso(theta_1(t), 'real');
assumeAlso(theta_2(t), 'real');
assumeAlso(theta_3(t), 'real');
assumeAlso(theta_4(t), 'real');
assumeAlso(omega_1(t), 'real');
assumeAlso(omega_2(t), 'real');
assumeAlso(omega_3(t), 'real');
assumeAlso(omega_4(t), 'real');
assumeAlso(dx(t), 'real');
assumeAlso(dy(t), 'real');
assumeAlso(dphi(t), 'real');
assumeAlso(dtheta_p(t), 'real');
assumeAlso(dtheta_1(t), 'real');
assumeAlso(dtheta_2(t), 'real');
assumeAlso(dtheta_3(t), 'real');
assumeAlso(dtheta_4(t), 'real');
assumeAlso(domega_1(t), 'real');
assumeAlso(domega_2(t), 'real');
assumeAlso(domega_3(t), 'real');
assumeAlso(domega_4(t), 'real');
assumeAlso(vx(t), 'real');
assumeAlso(vy(t), 'real');
assumeAlso(m_p > 0);
assumeAlso(m_w > 0);
assumeAlso(I_pbx > 0);
assumeAlso(I_pby > 0);
assumeAlso(I_pbz > 0);
assumeAlso(I_wx > 0);
assumeAlso(I_wyz > 0);
assumeAlso(r_w > 0);
assumeAlso((alpha_1 > -pi/2 & alpha_1 < 0) | (alpha_1 < pi/2 & alpha_1 > 0));
assumeAlso((alpha_2 > -pi/2 & alpha_2 < 0) | (alpha_2 < pi/2 & alpha_2 > 0));
assumeAlso((alpha_3 > -pi/2 & alpha_3 < 0) | (alpha_3 < pi/2 & alpha_3 > 0));
assumeAlso((alpha_4 > -pi/2 & alpha_4 < 0) | (alpha_4 < pi/2 & alpha_4 > 0));

% Define number of wheels
nw = 4;

if nw == 3
    theta_i = {theta_1 theta_2 theta_3};
    dtheta_i = {dtheta_1 dtheta_2 dtheta_3};
    ddtheta_i = {ddtheta_1 ddtheta_2 ddtheta_3};
    omega_i = {omega_1 omega_2 omega_3};
    domega_i = {domega_1 domega_2 domega_3};
    ddomega_i = {ddomega_1 ddomega_2 ddomega_3};
    l_i = [l_1 l_2 l_3];
    alpha_i = [alpha_1 alpha_2 alpha_3];
    tau_i = [tau_1 tau_2 tau_3]';
elseif nw == 4
    theta_i = {theta_1 theta_2 theta_3 theta_4};
    dtheta_i = {dtheta_1 dtheta_2 dtheta_3 dtheta_4};
    ddtheta_i = {ddtheta_1 ddtheta_2 ddtheta_3 ddtheta_4};
    omega_i = {omega_1 omega_2 omega_3 omega_4};
    domega_i = {domega_1 domega_2 domega_3 domega_4};
    domega_i = {ddomega_1 ddomega_2 ddomega_3 ddomega_4};
    l_i = [l_1 l_2 l_3 l_4];
    alpha_i = [alpha_1 alpha_2 alpha_3 alpha_4];
    tau_i = [tau_1 tau_2 tau_3 tau_4]';
end
I_w = diag([I_wx I_wyz I_wyz]);
I_p = diag([I_pbx I_pby I_pbz]);


% Full generalised coordinates
if nw == 3
    q = {x; y; phi; theta_p; theta_1; theta_2; theta_3; omega_1; omega_2; omega_3;};
    dq = {dx; dy; dphi; dtheta_p; dtheta_1; dtheta_2; dtheta_3; domega_1; domega_2; domega_3};
    ddq = {ddx; ddy; ddphi; ddtheta_p; ddtheta_1; ddtheta_2; ddtheta_3; ddomega_1; ddomega_2; ddomega_3};
elseif nw == 4
    q = {x; y; phi; theta_p; theta_1; theta_2; theta_3; theta_4; omega_1; omega_2; omega_3; omega_4};
    dq = {dx; dy; dphi; dtheta_p; dtheta_1; dtheta_2; dtheta_3; dtheta_4; domega_1; domega_2; domega_3; domega_4};
    ddq = {ddx; ddy; ddphi; ddtheta_p; ddtheta_1; ddtheta_2; ddtheta_3; ddtheta_4; ddomega_1; ddomega_2; ddomega_3; ddomega_4};
end

% Reduced generalised coordinates
p = {x; y; phi; theta_p};
dp = {dx; dy; dphi; dtheta_p};
ddp = [ddx; ddy; ddphi; ddtheta_p];

% pv generalised coordinates
v = {vx; vy; dphi; dtheta_p};
dv = [dvx; dvy; ddphi; ddtheta_p];

% input
u = [tau_i];


% Now using convention of x is right, y is forward, z is up, all rotations
% are by right hand rule.

%% Define rotation matrices
% Rotation from intertial frame E to body attached frame B
R_EB = [cos(phi) -sin(phi) 0;
            sin(phi) cos(phi) 0;
            0 0 1];
sel = [eye(2); 0 0];
R_EB_2d = sel'*R_EB*sel;
                        
% Rotation from body attached frame B to pendulum rigid body frame P
R_BP = [1 0 0
        0 cos(theta_p) -sin(theta_p)
        0 sin(theta_p) cos(theta_p)];
        
% Rotation from body to wheel frame
for i=1:nw
    R_BW{i} = [1 0 0
               0 cos(theta_i{i}) -sin(theta_i{i})
               0 sin(theta_i{i}) cos(theta_i{i})];
end

% Rotation from body to non-rotating roller frame (acceptable simplification if roller is massless)
for i=1:nw
    R_BR{i} = [cos(alpha_i(i)) -sin(alpha_i(i)) 0;
            sin(alpha_i(i)) cos(alpha_i(i)) 0;
            0 0 1];
end
 
%% Velocities derivation
% Define body angular velocity
omega_b = [0; 0; dphi];

% Define pendulum angular velocity
omega_p = R_BP.'*omega_b + [dtheta_p; 0; 0];

% Define wheel angular velocity
for i=1:nw
    % Both of these expressions give identical results
    % omega_w{i} = R_BW{i}'*omega_b + [dtheta_i{i}; 0; 0];
    omega_w{i} = omega_b + [dtheta_i{i}; 0; 0];
end

% Define body frame velocities in terms of q
v_b = R_EB.'*[dx; dy; 0];

% Define pendulum translational velocities
v_p = R_BP.'*v_b + cross(omega_p, [0; 0; h_p]);

% Define wheel translational velocities
for i=1:nw
    % Both of these expressions give identical results
    % v_w{i} = R_BW{i}'*v_b + cross(omega_w{i}, [l_i(i); 0; 0]);
    v_w{i} = v_b + cross(omega_w{i}, [l_i(i); 0; 0]);
end

%% Derivation of constraints, inverse kinematics, and M(q)
for i=1:nw
    % Body frame velocity at center of wheel (W)
    v_Wb{i} = v_b + [0; dphi*l_i(i); 0];

    % Body frame velocity of roller contact point (C)
    v_Cb{i} = v_Wb{i} + [0; -r_w*-dtheta_i{i}; 0];

    % Body frame roller rotation axis u_p and transverse axis u_t
    u_p{i} = R_BR{i}*[1;0;0];
    u_t{i} = R_BR{i}*[0;1;0];

    % Contraints
    constraintNoSlip(i,1) = dot(formula(v_Cb{i}),u_p{i});
    constraintRolling(i,1) = dot(formula(v_Cb{i}),u_t{i}) - -r_r*domega_i{i};
end

% Solve no slip constraint for theta_i
for i=1:nw
    theta_iSolved(i,1) = solve(stripTimeDependence(constraintNoSlip(i)), stripTimeDependence(formula(dtheta_i{i})));
end

% Pfaffian constraint matrix
A = subs(equationsToMatrix(stripTimeDependence([constraintNoSlip; constraintRolling]), stripTimeDependence(formula([dx; dy; dphi; dtheta_p; dtheta_i'; domega_i']))),stripTimeDependence(formula(phi)),formula(phi));


%% Energies
% Translational kinetic energy
K_trans = 0.5*m_p*(v_p.'*v_p);
for i=1:nw
    K_trans = K_trans + 0.5*m_w*(v_w{i}.'*v_w{i});
end

% Rotational kinetic energy
K_rot = 0.5*omega_p.'*I_p*omega_p;
for i=1:nw
    K_rot = K_rot + 0.5*omega_w{i}.'*I_w*omega_w{i};
end

K_trans = simplify(K_trans);
K_rot = simplify(K_rot, 5); % Doesnt seem to simplify cos(x)^2+sin(x)^2=1 with less than 5 simplification steps

% Potential Energy
U = m_p*g*h_p*cos(theta_p);

% Total Energy
L = K_trans + K_rot - U;


%% Euler-Lagrange Derivation
% Generalised forces
Q_tau = [
    zeros(3,1);
    -sum(tau_i);
    tau_i;
    zeros(nw,1);
    ];

if nw == 3
    Q_fric = [
        [eye(2) zeros(2,1)]*R_EB*k_vr*[1/(-r_w+r_r);0;0]*dot([0;1;0],formula(R_BR{1}*[domega_1;0;0] + R_BR{2}*[domega_2;0;0] + R_BR{3}*[domega_3;0;0]));
        0;
        sum(k_vw*(dtheta_i - dtheta_p));
        -K_rw*dtheta_1 + k_vw*(dtheta_p - dtheta_1) + k_vr*dot([1;0;0],formula(R_BR{1}*[domega_1; 0; 0]));
        -K_rw*dtheta_2 + k_vw*(dtheta_p - dtheta_2) + k_vr*dot([1;0;0],formula(R_BR{2}*[domega_2; 0; 0]));
        -K_rw*dtheta_3 + k_vw*(dtheta_p - dtheta_3) + k_vr*dot([1;0;0],formula(R_BR{3}*[domega_3; 0; 0]));
        -k_vr*domega_i';
        ];
elseif nw == 4
    Q_fric = [
        [eye(2) zeros(2,1)]*R_EB*k_vr*[1/(-r_w+r_r);0;0]*dot([0;1;0],formula(R_BR{1}*[domega_1;0;0] + R_BR{2}*[domega_2;0;0] + R_BR{3}*[domega_3;0;0] + R_BR{4}*[domega_4;0;0]));
        0;
        sum(k_vw*(dtheta_i - dtheta_p));
        -K_rw*dtheta_1 + k_vw*(dtheta_p - dtheta_1) + k_vr*dot([1;0;0],formula(R_BR{1}*[domega_1; 0; 0]));
        -K_rw*dtheta_2 + k_vw*(dtheta_p - dtheta_2) + k_vr*dot([1;0;0],formula(R_BR{2}*[domega_2; 0; 0]));
        -K_rw*dtheta_3 + k_vw*(dtheta_p - dtheta_3) + k_vr*dot([1;0;0],formula(R_BR{3}*[domega_3; 0; 0]));
        -K_rw*dtheta_4 + k_vw*(dtheta_p - dtheta_4) + k_vr*dot([1;0;0],formula(R_BR{4}*[domega_4; 0; 0]));
        -k_vr*domega_i';
        ];
end

% Compute Lagrangian
lambda = sym('lambda', [size(A,1) 1], 'real');
model = diff(functionalDerivative(L,dq),t) - functionalDerivative(L,q) == A.'*lambda + Q_tau + Q_fric;

% Substitute diff(q,t) for dq and diff(dq,t) for ddq
model = subs(model, diff(q,t), dq);
model = subs(model, diff(dq,t), ddq);

%% Fitting model to standard form M(q)ddq + C(q,dq)dq + G(q) == A'lambda + Bu + Fdq
% Rearrange LHS into terms of inertia and coriolis matrix
out.qdq.Mq = equationsToMatrix(lhs(model), ddq);

% Test for symmetry
if ~isequal(simplify(out.qdq.Mq-out.qdq.Mq.'), sym(zeros(numel(q))))
    warning('Mq is asymmetric')
end

% Test for positive SEMIdefiniteness of Mq - expected as rollers are massless & inertialess
% if all(isAlways(eig(simplify(substituteParameters(out.qdq.Mq)))>-eps)) == false
%     warning('Mq is not positive semidefinite');
% end

% Derive C(q,dq) matrix using Christoffel symbols of Mq. This operation is
% very slow, but seems to just be due to the number of calls to
% functionalDerivative, i.e. no way no improve. Running this as a single
% thread profiled at 554s, running with the parfor at 212s.
for i = 1:size(out.qdq.Mq,1)
    parfor j = 1:size(out.qdq.Mq,1)
        Cqdq(i,j) = sym(0); % Required to set type of cell
        for k = 1:size(out.qdq.Mq,1)
            Cqdq(i,j) = Cqdq(i,j) + 0.5*( ...
                functionalDerivative(out.qdq.Mq(i,j),q{k}) ...
                + functionalDerivative(out.qdq.Mq(i,k),q{j}) ...
                - functionalDerivative(out.qdq.Mq(j,k),q{i})... 
                ) * dq{k};                
        end
    end
end
out.qdq.Cqdq = Cqdq;
clear Cqdq;

% Test for skew symmetry of dMq - 2Cqdq
% dMq_minus_2Cqdq = subs(diff(out.qdq.Mq,t) - 2*out.qdq.Cqdq, diff(q,t), dq);
% if ~isequal(simplify(dMq_minus_2Cqdq + dMq_minus_2Cqdq.'), sym(zeros(numel(q))))
%     warning('dMq-2Cqdq is not skew symmetric');
% end

% Derive input matrix B
out.qdq.B = equationsToMatrix(rhs(model), u);

if any(Q_fric ~= 0)
    % Derive friction matrix Fq
    temp = sym('temp',[numel(dq) 1]);
    out.qdq.F = equationsToMatrix(subs(rhs(model) - A.'*lambda, dq, temp), temp);
else
    out.qdq.F = sym(zeros(numel(q)));
end

% Derive gravity matrix Gq
out.qdq.Gq = formula(simplify(lhs(model) - out.qdq.Mq*ddq - out.qdq.Cqdq*dq));

% Gq should contain a single term
if nnz(formula(out.qdq.Gq)) > 1
    warning('Mq and Cqdq do not fully describe passive unconstrained Lagrangian');
end

% Package matrices and model
out.qdq.model = out.qdq.Mq*ddq + out.qdq.Cqdq*dq + out.qdq.Gq == out.qdq.F*dq + out.qdq.B*tau_i;


%% Convert model from generalised coordinates q to p
% Calculate null matrix such that AH=0
% Calculating the null matrix for a reordering of q into q =
% [theta_i x y phi theta_p] then swapping back to the original
% ordering yields an identity mapping for x y phi theta_p
out.pdp.H = null([A(:,(numel(p)+1):end) A(:,1:numel(p))]);
out.pdp.H = [out.pdp.H((end-(numel(p)-1)):end,:); out.pdp.H(1:numel(q)-numel(p),:)];

if ~isequal(simplify(A*out.pdp.H), sym(zeros(numel(q)-numel(p), numel(p))))
    error('H is not a basis for the nullspace of A');
end        

% Redefine Mp
out.pdp.Mp = simplify(out.pdp.H.'*out.qdq.Mq*out.pdp.H);

% Retest for symmetry
% if ~isequal(simplify(out.pdp.Mp-out.pdp.Mp.'), sym(zeros(numel(p))))
%     warning('Mp is asymmetric')
% end

% Retest for positive definiteness
% if all(isAlways(eig(simplify(substituteParameters(out.pdp.Mp)))>eps)) == false
%     warning('Mp is not positive definite');
% end

% Redefine Cqdq
out.pdp.Cpdp = simplify(out.pdp.H.'*out.qdq.Cqdq*out.pdp.H + out.pdp.H.'*out.qdq.Mq*subs(diff(out.pdp.H,t), diff(p,t), dp));

% Retest for skew symmetry of dMq - 2Cqdq
% dMp_minus_2Cpdp = subs(diff(out.pdp.Mp,t) - 2*out.pdp.Cpdp, diff(p,t), dp);
% if ~isequal(simplify(dMp_minus_2Cpdp + dMp_minus_2Cpdp.'), sym(zeros(numel(p))))
%     warning('dMp-2Cpdp is not skew symmetric');
% end

% Redefine gravity matrix
out.pdp.Gp = out.pdp.H.' * out.qdq.Gq;

% Redefine input matrix
out.pdp.Bp = simplify(out.pdp.H.' * out.qdq.B);

% Redefine friction matrix
out.pdp.Fp = simplify(out.pdp.H.' * out.qdq.F * out.pdp.H);

% % Build model
% out.pdp.model = out.pdp.Mp*ddp + out.pdp.Cpdp*dp + out.pdp.Gp == out.pdp.Fp*dp + out.pdp.Bp*tau_i;
% % Currently runs out of memory when inverting Mp without substituting parameters
% out.pdp.dynamics = inv(substituteParameters(out.pdp.Mp))*(out.pdp.Fp*dp + out.pdp.Bp*tau_i - out.pdp.Cpdp*dp - out.pdp.Gp);
% out.pdp.dpddp = [dp; out.pdp.dynamics];

% Solve no slip constraint for theta_i, and rolling constraint for omega_i
temp = sym('temp', [4 1]);
for i=1:nw
    theta_iSolved(i,1) = solve(subs(constraintNoSlip(i), dtheta_i(i), temp(i)), temp(i));
    omega_iSolved(i,1) = solve(subs(constraintRolling(i), domega_i(i), temp(i)), temp(i));
end
out.pdp.inverseKinematicsM = equationsToMatrix(subs(theta_iSolved, dp, temp), temp);
out.pdp.inverseKinematicsIncRollersM = equationsToMatrix(subs([theta_iSolved; omega_iSolved], dp, temp), temp);


% Calculate generalised momentums conjugate to external and shape variables
out.pdp.p_x = out.pdp.Mp(1:2,1:2)*dp(1:2) + out.pdp.Mp(1:2,3:4)*dp(3:4);
out.pdp.p_s = out.pdp.Mp(3:4,1:2)*dp(1:2) + out.pdp.Mp(3:4,3:4)*dp(3:4);

% Calculate normalised momentums
out.pdp.pi_x = inv(out.pdp.Mp(1:2,1:2)) * out.pdp.p_x;
out.pdp.pi_s = inv(out.pdp.Mp(3:4,1:2)) * out.pdp.p_s;

% Derivation method 2 for comparison
out.pdp.pi_x_2 = dp(1:2) + inv(out.pdp.Mp(1:2,1:2))*out.pdp.Mp(1:2,3:4)*dp(3:4);
out.pdp.pi_s_2 = dp(1:2) + inv(out.pdp.Mp(3:4,1:2))*out.pdp.Mp(3:4,3:4)*dp(3:4);

%% Convert model from generalised coordinates (q,dq,ddq) to (p,v,dv)
% Calculate null matrix such that AH=0
% Calculating the null matrix for a reordering of q into q =
% [theta_i x y phi theta_p] then swapping back to the original
% ordering yields an identity mapping for x y phi theta_p
out.pv.H = null([A(:,5:end) A(:,1:4)]);
out.pv.H = [out.pv.H(end-3:end,:); out.pv.H(1:numel(q)-numel(p),:)];

% Rotate dx dy to vx vy
out.pv.Rv = blkdiag(formula(R_EB_2d),sym(eye(2)));
out.pv.H = out.pv.H*out.pv.Rv;

if ~isequal(simplify(A*out.pv.H), sym(zeros(numel(q)-numel(p), numel(p))))
    error('H is not a basis for the nullspace of A');
end        

% Redefine Mp
out.pv.Mp = simplify(out.pv.H.'*out.qdq.Mq*out.pv.H);

% Retest for symmetry
% if ~isequal(simplify(out.pv.Mp-out.pv.Mp.'), sym(zeros(numel(p))))
%     warning('Mp is asymmetric')
% end

% Retest for positive definiteness
% if all(isAlways(eig(simplify(substituteParameters(out.pv.Mp)))>eps)) == false
%     warning('Mp is not positive definite');
% end

% Redefine Cqv
out.pv.Cpv = simplify(out.pv.H.'*out.qdq.Cqdq*out.pv.H + out.pv.H.'*out.qdq.Mq*subs(diff(out.pv.H,t), diff(p,t), out.pv.Rv*v));

% Retest for skew symmetry of dMp - 2Cpv
% dMp_minus_2Cpv = subs(diff(out.pv.Mp,t) - 2*out.pv.Cpv, diff(p,t), out.pv.Rv*v);
% if ~isequal(simplify(dMp_minus_2Cpv + dMp_minus_2Cpv.'), sym(zeros(numel(p))))
%     warning('dMp-2Cpv is not skew symmetric');
% end

% Redefine gravity matrix
out.pv.Gp = out.pv.H.'*out.qdq.Gq;

% Redefine input matrix
out.pv.B = simplify(out.pv.H.'*out.qdq.B);

% Calculate simplified input u
out.pv.Bu = colspace(out.pv.B);
out.pv.Htau = pinv(out.pv.Bu)*out.pv.B;
out.pv.Htausubs = double(substituteParameters(out.pv.Htau));

% Redefine friction matrix
out.pv.F = simplify(out.pv.H.'*out.qdq.F*out.pv.H);

% Redefine model
out.pv.model = out.pv.Mp*dv + out.pv.Cpv*v + out.pv.Gp == out.pv.F*v + out.pv.B*tau_i;
out.pv.dynamics = inv(out.pv.Mp)*(out.pv.F*v + out.pv.B*tau_i - out.pv.Cpv*v - out.pv.Gp);
out.pv.inverseDynamics = pinv(out.pv.B)*(out.pv.Mp*dv + out.pv.Cpv*v + out.pv.Gp - out.pv.F*v);
out.pv.dpdv = [out.pv.Rv*v; out.pv.dynamics];

% Redefine inverse kinematics in terms of v
out.pv.inverseKinematicsM = simplify(out.pdp.inverseKinematicsM * out.pv.Rv);
out.pv.inverseKinematicsIncRollersM = simplify(out.pdp.inverseKinematicsIncRollersM * out.pv.Rv);
out.pv.inverseKinematics = out.pv.inverseKinematicsM*v;
out.pv.inverseKinematicsIncRollers = out.pv.inverseKinematicsIncRollersM*v;

% Calculate generalised momentums conjugate to external and shape variables
out.pv.p_x = out.pv.Mp(1:3,1:3)*v(1:3) + out.pv.Mp(1:3,4)*v(4);
out.pv.p_s = out.pv.Mp(4,1:3)*v(1:3) + out.pv.Mp(4,4)*v(4);

% Calculate normalised momentums
out.pv.pi_x = inv(out.pv.Mp(1:3,1:3)) * out.pv.p_x;
out.pv.pi_s = pinv(out.pv.Mp(4,1:3)) * out.pv.p_s;

% Derivation method 2 for comparison
out.pv.pi_x_2 = v(1:3) + inv(out.pv.Mp(1:3,1:3))*out.pv.Mp(1:3,4)*v(4);
out.pv.pi_s_2 = v(1:3) + pinv(out.pv.Mp(4,1:3))*out.pv.Mp(4,4)*v(4);


% Define expression and function for calculation of dvy
out.pv.dvy_tau = substituteParameters(out.pv.dynamics(2));
state = sym('state',[8 1]);
out.pv.dvy_tau_fun = matlabFunction(subs(out.pv.dvy_tau, [p;v], state), 'Vars', {state, tau_i}, 'File', 'Feedback_Linearisation/generatedFunctions/dvy_tau');


% Arrange model in form d(p,v) = f(p,v) + g u
out.pv.f = [out.pv.Rv*v; inv(out.pv.Mp)*(out.pv.F*v - out.pv.Cpv*v - out.pv.Gp)];
out.pv.gtau = [zeros(4,nw); inv(out.pv.Mp)*out.pv.B];
out.pv.g = [zeros(4,3); inv(out.pv.Mp)*out.pv.Bu];

% Define error model with rotated Cartesian position error
e = sym('e_',[8,1]); e_u = sym('e_u_',[nw 1]);  xr = sym('xr_',[8,1]); tau_r = sym('tau_r_',[nw,1]);

% Define Cartesian error in body frame
phi_e_xr = xr(3) - e(3);
e1e2 = subs(formula(R_EB_2d).', phi, phi_e_xr)*[xr(1)-p(1);xr(2)-p(2)];
e1e2 = subs(e1e2, [p;v], xr-e);
e1 = e1e2(1); e2 = e1e2(2);

% Define dynamics 
f_xr = subs(out.pv.dpdv, [p;v], xr);
f_xr = subs(f_xr, tau_i, tau_r);
f_xr_mns_e = subs(out.pv.dpdv, [p;v], xr-e);
f_xr_mns_e = subs(f_xr_mns_e, tau_i, tau_r-e_u);

% Define integral errors
syms e_x_int e_y_int e_phi_int real
e_z = blkdiag(subs(formula(R_EB_2d).', phi, phi_e_xr), 1) * [e_x_int; e_y_int; e_phi_int];

% Define error dynamics
out.pv.de = [
    -e_z(2)*f_xr_mns_e(3) + e1; 
    e_z(1)*f_xr_mns_e(3) + e2; 
    e(3);
    e2*f_xr_mns_e(3) + cos(phi_e_xr)*f_xr(1) + sin(phi_e_xr)*f_xr(2) - cos(phi_e_xr)*f_xr_mns_e(1) - sin(phi_e_xr)*f_xr_mns_e(2);
    -e1*f_xr_mns_e(3) - sin(phi_e_xr)*f_xr(1) + cos(phi_e_xr)*f_xr(2) + sin(phi_e_xr)*f_xr_mns_e(1) - cos(phi_e_xr)*f_xr_mns_e(2);
    f_xr(3:8) - f_xr_mns_e(3:8)
    ];

% Linearise error dynamics about e=0
out.pv.Ae = subs(jacobian(out.pv.de, [e_x_int;e_y_int;e_phi_int;e]), [e_x_int; e_y_int; e_phi_int; e;e_u], [zeros(11,1); zeros(nw,1)]);
out.pv.Be = subs(jacobian(out.pv.de, e_u), [e_x_int; e_y_int; e_phi_int; e;e_u], [zeros(11,1); zeros(nw,1)]);

out.pv.Ae_fun = matlabFunction(simplify(substituteParameters(out.pv.Ae),100), 'Vars', {xr, tau_r}, 'File', 'Differential_Flatness/generatedFunctions/TVLQR_A_fun');
out.pv.Be_fun = matlabFunction(simplify(substituteParameters(out.pv.Be),100), 'Vars', {xr, tau_r}, 'File', 'Differential_Flatness/generatedFunctions/TVLQR_B_fun');
out.pv.e_fun = matlabFunction(subs([subs(e_z, e, xr-[p;v]); formula(R_EB_2d.')*[xr(1)-p(1);xr(2)-p(2)]; xr(3:8)-[p(3:4);v]], [p;v], state), 'Vars', {state,xr,[e_x_int;e_y_int;e_phi_int]}, 'File', 'Differential_Flatness/generatedFunctions/TVLQR_e_fun');

%% Feedback linearisation
% Uses the fully parametrised model, using Pathak's method but for the more general case
% This method should work with assymetric wheel configurations, odd roller angles etc.

% Calculate new input matrix P to simplify the input vector fields
out.pv.P = out.pv.g([5 7 8],:);

% New input vector fields g_hat - too complex to invert P without some substitutions
out.pv.gHat = [
    zeros(4,3);
    1 0 0;
    out.pv.g(6,:)*simplify(inv(substituteParameters(out.pv.P, true)));
    0 1 0;
    0 0 1];

% Calculate feedback linearising input in x
w = sym('w', [3 1]);
out.pv.uFB = [
    w(1) - out.pv.f(5);
    (w(2) - out.pv.f(7));
    w(3) - out.pv.f(8);
    ];

out.pv.fNew = [
    out.pv.f(1:4);
    0;
    out.pv.f(6) - out.pv.gHat(6,1)*out.pv.f(5) - out.pv.gHat(6,2)*out.pv.f(7) - out.pv.gHat(6,3)*out.pv.f(8);
    0;
    0];

% Calculate change of coordinates z=T(x)
x = [p;v];
out.pz.T = [
    x(1);
    x(2);
    x(3);
    x(4);
    x(5);
    x(6) - x(5)*out.pv.gHat(6,1) - x(7)*out.pv.gHat(6,2) - x(8)*out.pv.gHat(6,3);
    x(7);
    x(8);
    ];

% and inverse change of coordinates x=Tinv(z)
z = sym('z', [8 1], 'real');
out.pz.Tinv = [
    z(1);
    z(2);
    z(3);
    z(4);
    z(5);
    z(6) + subs(z(5)*out.pv.gHat(6,1) + z(7)*out.pv.gHat(6,2) + z(8)*out.pv.gHat(6,3), x(4), z(4));
    z(7);
    z(8);
    ];


% Calculate new drift and input vector fields in z
out.pz.f = subs([
    cos(z(3))*z(5) - sin(z(3))*(z(6) + z(5)*out.pv.gHat(6,1) + z(7)*out.pv.gHat(6,2) + z(8)*out.pv.gHat(6,3));
    sin(z(3))*z(5) + cos(z(3))*(z(6) + z(5)*out.pv.gHat(6,1) + z(7)*out.pv.gHat(6,2) + z(8)*out.pv.gHat(6,3));
    z(7)
    z(8);
    0;
    out.pv.f(6) - out.pv.f(5)*out.pv.gHat(6,1) - out.pv.f(7)*out.pv.gHat(6,2) - out.pv.f(8)*out.pv.gHat(6,3) - z(5)*diff(out.pv.gHat(6,1),t) - z(7)*diff(out.pv.gHat(6,2),t) - z(8)*diff(out.pv.gHat(6,3),t);
    0;
    0;
    ], x, out.pz.Tinv);

out.pz.g = [
    0 0 0
    0 0 0
    0 0 0
    0 0 0
    1 0 0
    0 0 0
    0 1 0
    0 0 1
    ];

% Zero dynamics should be calculated by setting dz=0 for controlled states,
% ie dthetap=dphi=w=0
% zeroDynamics = subs(substituteParameters(subs(out.pz.f, [k_vr, k_vw, K_rw], [0 0 0])), z([3 4 5 7 8]), zeros(5,1));
zeroDynamics = subs(out.pz.f, [z([5 7 8]); w], zeros(6,1));


% Calculate feedback linearising input in z
out.pz.uFB = subs(out.pv.uFB, [p;v], out.pz.Tinv);

% Derive expressions for dvy with and without acceleration due to rotation in terms of x
syms dvy real;
out.pv.dvy = out.pv.f(6) - out.pv.gHat(6,1)*out.pv.f(5) - out.pv.gHat(6,2)*out.pv.f(7) - out.pv.gHat(6,3)*out.pv.f(8) + out.pv.gHat(6,1)*w(1) + out.pv.gHat(6,2)*w(2) + out.pv.gHat(6,3)*w(3);

% Create functions to return evaluation of fdvy - dvy for given
% state and input - used to numerically solve for theta_p_ss, i.e.
% f_dvy^-1
state = sym('state',[8 1]);
fun = subs(-dvy + substituteParameters(out.pv.dvy), x, state);
dFun = jacobian(fun,state(4));
out.pv.f_solve_fdvy_for_theta_p_x = matlabFunction(fun, dFun, 'Vars', {state,w,dvy}, 'Outputs', {'fun','dFun'}, 'File', 'Feedback_Linearisation/generatedFunctions/f_solve_fdvy_theta_p_x');

% Define steady state (dtheta_p=w3=0) dvy's
syms dvy_ss real;
out.pv.dvy_ss = subs(substituteParameters(out.pv.dvy), {w(3) dtheta_p}, {0 0});

% Convert to function
state = sym('state',[8 1]);
out.pv.dvy_ss_fun = matlabFunction(formula(subs(substituteParameters(out.pv.dvy_ss), x, state)), 'Vars', {state,w}, 'Outputs', {'dvy_ss'}, 'File', 'Feedback_Linearisation/generatedFunctions/dvy_ss_fun');

% Define steady state (constant dvy) derivative of dvy
% This should capture variation of dvy for a given theta_p due to
% dvx and ddphi
syms dtheta_p_ss real;
out.pv.ddvy_ss = subs(diff(out.pv.dvy_ss,t), diff(theta_p), dtheta_p_ss);
out.pv.ddvy_ss = subs(out.pv.ddvy_ss, [diff(vx) diff(dphi)], [w(1) w(2)]);

syms ddvy real;
out.pv.dtheta_p_ss = solve(ddvy==out.pv.ddvy_ss, dtheta_p_ss);

if nw==4

    %% Velocity controller (body frame), constrained theta_p
    syms Kv Kdphi Kr Kw1 Kw2 theta_p_max w1_max w2_max theta_pr fss_minus1_dvy0 vxr vyr dphir K_slow_dtheta_p K_slow_theta_p real;
    body_vel_control_dtheta_pr = -subs(out.pv.dtheta_p_ss, {theta_p, ddvy}, {theta_pr, 0})*(theta_p_max^2 - theta_pr^2) / (fss_minus1_dvy0*theta_pr - theta_p_max^2) ...
        - Kr*(theta_pr - fss_minus1_dvy0)*(fss_minus1_dvy0*theta_pr - theta_p_max^2) ...
        - ((theta_p_max^2-theta_pr^2)^2 * subs(out.pv.dvy_ss,theta_p,theta_pr)*Kv*(vyr-vy)) / ((fss_minus1_dvy0*theta_pr - theta_p_max^2)*(theta_pr - fss_minus1_dvy0));
    body_vel_control_dw1 = -Kw1*w(1) + Kv*(vxr-vx)*(w1_max^2 - w(1)^2)^2;
    body_vel_control_dw2 = -Kw2*w(2) + Kdphi*(dphir-dphi)*(w2_max^2 - w(2)^2)^2;

    % Slow response
    body_vel_control_dtheta_pr = body_vel_control_dtheta_pr * exp(-K_slow_dtheta_p*abs(dtheta_p) - K_slow_theta_p*abs(theta_p-theta_pr));

    out.pv.body_vel_control_dw1_dw2_dtheta_pr_fun = matlabFunction( ...
        formula(subs(formula(body_vel_control_dtheta_pr), x, state)), ...
        formula(subs(formula(body_vel_control_dw1), x, state)), ...
        formula(subs(formula(body_vel_control_dw2), x, state)), ...
    'Vars', {state w Kv Kdphi Kr Kw1 Kw2 theta_p_max w1_max w2_max theta_pr fss_minus1_dvy0 vxr vyr dphir K_slow_dtheta_p K_slow_theta_p}, 'Outputs', {'dtheta_pr' 'dw1' 'dw2'}, 'File', 'Feedback_Linearisation/generatedFunctions/body_vel_control_dw1_dw2_dtheta_pr_fun', 'Optimize', false);


    %% Velocity controller (inertial frame), constrained theta_p   
    syms Kv Kdphi Kr Kw1 Kw2 theta_p_max w1_max w2_max theta_pr fss_minus1_dvy_mvxdphi dxr dyr dphir real;     
    inertial_vel_control_dtheta_pr = -subs(out.pv.dtheta_p_ss, {theta_p, ddvy}, {fss_minus1_dvy_mvxdphi, -w(1)*x(7) - w(2)*x(5)})*(theta_p_max^2 - theta_pr^2) / (fss_minus1_dvy_mvxdphi*theta_pr - theta_p_max^2) ...
        + exp(-K_slow_dtheta_p*abs(dtheta_p) - K_slow_theta_p*abs(theta_p-theta_pr))*( ...
            - Kr*(theta_pr - fss_minus1_dvy_mvxdphi)*(fss_minus1_dvy_mvxdphi*theta_pr - theta_p_max^2) ...
            - ((theta_p_max^2-theta_pr^2)^2 * (subs(out.pv.dvy_ss, theta_p, theta_pr) + vx*dphi)*Kv*(vyr-vy)) / ((fss_minus1_dvy_mvxdphi*theta_pr - theta_p_max^2)*(theta_pr - fss_minus1_dvy_mvxdphi)) ...
        );

    %inertial_vel_control_dw1 = (dphi*out.pv.dvy_ss + vy*w(2)) -Kw1*(w(1) - dphi*vy) + Kv*(vxr-vx)*(w1_max - w(1) + vy*dphi)^2*(w1_max + w(1) - vy*dphi)^2 / w1_max;
    inertial_vel_control_dw1 = (dphi*out.pv.dvy_ss + vy*w(2)) -Kw1*(w(1) - dphi*vy) + Kv*(vxr-vx)*(w1_max - w(1) + vy*dphi)^2*(w1_max + w(1) - vy*dphi)^2 / w1_max;
    inertial_vel_control_dw2 = -Kw2*w(2) + Kdphi*(dphir-dphi)*(w2_max^2 - w(2)^2)^2;

    % Substitute vxr for dxr etc
    inertial_vel_control_dtheta_pr = subs(inertial_vel_control_dtheta_pr, [vxr; vyr], R_EB_2d.'*[dxr;dyr]);
    inertial_vel_control_dw1 = subs(inertial_vel_control_dw1, [vxr; vyr], R_EB_2d.'*[dxr;dyr]);
    inertial_vel_control_dw2 = subs(inertial_vel_control_dw2, [vxr; vyr], R_EB_2d.'*[dxr;dyr]);        


    out.pv.inertial_vel_control_dw1_dw2_dtheta_pr_fun = matlabFunction( ...
        formula(subs(formula(inertial_vel_control_dtheta_pr), x, state)), ...
        formula(subs(formula(inertial_vel_control_dw1), x, state)), ...
        formula(subs(formula(inertial_vel_control_dw2), x, state)), ...
    'Vars', {state w Kv Kdphi Kr Kw1 Kw2 theta_p_max w1_max w2_max theta_pr dxr dyr dphir fss_minus1_dvy_mvxdphi K_slow_dtheta_p K_slow_theta_p}, 'Outputs', {'dtheta_pr' 'dw1' 'dw2'}, 'File', 'Feedback_Linearisation/generatedFunctions/inertial_vel_control_dw1_dw2_dtheta_pr_fun', 'Optimize', true);


    % Inertial velocity controller with differential flatness derived perturbations
    syms Kvx Kvy Kdphi Kr Kw1 Kw2 theta_p_max w1_max w2_max theta_pr fss_minus1_dvy_f_dvyp dxr dyr dphir real;    

    % Circular dependency here
    [dxp, dyp, vxp, vyp, dvxp, dvyp, ddvxp, ddvyp] = calculateInertialVelocityPerturbations(dxr, dyr, phi, dphir);

    inertial_vel_control_dtheta_pr = ...
        -subs(out.pv.dtheta_p_ss, {theta_p, ddvy}, {fss_minus1_dvy_f_dvyp, ddvyp})*(theta_p_max^2 - theta_pr^2) / (fss_minus1_dvy_f_dvyp*theta_pr - theta_p_max^2) ...
        + exp(-K_slow_dtheta_p*abs(dtheta_p) - K_slow_theta_p*abs(theta_p-theta_pr))*( ...
            - Kr*(theta_pr - fss_minus1_dvy_f_dvyp)*(fss_minus1_dvy_f_dvyp*theta_pr - theta_p_max^2) ...
            - ((theta_p_max^2-theta_pr^2)^2 * (subs(out.pv.dvy_ss, theta_p, theta_pr) - dvyp)*Kvy*(vyr+vyp-vy)) / ((fss_minus1_dvy_f_dvyp*theta_pr - theta_p_max^2)*(theta_pr - fss_minus1_dvy_f_dvyp)) ...
        );

    inertial_vel_control_dw1 = ddvxp - Kw1*(w(1) - dvxp) + Kvx*(vxr+vxp-vx)*(w1_max+dvxp - w(1))^2*(w1_max - dvxp + w(1))^2 / w1_max^2;
    inertial_vel_control_dw2 = -Kw2*w(2) + Kdphi*(dphir-dphi)*(w2_max^2 - w(2)^2)^2;

    % Substitute vxr for dxr etc
    inertial_vel_control_dtheta_pr = subs(inertial_vel_control_dtheta_pr, [vxr; vyr], R_EB_2d.'*[dxr;dyr]);
    inertial_vel_control_dw1 = subs(inertial_vel_control_dw1, [vxr; vyr], R_EB_2d.'*[dxr;dyr]);
    inertial_vel_control_dw2 = subs(inertial_vel_control_dw2, [vxr; vyr], R_EB_2d.'*[dxr;dyr]);        


    out.pv.inertial_vel_control_dw1_dw2_dtheta_pr_fun = matlabFunction( ...
        simplify(subs(formula(inertial_vel_control_dtheta_pr), formula(vertcat(x{:})), state)), ...
        simplify(subs(formula(inertial_vel_control_dw1), formula(vertcat(x{:})), state)), ...
        simplify(subs(formula(inertial_vel_control_dw2), formula(vertcat(x{:})), state)), ...
        'Vars', {state w Kvx Kvy Kdphi Kr Kw1 Kw2 theta_p_max w1_max w2_max theta_pr dxr dyr dphir fss_minus1_dvy_f_dvyp K_slow_dtheta_p K_slow_theta_p}, ...
        'Outputs', {'dtheta_pr' 'dw1' 'dw2'}, ...
        'File', 'Feedback_Linearisation/generatedFunctions/inertial_vel_control_2_dw1_dw2_dtheta_pr_fun', ...
        'Optimize', true);


    %% Position controller
    syms K_vr K_p K_dphir K_phi v_max dphi_max  xr yr phir K_slow real;        
    dxdy = formula(R_EB_2d*[x(5); x(6);]);
    ddxr = -K_vr*dxr + (v_max^2 - dxr^2 - dyr^2)^2 * K_p*(xr - x(1));
    ddyr = -K_vr*dyr + (v_max^2 - dxr^2 - dyr^2)^2 * K_p*(yr - x(2));
    ddphir = -K_dphir*dphir + (dphi_max^2 - dphir^2)^2 * K_phi*(phir - x(3));

    ddxr = ddxr * exp(-K_slow * abs(dxdy(1) - dxr));
    ddyr = ddyr * exp(-K_slow * abs(dxdy(2) - dyr));
    ddphir = ddphir * exp(-K_slow * abs(x(7) - dphir));

    out.pv.inertial_pos_control_ddxr_ddyr_ddphir_fun = matlabFunction( ...
        subs(ddxr, x, state), ...
        subs(ddyr, x, state), ...
        subs(ddphir, x, state), ...
    'Vars', {state K_vr K_p K_dphir K_phi v_max dphi_max dxr dyr dphir xr yr phir K_slow}, 'Outputs', {'ddxr' 'ddyr' 'ddphir'}, 'File', 'Feedback_Linearisation/generatedFunctions/inertial_pos_control_ddxr_ddyr_ddphir_fun', 'Optimize', true);
end

%% Nonlinear controllability
runNonlinearControllability = false;
if runNonlinearControllability
    % Put system into nonlinear input-affine form dx = f(x) + sum_{j=1}^4 g_j(x)u_j
    x = sym('x',[8 1],'real');
    f = substituteParameters(subs([out.pv.Rv*v; inv(out.pv.Mp)*(out.pv.F*v - out.pv.Cpv*v - out.pv.Gp)], [p;v], x));
    g = substituteParameters(subs([zeros(4,3); (inv(out.pv.Mp)*out.pv.Bu)], [p;v], x));
%     f = substituteParameters(subs(subs([out.pv.Rv*v; inv(out.pv.Mp)*(out.pv.F*v - out.pv.Cpv*v - out.pv.Gp)], [p;v], x),[h_p k_vw k_vr],[0 0 0]));
%     g = substituteParameters(subs(subs([zeros(4,3); (inv(out.pv.Mp)*out.pv.Bu)], [p;v], x),[h_p k_vw k_vr],[0 0 0]));
    f = subs(f, [p;v], x);
    g = subs(g, [p;v], x);

    % Define Lie bracket operation
    lb = @(g1,g2,x) jacobian(g2,x)*g1 - jacobian(g1,x)*g2;
    
    
    % Confirm G_0 is the involutive closure of G - not the case unless dvx
    % and ddphi are decoupled
    lieBracket(g,g,x)
    
    Q_0 = g;
    Q_0_closure = Q_0;
    Q_1 = [Q_0_closure lb(f,g(:,1),x) lb(f,g(:,2),x) lb(f,g(:,3),x)];
    Q_1_closure = [Q_1 lieBracket(Q_1,Q_1,x)];
    
    % Controllability indices
    r_0 = rank(Q_0);
    r_1 = rank(Q_1) - rank(Q_0);
    

    % Strong accessibility / STLA
    Delta{1} = [f g];
    disp(['rank(Delta_1) = ' num2str(rank(Delta{1}))]);
    for i=2:100
        Delta{i} = [Delta{i-1} lieBracket(Delta{1},Delta{i-1},x)];        
        disp(['rank(Delta_' num2str(i) ') = ' num2str(rank(Delta{i}))]);
        if rank(Delta{i}) == rank(Delta{i-1})
            break;
        end
    end
end


%% Internal dynamics derivation
% Eliminate tau by subtracting second and fourth expressions
out.internalDynamics = collect(out.pv.model(2)*r_w - out.pv.model(4), tau_i);

if any(ismember(tau_i, symvar(out.internalDynamics)))
    error('Internal dynamics still contain tau');
end


%% Generate C code
codegen f_solve_fdvy_theta_p_x  -d ./Feedback_Linearisation/codegen/f_solve_fdvy_theta_p_x -c -args {zeros(8,1), zeros(3,1), 0}

temp = sym('temp', [8 1]);
matlabFunction(subs(substituteParameters(out.pz.T), x, temp), 'Vars', {temp}, 'Outputs', {'z'}, 'File', 'Feedback_Linearisation/generatedFunctions/T_x_to_z');
matlabFunction(substituteParameters(out.pz.uFB), 'Vars', {z,w}, 'Outputs', {'v'}, 'File', 'Feedback_Linearisation/generatedFunctions/uFB');


vin = sym('vin', [3 1]);
matlabFunction(subs(inv(substituteParameters(out.pv.P))*vin, x, substituteParameters(out.pz.Tinv)), 'Vars', {z,vin}, 'Outputs', {'u'}, 'File', 'Feedback_Linearisation/generatedFunctions/Pz_v_to_u');

     
codegen T_x_to_z -d ./Feedback_Linearisation/codegen/T_x_to_z -c -args {zeros(8,1)}
codegen uFB -d ./Feedback_Linearisation/codegen/uFB -c -args {zeros(8,1), zeros(3,1)}
codegen Pz_v_to_u -d ./Feedback_Linearisation/codegen/Pz_v_to_u -c -args {zeros(8,1), zeros(3,1)}
codegen dvy_ss_fun -d ./Feedback_Linearisation/codegen/dvy_ss -c -args {zeros(8,1), zeros(3,1)}
codegen body_vel_control_dw1_dw2_dtheta_pr_fun -d ./Feedback_Linearisation/codegen/body_vel_control_dw1_dw2_dtheta_pr_fun -c -args {zeros(8,1) zeros(3,1) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
codegen inertial_vel_control_dw1_dw2_dtheta_pr_fun -d ./Feedback_Linearisation/codegen/inertial_vel_control_dw1_dw2_dtheta_pr_fun -c -args {zeros(8,1) zeros(3,1) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}
codegen inertial_pos_control_ddxr_ddyr_ddphir_fun -d ./Feedback_Linearisation/codegen/inertial_pos_control_ddxr_ddyr_ddphir_fun -c -args {zeros(8,1) 0 0 0 0 0 0 0 0 0 0 0 0 0}
codegen dvy_tau -d ./Feedback_Linearisation/codegen/dvy_tau_fun -c -args {zeros(8,1) zeros(nw,1)}



%% Generate optimised simulink blocks and matlab functions
stateInput = sym('stateInput', [8 1]);
if generateBlocks
    % Create matlab function for pv dynamics model
    out.dpdv = matlabFunction(subs(substituteParameters(out.pv.dpdv), [p;v], stateInput) ...
        , 'vars',   {stateInput, tau_i} ...
        , 'outputs', {'dpdv'});    
    
    % Create/open simulink library
    if ~exist('model_library', 'file')
        new_system  ('model_library', 'Library');
    else
        load_system('model_library');
    end
    set_param('model_library','Lock','off');
    
%     % Create pdp model block 
%     matlabFunctionBlock('model_library/dynamics_dpddp', subs(substituteParameters(out.pdp.dpddp), [p;dp], stateInput) ...
%         , 'vars',   {stateInput, tau_i} ...
%         , 'outputs', {'dpddp'});
    
    % Create pv model block 
    matlabFunctionBlock('model_library/dynamics_dqdv', subs(substituteParameters(out.pv.dpdv), [p;v], stateInput) ...
        , 'vars',   {stateInput, tau_i} ...
        , 'outputs', {'dpdv'});
            
    % Create pv inverse kinematics block
    matlabFunctionBlock('model_library/qv_inverse_kinematics',subs(substituteParameters(out.pv.inverseKinematics), [p;v], stateInput) ...
        , 'vars',   {stateInput} ...
        , 'outputs', {'dtheta_i'});
    
%     % Create zeta->u block
%     matlabFunctionBlock('model_library/pz_zeta_to_u', subs(substituteParameters(out.pz.uFB), [p;z], stateIn) ...
%         , 'vars',   {stateIn, zeta} ...
%         , 'outputs', {'u'});

    % Create feedback linearising input block
    matlabFunctionBlock('model_library/uFB_z',substituteParameters(out.pz.uFB) ...
        , 'vars',   {z,w} ...
        , 'outputs', {'v'});
    
    % Create x->z transform z=T(x)
    matlabFunctionBlock('model_library/T_x_to_z',subs(substituteParameters(out.pz.T), x, stateInput) ...
        , 'vars',   {stateInput} ...
        , 'outputs', {'z'});    
    
%     % Create z->x transform x=Tinv(z)
%     matlabFunctionBlock('model_library/T_z_to_x',substituteParameters(out.pz.Tinv) ...
%         , 'vars',   {z} ...
%         , 'outputs', {'x'});
    
%     % Create u->v mapping function v=Pu in terms of x
%     u = sym('u', [3 1], 'real');
%     matlabFunctionBlock('model_library/Px_u_to_v',subs(substituteParameters(out.pv.P*u), x, stateInput) ...
%         , 'vars',   {stateInput, u} ...
%         , 'outputs', {'v'});
    
%     % Create u->v mapping function v=Pu in terms of z
%     matlabFunctionBlock('model_library/Pz_u_to_v',subs(substituteParameters(out.pv.P*u), x, substituteParameters(out.pz.Tinv)) ...
%         , 'vars',   {z, u} ...
%         , 'outputs', {'v'});
    
%     % Create v->u mapping function v=Pu in terms of x
%     vin = sym('vin', [3 1], 'real');
%     matlabFunctionBlock('model_library/Px_v_to_u',subs(inv(substituteParameters(out.pv.P)*vin), x, stateInput) ...
%         , 'vars',   {stateInput, vin} ...
%         , 'outputs', {'u'});
    
    % Create v->u mapping function v=Pu in terms of z
    vin = sym('vin', [3 1], 'real');
    matlabFunctionBlock('model_library/Pz_v_to_u',subs(inv(substituteParameters(out.pv.P))*vin, x, substituteParameters(out.pz.Tinv)) ...
        , 'vars',   {z, vin} ...
        , 'outputs', {'u'});
            
    save_system ('model_library',[],'OverwriteIfChangedOnDisk',true);
    close_system('model_library');
end

%% Generate linear system
dqdvSubbed = subs(subs(substituteParameters(out.pv.dpdv), [p;v], stateInput), {cos(phi), sin(phi)}, {1 0});
A = double(subs(jacobian(dqdvSubbed, stateInput), [stateInput; tau_i], zeros(8+nw,1)));
B = double(subs(jacobian(dqdvSubbed, tau_i), [stateInput; tau_i], zeros(8+nw,1)));
C = eye(8);

out.linsys = ss(A,B,C,0);

%% Store function handles for later use
out.substituteAlphas = @(x) (substituteAlphas(x));
out.substituteParameters = @(x) (substituteParameters(x));
out.removeWheelMassInertiaTerms = @(x) (removeWheelMassInertiaTerms(x));
out.stripTimeDependence = @(x) (stripTimeDependence(x));

end

% Function to calculate all possible Lie brackets of two distributions
function out = lieBracket(F,G,x,depth)

    if ~exist('depth','var')
        depth = 1;
    end

    % Define Lie bracket operator
    lb = @(g1,g2,x) jacobian(g2,x)*g1 - jacobian(g1,x)*g2;

    out = sym([]);
    for i=1:size(F,2)
        for j=i+1:size(G,2)
            out = [out lb(F(:,i),G(:,j),x)];
            if depth>1
                for k=1:depth-1
                    out = [out lb(out(:,end),G(:,j),x)];
                end
            end
        end
    end
end


function [out] = substituteParameters(in, simplificationForInversion)

    if ~exist('simplificationForInversion', 'var')
        simplificationForInversion = false;
    end

    syms m_p m_w I_pbx I_pby I_pbz I_wx I_wyz h_p l_1 l_2 l_3 l_4 r_w r_r g alpha_1 alpha_2 alpha_3 alpha_4 k_vw k_vr K_rw real;
    names={}; values = {};
    names{end+1} = alpha_1; values{end+1} = pi/4;
    names{end+1} = alpha_2; values{end+1} = -pi/4;
    names{end+1} = alpha_3; values{end+1} = pi/4;
    names{end+1} = alpha_4; values{end+1} = -pi/4; 
    if ~simplificationForInversion
        names{end+1} = I_pbx;    values{end+1} = 0.0315; % Measured in pendulum experiment
        names{end+1} = I_pby;    values{end+1} = 0.0534;
        names{end+1} = I_pbz;    values{end+1} = 0.0271;
        names{end+1} = I_wx;    values{end+1} = 5.12e-5; %5.5e-05; % Thoroughly estimated at 500Hz using fit_wheel_inertia_model_accel
        names{end+1} = I_wyz;   values{end+1} = 0.00011;
        names{end+1} = h_p;     values{end+1} = 4*0.145*0.07/(3.22 - 4*0.145) + 0.07;  
        names{end+1} = m_p;     values{end+1} = 3.22 - 4*0.145;
        names{end+1} = m_w;     values{end+1} = 0.145;    
        names{end+1} = l_1;     values{end+1} = -0.105;
        names{end+1} = l_2;     values{end+1} = -0.063;
        names{end+1} = l_3;     values{end+1} = 0.063;
        names{end+1} = l_4;     values{end+1} = 0.105;
        names{end+1} = r_w;     values{end+1} = 0.0595/2;
        names{end+1} = r_r;     values{end+1} = 0.0055;
        names{end+1} = g;       values{end+1} = 9.81;
        names{end+1} = k_vw;     values{end+1} = 2.33e-5;
        names{end+1} = k_vr;     values{end+1} = 1.01e-4;% 9.7e-06;
        names{end+1} = K_rw;     values{end+1} = 1.97e-4;%(3e-04 - 1.5e-5)*0.65;
    else
        names{end+1} = l_3;     values{end+1} = -l_2;
        names{end+1} = l_4;     values{end+1} = -l_1;
    end
    out = subs(in, names,  values);
end

function [out] = substituteAlphas(in)
    syms alpha_1 alpha_2 alpha_3 alpha_4 real;
    names={}; values = {};
    names{end+1} = alpha_1; values{end+1} = pi/4;
    names{end+1} = alpha_2; values{end+1} = -pi/4;
    names{end+1} = alpha_3; values{end+1} = pi/4;
    names{end+1} = alpha_4; values{end+1} = -pi/4;
%     names{end+1} = alpha_1; values{end+1} = pi/4;
%     names{end+1} = alpha_2; values{end+1} = -pi/4;
%     names{end+1} = alpha_3; values{end+1} = -pi/4;
%     names{end+1} = alpha_4; values{end+1} = pi/4;
    out = simplify(subs(in, names,  values));
end

function [ out ] = stripTimeDependence(in)
    syms(symvar(in));
    if contains(char(in), 'diff') 
        error('Cannot remove time dependence when expression contains differentials') 
    end
    removeTimeDep = @(expr) str2sym(strrep(char(expr), '(t)', ''));
    out = arrayfun(removeTimeDep, in);
end

