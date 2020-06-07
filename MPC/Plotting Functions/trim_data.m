function [ data ] = trim_data( data, t0, tend )

try data.MPC.c = data.MPC.c(:, data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.c_inf = data.MPC.c_inf(:, data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.ref.x = data.MPC.ref.x(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.ref.y = data.MPC.ref.y(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.ref.phi = data.MPC.ref.phi(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.u = data.MPC.u(:,data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.cost = data.MPC.cost(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.iter = data.MPC.iter(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.return = data.MPC.return(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.t_exec = data.MPC.t_exec(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.t_total = data.MPC.t_total(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.t = data.MPC.t(data.MPC.t >= t0 & data.MPC.t < tend); catch end
try data.MPC.t = data.MPC.t - t0; catch end

try data.sensors.acc_cal.x = data.sensors.acc_cal.x(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.acc_cal.y = data.sensors.acc_cal.y(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.acc_cal.z = data.sensors.acc_cal.z(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.rates.p = data.sensors.rates.p(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.rates.q = data.sensors.rates.q(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.rates.r = data.sensors.rates.r(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.theta_i = data.sensors.theta_i(:,data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.t = data.sensors.t(data.sensors.t >= t0 & data.sensors.t < tend); catch end
try data.sensors.t = data.sensors.t - t0; catch end

try data.ref.x	= data.ref.x(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.y	= data.ref.y(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.phi	= data.ref.phi(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.theta_p	= data.ref.theta_p(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.x_dot	= data.ref.x_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.y_dot	= data.ref.y_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.phi_dot	= data.ref.phi_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.ref.theta_p_dot	= data.ref.theta_p_dot(data.state.t >= t0 & data.state.t < tend); catch end

try data.state.b_p = data.state.b_p(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.b_q = data.state.b_q(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.x = data.state.x(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.y = data.state.y(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.phi = data.state.phi(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.theta_p = data.state.theta_p(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.x_dot = data.state.x_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.y_dot = data.state.y_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.phi_dot = data.state.phi_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.theta_p_dot = data.state.theta_p_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.b_p = data.state.variance.b_p(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.b_r = data.state.variance.b_r(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.x = data.state.variance.x(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.y = data.state.variance.y(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.phi = data.state.variance.phi(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.theta_p = data.state.variance.theta_p(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.x_dot = data.state.variance.x_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.y_dot = data.state.variance.y_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.phi_dot = data.state.variance.phi_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.variance.theta_p_dot = data.state.variance.theta_p_dot(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.t = data.state.t(data.state.t >= t0 & data.state.t < tend); catch end
try data.state.t = data.state.t - t0; catch end


try data.FBL.w1 = data.FBL.w1(data.t >= t0 & data.t < tend); catch end
try data.FBL.w2 = data.FBL.w2(data.t >= t0 & data.t < tend); catch end
try data.FBL.theta_pr = data.FBL.theta_pr(data.t >= t0 & data.t < tend); catch end
try data.FBL.w3 = data.FBL.w3(data.t >= t0 & data.t < tend); catch end
try if isfield(data.FBL,'dxr'), data.FBL.dxr = data.FBL.dxr(data.t >= t0 & data.t < tend); end, catch end
try if isfield(data.FBL,'dyr'),data.FBL.dyr = data.FBL.dyr(data.t >= t0 & data.t < tend); end, catch end
try if isfield(data.FBL,'dphir'),data.FBL.dphir = data.FBL.dphir(data.t >= t0 & data.t < tend); end, catch end


if isfield(data,'tau')
    data.tau.tau_1 = data.tau.tau_1(data.t >= t0 & data.t < tend); 
    data.tau.tau_2 = data.tau.tau_2(data.t >= t0 & data.t < tend); 
    data.tau.tau_3 = data.tau.tau_3(data.t >= t0 & data.t < tend); 
    data.tau.tau_4 = data.tau.tau_4(data.t >= t0 & data.t < tend); 
end

if isfield(data,'feedforward')
    data.feedforward.tau_1 = data.feedforward.tau_1(data.t >= t0 & data.t < tend); 
    data.feedforward.tau_2 = data.feedforward.tau_2(data.t >= t0 & data.t < tend); 
    data.feedforward.tau_3 = data.feedforward.tau_3(data.t >= t0 & data.t < tend); 
    data.feedforward.tau_4 = data.feedforward.tau_4(data.t >= t0 & data.t < tend); 
end

data.t = data.t(data.t >= t0 & data.t < tend);
data.t = data.t - t0;

end

