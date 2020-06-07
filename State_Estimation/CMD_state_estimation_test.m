
% close all;
clearvars -except data modelData trajectory;
% if ~exist('data', 'var')
%     data = import_data('D:\Google_Drive\Labview\Robot 2\Robot test data\data_270318_1619.csv');
%     data = import_data('D:\Google_Drive\Labview\Robot 2\Robot test data\data_280318_0953.csv');   
%     data = import_data('D:\Google_Drive\Labview\Robot 2\Robot test data\data_030418_1453.csv');  
%     data = import_data('D:\Google_Drive\Labview\Robot 2\Robot test data\data_070418_1653.csv');
%     data = import_data('D:\Google_Drive\Labview\Robot 2\Robot test data\data_120418_1319.csv');
%     data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_220119_1147.csv');
%     data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_220119_1732_1m_translation_1_rotation.csv');
%     data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_240119_1341.csv');
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_060219_1451.csv');
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_270219_1950.csv');
% data = import_data('D:\Google_Drive\Labview\Robot 3\Robot test data\data_020819_1225.csv');


% end
% Manually rebias gyroscopes
% data.sensors.rates.p(1000:end) = data.sensors.rates.p(1000:end) + mean(data.sensors.rates.p(1:1000));
% data.sensors.rates.q(1000:end) = data.sensors.rates.q(1000:end) + mean(data.sensors.rates.q(1:1000));
% data.sensors.rates.r(1000:end) = data.sensors.rates.r(1000:end) + mean(data.sensors.rates.r(1:1000));


dt = 0.001;
if any(dt ~= diff(data.sensors.t))
    warning('Bad timestamps');
end
data.sensors.t = data.sensors.t - data.sensors.t(1);

theta_i = data.sensors.theta_i;
a = [data.sensors.acc_cal.y data.sensors.acc_cal.z]';
w = [data.sensors.rates.p data.sensors.rates.q data.sensors.rates.r]';

z = [theta_i; a; zeros(1,numel(data.t))];
u = w;

nx = 10;
nxk = 5;

% Initial covariance & state
P = 1e3*eye(nxk);
x = zeros(nx, numel(data.sensors.t));
% x(4,1) = atan2(data.sensors.acc_cal.y(1), data.sensors.acc_cal.z(1));


for i = 2:numel(data.sensors.t)    
    [x(:,i), P] = CMD_state_estimation_single_step(x(:,i-1), P, u(:,i), z(:,i), theta_i(:,i-1), dt);    
    variance(:,i) = diag(P)';
end

w_rot(1,:) = w(1,:);% - mean(w(1,1:10),2);
w_1_int = atan2(data.sensors.acc_cal.y(1), data.sensors.acc_cal.z(1)) + cumsum(dt*w_rot(1,:));

for i=1:size(w,2)
    w_rot(2:3,i) = [zeros(2,1) eye(2)]*rotx(w_1_int(i))*[zeros(2,1) eye(2)]' * (w(2:3,i) - mean(w(2:3,1:10),2));
end
w_3_int = cumsum(dt*w_rot(3,:));


%% Thesis figures
figure;
ax = [];
tend = 80;
ax(end+1) = subplot(6,1,1); plot(data.sensors.t, x(1:2,:)'), legend('\(x\)', '\(y\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
ax(end+1) = subplot(6,1,2); plot(data.sensors.t, [x(3,:)' w_3_int']); legend('\(\phi\)', '\(\phi_{b}\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
ax(end+1) = subplot(6,1,3); plot(data.sensors.t, x(5:6,:)'), legend('\(v_x\)', '\(v_y\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
ax(end+1) = subplot(6,1,4); plot(data.sensors.t, [x(4,:)' w_1_int']); legend('\(\theta_p\)', '\(\int \Omega_p\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
ax(end+1) = subplot(6,1,5); plot(data.sensors.t, x(9:10,:)'), legend('\(b_p\)', '\(b_q\)', 'Location', 'NorthEastOutside'); xlim([0 tend]); %ylim([-0.05 0.099]);
ax(end+1) = subplot(6,1,6); semilogy(data.sensors.t, variance([1 4 5],:)'), xlim([0 tend]); legend('\(\text{Var}(\widehat{\theta}_p)\)', '\(\text{Var}(\widehat{b}_p)\)', '\(\text{Var}(\widehat{b}_q)\)', 'Location', 'NorthEastOutside')

% set(gcf, 'Position', [20 20 560 700])

% cleanfigure;
% matlab2tikz('D:\Google_Drive\Latex\Thesis\Figures\CMD\state_estimation.tex', 'width', '0.8\linewidth', 'height', '0.8\textheight', 'parseStrings', false, 'extraTikzpictureOptions', 'trim axis left, trim axis right');

%% Plot robot's state estimates
% figure;
% ax = [];
% tend = 80;
% ax(end+1) = subplot(6,1,1); plot(data.sensors.t, [data.state.x data.state.y]), legend('\(x\)', '\(y\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
% ax(end+1) = subplot(6,1,2); plot(data.sensors.t, [data.state.phi w_3_int']); legend('\(\phi\)', '\(\phi_{b}\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
% ax(end+1) = subplot(6,1,3); plot(data.sensors.t, [data.state.x_dot data.state.y_dot]), legend('\(v_x\)', '\(v_y\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
% ax(end+1) = subplot(6,1,4); plot(data.sensors.t, [data.state.theta_p w_1_int']); legend('\(\theta_p\)', '\(\int \Omega_p\)', 'Location', 'NorthEastOutside'); xlim([0 tend]);
% ax(end+1) = subplot(6,1,5); plot(data.sensors.t, [data.state.b_p data.state.b_q]), legend('\(b_p\)', '\(b_q\)', 'Location', 'NorthEastOutside'); xlim([0 tend]); %ylim([-0.05 0.099]);


function rot = rotx(alpha)
    rot = [1 0 0; 0 cos(alpha) -sin(alpha); 0 sin(alpha) cos(alpha)];
end

function rot = roty(alpha)
    rot = [cos(alpha) 0 sin(alpha); 0 1 0; -sin(alpha) 0 cos(alpha)];
end

function rot = rotz(alpha)
    rot = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1;];
end
    
    






