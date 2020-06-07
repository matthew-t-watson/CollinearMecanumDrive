
close all;
clearvars;

Ts = 0.035;
% Q = diag([1 1 1 0.1 0 0 0 1E-2]);
Q = diag([1 1 0.1 0 0 0 0 0]);
% R = 0.2*eye(4);
R = 0.01*eye(4);


%% Linearize system
[A, B] = linearization;
cont_sys = ss(A,B,eye(size(A)),0);

%% Discretise model
dscrt_sys = c2d(cont_sys,Ts,'zoh');
Kd = dlqr(dscrt_sys.A, dscrt_sys.B, Q, R);
closed_dscrt_sys = dscrt_sys;
closed_dscrt_sys.A = dscrt_sys.A - dscrt_sys.B*Kd;

figure, step(closed_dscrt_sys,1);
opt = bodeoptions;
opt.FreqUnits = 'Hz';
opt.PhaseVisible = 'off';
opt.YLim = [-20 30];
opt.YLimMode = 'manual';
figure; bodeplot(closed_dscrt_sys, 2*pi*(1E-2:0.01:1E2), opt);

