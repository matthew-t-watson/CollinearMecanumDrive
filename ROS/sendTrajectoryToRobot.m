rosshutdown
rosinit('matt-VirtualBox'); % Connect to external master


trajPub = rospublisher('robot/PolynomialTrajectory', 'polynomial_msgs/PolynomialTrajectory', 'IsLatching', true); % disabling latching breaks everything
[gainPub,gainMsg] = rospublisher('/robot/FeedbackGain', 'polynomial_msgs/FeedbackGain', 'IsLatching', true);

%% Update feedback gain
Q = diag([1 1 1 0.1 0 0 0 0]);
R = 0.4*eye(4);
dt = 0.001;
K = lqr(c2d(modelData.linsys, dt),Q,R);

gainMsg.K = K(:);
send(gainPub, gainMsg);

% pause(6);


%% Send trajectory 
trajMsg = trajectory.getROSTrajectoryMessage;
send(trajPub, trajMsg);

pause(2);

rosshutdown

