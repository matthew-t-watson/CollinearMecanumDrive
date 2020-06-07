
close all;
clearvars -except modelData trajectory;

%% Ensure we are in the correct path
cd('D:\Google_Drive\Matlab\CMD');

%% Configure environment
addpath(genpath('../qpOASES-3.2.1/'));
rmpath('D:\Program Files\Mosek\8\toolbox\r2014a');


%% Create modelData if it doesn't exist
if ~exist('modelData', 'var')
    modelData = model_derivation(true);
end

%% Derive MPC
    MPC = Derive_MPC_Reference_Previewing(modelData ...
        , 'Ts', 0.035... Increasing this allows greater access to the constrained set for an equivalent nc
        , 'nc', 12 ...
        , 'nr', 12 ...  Surprisingly nr>nc gives good results on figure 8 simulation - yields infeasibility on step reference though
        , 'Q', diag([1 1 1 0 0 0 0 0]) ...
        , 'R', 0.1*eye(4) ... 
        , 'umax', 0.1*ones(4,1) ... 0.05 reduces peak theta_p, 0.065 is same as 0.1
        , 'theta_p_max', 0.3 ...
        , 'v_y_max', 1 ...
        , 'v_x_max', 1 ...
        , 'phi_dot_max', 4 ...
        , 'MAS', 'minimal' ...
        , 'MAS_tolerance', 1E-4 ... % 3E-3 seems to cause instability, 1E-3 seems ok
        , 'removeConstraints', 0 ...
        , 'slackType', 'individualToNiThenShared' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
        , 'ni', 3 ... 3 appears to be optimal for smooth transitions between constrained and unconstrained regions
        , 'cinf_weighting', 1E-12 ...
        , 's_weight', [1E-5 1E-5 1E2] ... [theta_p v dphi]
        , 's_weight_inf' , [1E5 1E5 1E1] ... % 1E3 for theta_p gives willingful violation, 1E4 gives a small overshoot on theta_p, 1E5 gives tight constraint tracking
        , 'generateCode', true ...
        , 'verbosity', 2 ...
        , 'forceRegen', true ...
        );

%% Simulation Setup
pv0 = [0 0 0 0 0 0 0 0]';
runtime = 10;
steps = round(runtime/MPC.Ts);

%% Generate reference profiles
% Step changes
stepIndex1 = round(2/MPC.Ts);
stepIndex2 = round(6/MPC.Ts);
step = [
    repmat([0 0 0]', [1 stepIndex1]) ...
    repmat([0 3 0]', [1 stepIndex2-stepIndex1]) ...
    repmat([0 0 0]', [1 steps-stepIndex2+MPC.nr])
    ];

% Figure of 8
figure8 = [];
a = 1;
lapDuration = 10;
stepsPerLap = round(lapDuration/MPC.Ts);
for i = 0:steps
    figure8 = [figure8 [a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        a*sqrt(2)*cos(i*(2*pi/stepsPerLap)+pi/2)*sin(i*(2*pi/stepsPerLap)+pi/2)/(sin(i*(2*pi/stepsPerLap)+pi/2)^2+1);
        0]
        ];
end
figure8 = [figure8 repmat([0 0 0]', [1 steps-stepsPerLap+MPC.nr])];

% Linear ramp
ramp = zeros(3,1);
for i=2:steps
    ramp(2,i) = ramp(2,i-1) + 0.03;
end

%% Select reference
ref = step;
% ref = figure8;
% ref = ramp;
previewing = true;

traj.pvdv = timeseries(ref, 0:MPC.Ts:(MPC.Ts*(size(ref,2)-1)));
traj.u = timeseries([0;0;0;0]);

%% Run simulation
% res_lin = run_single_simulation(modelData, MPC, 'Linear', 'qpOASES', pv0, ref, previewing);

res_nl = run_single_simulation(modelData, MPC, 'Linear', 'qpOASES', pv0, ref, previewing);
% res_nl = run_single_simulation(modelData, MPC, 'Nonlinear', 'quadprog', pv0, ref, previewing);
% 
% disp(['Linear model worst case execution time ' num2str(max(res_lin.t_exec)) ', median ' num2str(median(res_lin.t_exec))]);
% disp(['Nonlinear model worst case execution time ' num2str(max(res_nl.t_exec)) ', median ' num2str(median(res_nl.t_exec))]);

constraints.u_max = MPC.umax(1);
constraints.x_dot_max = MPC.v_x_max;
constraints.y_dot_max = MPC.v_y_max;
constraints.phi_dot_max = MPC.phi_dot_max;
constraints.theta_p_max = MPC.theta_p_max;

%% Plot readouts
% plot_full_readout(res_lin, constraints);
% plot_full_readout(res_nl, constraints);


% plot_xy_readout(res_lin, false, 'Figures\linear_figure_8.tex');
plot_xy_readout(res_nl, constraints, false, 'Figures\nonlinear_figure_8.tex');
% plot_xyphi_readout(res_lin, false, 'Figures\nonlinear_figure_8.tex');
% plot_xyphi_readout(res_nl, false, 'Figures\nonlinear_figure_8.tex');

% plot_y_readout(res_lin, true, 'Figures\linear_y_step_with_disturbance.tex');
% plot_y_readout(res_lin, true, 'Figures\linear_y_step.tex');
% plot_phi_readout(res_nl, false);
% plot_x_readout(res_nl, false);

%% Plot xy trajectory
plot_xy(res_nl, constraints, false, 'MPC\Figures\nonlinear_figure_8_trajectory_temp.tex');

%% Plot execution stats
% plot_execution_stats(res_lin, res_nl);

%% Plot linear and nonlinear readout - just y, one 4x2 subplot, generate pgfplot
% figure('pos',[680 42 560 700]);
% T = 0:Ts:Ts*(steps-1);
% y_lim_scale = 1.3;
% subplot(4,2,1); hold on; stairs(T,u','b'); stairs(T,u_nl','r'), plot([T(1),T(end); T(1),T(end)]',[umax(1),umax(1); umin(1),umin(1)]', '-.'), title('$u \ (\unit{Nm})$'), ylim(max([max(u) umax(1)])*[-y_lim_scale y_lim_scale]);
% subplot(4,2,2); hold on; stairs(T,c(1:nu,:)','b'); stairs(T,c_nl(1:nu,:)','r'), title('$c$');
% subplot(4,2,3); hold on; stairs(T,cinf','b'); stairs(T,cinf_nl','r'); title('$c_\infty$');
% subplot(4,2,4); hold on; stairs(T,fval','b'); stairs(T,fval_nl','r'); title('$J$');
% subplot(4,2,5); hold on; plot(T,x(2,1:steps)', 'b', T,x_nl(2,1:steps)', 'r', T, ref(2,1:steps)', '--'), title('$y \ (\unit{m})$'); ylim([-0.3 1.3]);
% subplot(4,2,6); hold on; plot(T,x(4,1:steps)','b',T,x_nl(4,1:steps)','r'), title('$\theta_p \ (\unit{rad})$'), hold on, plot([T(1),T(end); T(1),T(end)]',[theta_p_max,theta_p_max; -theta_p_max,-theta_p_max]', '-.'), ylim(max([max([x(4,1:steps)' x_nl(4,1:steps)']) theta_p_max])*[-y_lim_scale y_lim_scale]);
% subplot(4,2,7); hold on; plot(T,x(6,1:steps)','b',T,x_nl(6,1:steps)','r'), title('\(\dot{y} \ (\unit{ms^{-1}})\)'), hold on, plot([T(1),T(end); T(1),T(end)]',[vel_y_max,vel_y_max; -vel_y_max,-vel_y_max]', '-.'), ylim(max([max([x(6,1:steps)' x_nl(6,1:steps)']) vel_y_max])*[-y_lim_scale y_lim_scale]);
% subplot(4,2,8), hold on; stairs(t_exec','b'); stairs(t_exec_nl','r'); title('$t_{\text{exec}} \ (\unit{s})$');
% matlab2tikz('Figures/linear_nonlinear_y_step/tikz/single_subplot.tex', 'width', '0.9\linewidth', 'parseStrings', false, ...
%     'extraaxisoptions',['title style={font=\footnotesize},'...
%     'title style={yshift=-1.5ex},' ...
%     'xlabel style={font=\footnotesize},'...
%     'ylabel style={font=\footnotesize},' ...
%     'ticklabel style={font=\scriptsize},' ...
%     'height=0.2\linewidth,'...
%     ...' scaled y ticks = false,' ...
%     ...' y tick label style={/pgf/number format/fixed},' ...
%     ]);
