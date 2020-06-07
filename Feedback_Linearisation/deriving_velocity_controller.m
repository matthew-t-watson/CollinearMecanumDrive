
clear all;
syms f_ss(t) theta_p_ss(t) theta_pr(t) theta_pmax y(t) yr xr x(t) K_x K_y vy(t) vxr vyr dphir vx(t) vx_max vy_max K_vx K_vy K_r dphi(t) phi(t) phi_r dphi_max K_dphi K_phi real


V_E = ...
    1/(2*(theta_pmax^2 - (theta_p_ss - theta_pr)^2)) ...
    + (K_vy*(vy - vyr)^2)/2 ...
    + (K_vx*(vx - vxr)^2)/2 ...
    + (K_dphi*(dphi - dphir)^2)/2 ...
    ;

dV_E = simplify(diff(V_E,t),100);


pretty(dV_E)

% New barrier function
V_E = ...
    1/(2*(theta_pmax^2 - (theta_p_ss - theta_pr)^2)) ...
    ;




% Define control laws
% dtheta_pr = dfss_minus1_dvy0 ...
%     + K_r*(theta_pr - fss_minus1_dvy0) ...
%     +((theta_p_max^2-(fss_minus1_dvy0-theta_pr)^2)^2*K_vy*vy*out.pv.dvy_ss)/((fss_minus1_dvy0-theta_pr)*(vy^2-vy_max^2)^2) ...
%     +((theta_p_max^2-(fss_minus1_dvy0-theta_pr)^2)^2*K_p*vy*(-(x-x_r)*sin(phi)+(y-y_r)*cos(phi)))/(fss_minus1_dvy0-theta_pr);
% 
% w1 = -K_vx*vx - K_p*(vx^2-vx_max^2)^2*(cos(phi)*(x-x_r)+sin(phi)*(y-y_r));
% w2 = -K_dphi*dphi - (dphi^2-dphi_max^2)^2*(phi_r-phi)*K_phi;

% % Substitute controls into dV_E
% dV_E_subs = dV_E;
% dV_E_subs = simplify(expand(subs(dV_E_subs, [diff(vx); diff(dphi)], [w1; w2])),1000);
% dV_E_subs = simplify(subs(dV_E_subs, diff(theta_pr), dtheta_pr),1000);
% pretty(dV_E_subs)

    