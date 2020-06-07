function [ state_out, P_new, ignoring_accel ] = CMD_state_estimation_single_step(state_in, P_old, u, z, theta_i_prev, dt)

% Extract needed parts of state
x_old = [state_in(4:6); state_in(9:10)];

persistent ekf;
if isempty(ekf)
    ekf = extendedKalmanFilter(@state_transition_function,@measurement_function, x_old);
    ekf.StateTransitionJacobianFcn = @state_transition_jacobian_function;
    ekf.MeasurementJacobianFcn = @measurement_jacobian_function;
        
       processNoise = [...
        1e-11 ... theta_p
        5 5 ... vx vy
        1e-15 1e-15 ... b_p b_q
        ];
    measurementNoise = [...
        1e2*ones(1,4) ... encoders
        1e2*ones(1,2) ... accel
        1e1 ... q
        ];

    ekf.ProcessNoise = diag(processNoise);
    ekf.MeasurementNoise = diag(measurementNoise);
end


persistent accel__norm_error
if isempty(accel__norm_error)
    accel__norm_error = 1;
end


ekf.State = x_old;
ekf.StateCovariance = P_old;

a=0.99;
accel__norm_error = a*accel__norm_error + (1-a)*abs(1-sqrt(z(5)^2 + z(6)^2));


% Increase accelerometer measurement variance if measuring centripetal acceleration
if accel__norm_error > 0.01
    ignoring_accel = 1;
    scale = 1e6;
else
    ignoring_accel = 0;
    scale = 1;
end

% scale = (1+exp(500*abs(sqrt(z(5)^2 + z(6)^2) - 1)));
% if scale > 1e9
%     scale = 1e9;
% end

ekf.MeasurementNoise(5:7,5:7) = eye(2)*1e1*scale;

%% Predict & update
predict(ekf, u, dt);
[x_new, P_new] = correct(ekf, z, u, theta_i_prev, dt);

% Calculate new states not included in EKF

% forward kinematics matrix
phi = state_in(3);
M = [-(4000*2^(1/2)*cos(pi/4 + phi))/119, -(4000*2^(1/2)*sin(pi/4 + phi))/119,  60/17;
      (4000*2^(1/2)*sin(pi/4 + phi))/119, -(4000*2^(1/2)*cos(pi/4 + phi))/119,  36/17;
     -(4000*2^(1/2)*cos(pi/4 + phi))/119, -(4000*2^(1/2)*sin(pi/4 + phi))/119, -36/17;
      (4000*2^(1/2)*sin(pi/4 + phi))/119, -(4000*2^(1/2)*cos(pi/4 + phi))/119, -60/17];
  
% Calculate change in position
Dtheta_i = z(1:4) - theta_i_prev + (x_new(1)-state_in(4)); % Is this sign correct?
%Dx = M\Dtheta_i; % Unknown Dphi
Dx = M(:,1:2)\(Dtheta_i - M(:,3)*dt*(u(3)*cos(state_in(4)) + (u(2) - state_in(10))*sin(state_in(4)))); % With Dphi knowledge, appears to improve performance

state_out = [
    state_in(1:2) + Dx(1:2);
    state_in(3) + dt*(u(3)*cos(state_in(4)) + u(2)*sin(state_in(4))); % + Dx(3);
    x_new(1);
    x_new(2);
    x_new(3);
    u(3)*cos(state_in(4)) + (u(2) - state_in(10))*sin(state_in(4));
    u(1) - state_in(9);
    x_new(4);
    x_new(5);
 ];


end

