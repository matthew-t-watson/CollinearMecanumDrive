
function [] = CMD_state_estimation_model_derivation()

%% Currently only considering body positions
% Prediction step is based on integrating debiased gyroscope measurements
% and estimated velocities.
% Update step compares the current body positions with that measured by the
% wheels, and the rotated acceleration vector with gravity, adjusted for
% centripetal & coriolis forces

syms dt p q r b_p b_q b_r x y vx vy phi theta_p dphi dtheta_p real;
syms theta_1 theta_2 theta_3 theta_4 real;
syms theta_1_prev theta_2_prev theta_3_prev theta_4_prev real;
syms dtheta_1 dtheta_2 dtheta_3 dtheta_4 real;



%% Model form
% x_k = f(x_{k-1}, u_{k-1}) + w_{l-1}
% z_k = h(x_k) + v_k

w = rotx(theta_p)*[p-b_p; q-b_q; r];
dphi = w(3);
dtheta_p = w(1);

Rphi = [eye(2) zeros(2,1)]*rotz(phi)*[eye(2) zeros(2,1)]';

theta_i = [theta_1; theta_2; theta_3; theta_4];
theta_i_prev = [theta_1_prev; theta_2_prev; theta_3_prev; theta_4_prev];

dtheta_i = [
   (60*dphi)/17 - (4000*vx)/119 - (4000*vy)/119 - dtheta_p;
   (36*dphi)/17 + (4000*vx)/119 - (4000*vy)/119 - dtheta_p;
 - (36*dphi)/17 - (4000*vx)/119 - (4000*vy)/119 - dtheta_p;
 - (60*dphi)/17 + (4000*vx)/119 - (4000*vy)/119 - dtheta_p;
    ];

f_x_u = [
    theta_p + w(1)*dt;
    vx;
    vy;
    b_p;
    b_q;
    ];

state = [theta_p; vx; vy; b_p; b_q];
u = [p; q; r];

F_x_u = jacobian(f_x_u, state);


% z = [theta_1 theta_2 theta_3 theta_4 x_ddot y_ddot z_ddot]
% z_k = h(x_k) + v_k

% Rotate g from body to pendulum frame.
g = [0; 0; 1];
accel = rotx(theta_p)'*g;


h_x = [
    theta_i_prev + dt*dtheta_i;
    accel(2:3);
    w(2);
    ];

H_x = jacobian(h_x, state);

matlabFunction(f_x_u, 'File', 'State_Estimation/EKF_functions/state_transition_function.m', 'Vars', {state, u, dt});
matlabFunction(F_x_u, 'File', 'State_Estimation/EKF_functions/state_transition_jacobian_function.m', 'Vars', {state, u, dt});
matlabFunction(h_x, 'File', 'State_Estimation/EKF_functions/measurement_function.m', 'Vars', {state, u, theta_i_prev, dt});
matlabFunction(H_x, 'File', 'State_Estimation/EKF_functions/measurement_jacobian_function.m', 'Vars', {state, u, theta_i_prev, dt});
    
end

function rot = rotx(alpha)
    rot = [1 0 0; 0 cos(alpha) -sin(alpha); 0 sin(alpha) cos(alpha)];
end

function rot = roty(alpha)
    rot = [cos(alpha) 0 sin(alpha); 0 1 0; -sin(alpha) 0 cos(alpha)];
end

function rot = rotz(alpha)
    rot = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1;];
end
    
