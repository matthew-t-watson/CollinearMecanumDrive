
close all;
clearvars;

numTests = 50; % Make multiple of 4 if small
previewing = true;


[A, B] = linearization;
sys = ss(A,B,eye(size(A)),0);


%% Generate theta_p_max test vector
% Method 1
% theta_p_max = 0.0001;
% for i=2:50
%     theta_p_max(i) = R_weights(i-1)*1.2;
% end

% Method 2
% theta_p_max = 0.28;

% Method 3
theta_p_max = 0.3:-0.01:0.15;


%% Run tests
for k=1:numel(theta_p_max)
    MPC = Derive_MPC_Reference_Previewing(sys ...
        , 'umax', 0.1*ones(4,1) ...
        , 'theta_p_max', theta_p_max(k) ...
        , 'R', 0.01*eye(4) ...
        , 'v_y_max', 1 ...
        , 'v_x_max', 1 ...
        );
    
    % Helps to speed up parfor
    MPCCon =  parallel.pool.Constant(MPC);
    previewingCon =  parallel.pool.Constant(previewing);

    %% Run simulations
    parfor i=1:numTests
        [ref{i}, x0{i}] = generate_random_test_scenario(6000, [0.1 0.1 0.05 zeros(1,5)],i);
        test{i} = run_single_simulation(MPCCon.Value, 'Nonlinear', x0{i}, ref{i}, previewingCon.Value);
    end

    numFeasible = 0;
    for i = 1:numTests
        if test{i}.feasible == true
            numFeasible = numFeasible + 1;
        end
    end

    disp(['theta_p_max = ' num2str(theta_p_max(k)) ', numFeasible = ' num2str(numFeasible) ' of ' num2str(numTests)]);
    
    result.numFeasible(k) = numFeasible;
    
    if numFeasible == numTests
        break;
    end
end

figure;
plot(theta_p_max(1:numel(result.numFeasible)), result.numFeasible);




