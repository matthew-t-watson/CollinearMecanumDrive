

syms dvx_max dvy_max f_vyss_thetapr(t) Kv dx(t) dxr dy(t) dyr phi(t) dphir vx(t) vy(t) vxr vyr w1(t) real


assumeAlso(phi(t), 'real');

R_EB = [cos(phi) -sin(phi);
            sin(phi) cos(phi)];
        
% Inertial frame velocities
v_inertial = R_EB*[vx;vy];
dv_inertial = diff(v_inertial,t);
% and back to body frame
simplify(R_EB'*dv_inertial,1000);

% dx and dy in body frame
dxdy_body = R_EB'*[dx;dy];
dxrdyr_body = R_EB'*[dxr;dyr];

% Derive in terms of body velocities and references, then substitute once
% controllers are derived

V_E = 1/(2*(dvy_max^2 - f_vyss_thetapr^2)) ...
    + 0.5*Kv*((vx - vxr)^2 + (vy - vyr)^2) ...
    + 1/(2*(dvx_max^2 - w1^2)) ...
    ;
dV_E = simplify(diff(V_E,t), 1000)


% Substitute dvy for f_vyss_thetapr and dvx for w1
dV_E = simplify(subs(dV_E, [diff(vy) diff(vx)], [f_vyss_thetapr w1]), 1000);

% Substitute df_vyss_thetapr for actual expression
dV_E = simplify(subs(dV_E, diff(f_vyss_thetapr), diff(modelData.pv.dvy_ss)), 1000)

% % Substitute dx dy ddx ddy in terms of body velocities
% dV_E = simplify(subs(dV_E, [dx; dy], v_inertial), 1000);
% dV_E = simplify(subs(dV_E, [diff(dx); diff(dy)], dv_inertial), 1000);

clc;
pretty(dV_E)