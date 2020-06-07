
clearvars;
% close all;

nc = 10:10:70;
x0 = [0 0 0 0 0 0 0 0]';
ref = repmat([0 100 zeros(1,6)]', [1 100]);

for i=1:numel(nc)
    s_weight=[1.7 0.5 0.5 0.17]*1E0; % slacks set to 1/(max-min) such that s_weight*(max-min)=1 for all states
    MPC = Derive_MPC_Reference_Previewing(...
        'Ts', 0.015 ...
        , 'nc', nc(i) ...
        , 'R', 0.01*eye(4) ...
        , 'umax', 0.1*ones(4,1) ...
        , 'theta_p_max', 0.3 ...
        , 'v_y_max', 1 ...
        , 'v_x_max', 1 ...
        , 'phi_dot_max', 3 ...
        , 'MAS', 'lazy' ...
        , 'MAS_tolerance', 1E-3 ...
        , 'removeConstraints', 1 ...
        , 'slackType', 'individualToNi' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
        , 'constraintBlockingSize', 9 ...
        , 'ni', 5 ...
        , 'cinf_weighting', 1E-13 ...
        , 's_weight', s_weight ...
        , 's_weight_inf' , s_weight*1E1 ...
        , 'forceRegen', true ...
        );
    
    res{i} = run_single_simulation( MPC, 'Linear', 'qpOASES', x0, ref, false );
end

i=1;
while i <= numel(res)
    if res{i}.feasible == 0
        res(i) = [];
    else
        i=i+1;
    end
end

figure;
hold on;
for i=1:numel(res)
    subplot(2,2,1); hold on; plot(res{i}.x(2,:)); title('y');
    subplot(2,2,2); hold on; plot(res{i}.x(4,:)); title('theta_p');
    subplot(2,2,3); hold on; plot(res{i}.x(6,:)); title('vy');
    subplot(2,2,4); hold on; plot(res{i}.u'); title('u');
end

% figure;
% for i=1:numel(res)
%    subplot(numel(res),1,i);
%    plot(reshape(res{i}.z(1:res{i}.MPC.nu*res{i}.MPC.nc), [res{i}.MPC.nu res{i}.MPC.nc])');
%    xlim([0 max(nc)]);
% end
% 
% figure;
% hold on;
% for i=1:numel(res)
%    c = reshape(res{i}.z(1:res{i}.MPC.nu*res{i}.MPC.nc), [res{i}.MPC.nu res{i}.MPC.nc])';
%    plot(c(:,1));
%    xlim([0 max(nc)]);
% end
% 
% allU = [];
% for i=1:numel(res)
%    allU = [allU res{i}.u];
% end
% allU