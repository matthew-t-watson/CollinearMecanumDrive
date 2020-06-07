
%% Part 1
syms dxr dyr K_v real
syms dx(t) dy(t) f_dxp(t) f_dyp(t)

V_E = 0.5*K_v*(dxr + f_dxp - dx)^2 + 0.5*K_v*(dyr + f_dyp - dy)^2;
dV_E = diff(V_E,t);

syms vx(t) vy(t) phi(t) f_vxp(t) f_vyp(t) vxr(t) vyr(t)
assumeAlso(phi(t), 'real');

R_EB = [cos(phi) -sin(phi);
            sin(phi) cos(phi)];

syms dvx(t) dvy(t)
syms f_dvxp(t) f_dvyp(t) dphi(t)
dV_E = subs(dV_E, diff([f_dxp; f_dyp],t), R_EB*[f_dvxp; f_dvyp]);
dV_E = subs(dV_E, diff([dx; dy],t), R_EB*[dvx;dvy]);
dV_E = subs(dV_E, [dx; dy], R_EB*[vx;vy]); % Substitute inertial velocities for body frame
dV_E = subs(dV_E, [dxr; dyr], R_EB*[vxr;vyr]); % Substitute inertial velocity references for body frame
dV_E = subs(dV_E, [f_dxp; f_dyp], R_EB*[f_vxp; f_vyp]);
dV_E = subs(dV_E, diff(phi,t), dphi);


%% Part 2
syms w1(t) dvxMax
V_E = (w1 - f_dvxp)^2 / (2*(dvxMax^2 - (w1 - f_dvxp)^2))
dV_E = diff(V_E,t)

syms dw1(t)
dV_E = subs(dV_E, diff(w1,t), dw1)
dV_E = simplify(dV_E, 1000)




