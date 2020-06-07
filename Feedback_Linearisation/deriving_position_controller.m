
% clear all;
syms  y(t) yr xr x(t) K_p vy(t) vyr(t) vx(t) vxr(t) v_max dvy_max K_vx K_vy dphi(t) dphir(t) phi(t) phi_r dphi_max K_dphi K_phi real

assumeAlso(phi(t), 'real');

R_EB = [cos(phi) -sin(phi);
            sin(phi) cos(phi)];
        
% Body frame position error
e = formula(R_EB'*[x-xr; y-yr]);

% Inertial frame velocities
v_inertial = R_EB*[vx;vy];
dv_inertial = diff(v_inertial,t);
% and back to body frame
simplify(R_EB'*dv_inertial,1000);


V_E = ...
    + K_p*0.5*(e(1)^2 + e(2)^2) ...
    + K_phi*((phi - phi_r)^2)/2 ...
    + 1/(2*(v_max^2-vxr^2-vyr^2)) ...
    + 1/(2*(dphi_max^2 - dphir^2)) ...
    ;

dV_E = simplify(diff(V_E,t),100);

% Substitute dx dy for vx vy       
dV_E = simplify(subs(dV_E, [diff(x); diff(y); diff(phi)], [R_EB*[vx; vy]; dphi]), 1000);

clc;
pretty(dV_E)

syms K_v dx(t) dy(t) dxr dyr real
 V_E = K_v*((dxr-dx)^2 + (dyr-dy)^2)/2;
 dV_E = diff(V_E,t);
 dV_E = subs(dV_E, [dxr;dyr], R_EB*[vxr;vyr]);
 dV_E = subs(dV_E, [diff(dx);diff(dy)], diff(R_EB*[vx;vy],t));
 dV_E = subs(dV_E, [dx;dy], R_EB*[vx;vy]);
 dV_E = simplify(dV_E, 1000);
 pretty(dV_E)
 pretty(collect(dV_E, [diff(vx) diff(vy)]))
 
 
 syms vxr(t) vyr(t)
 V_E = K_v*((vxr-vx)^2 + (vyr-vy)^2)/2;
 dV_E = diff(V_E,t);
 dV_E = subs(dV_E, [vxr; vyr], R_EB'*[dxr;dyr])
 dV_E = subs(dV_E, diff([vxr; vyr]), diff(R_EB'*[dxr;dyr]))
 dV_E = simplify(dV_E, 1000);
 pretty(dV_E)

    