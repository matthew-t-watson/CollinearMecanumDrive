
close all;
clearvars;

numTests = 100; % Make multiple of 4 if small
previewing = false;


[A, B] = linearization;
sys = ss(A,B,eye(size(A)),0);


%% Generate R_weight test vector
% Method 1
% R_weights = 0.0001;
% for i=2:50
%     R_weights(i) = R_weights(i-1)*1.2;
% end

% Method 2
R_weights = 0.38;

% Method 3
% R_weights = 0.24:0.02:0.4;


%% Run tests
for k=1:numel(R_weights)
    MPC = Derive_MPC_Reference_Previewing(sys, ...
        'R', R_weights(k)*eye(4) ...
        , 'umax', 0.1*ones(4,1) ...
        , 'theta_p_max', 0.3 ...
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
        else
%             plot_full_readout(test{i});
        end
    end
    plot_full_readout(test{1});

    disp(['R weight ' num2str(R_weights(k)) ', numFeasible = ' num2str(numFeasible) ' of ' num2str(numTests)]);
    
    result.numFeasible(k) = numFeasible;
    
    if numFeasible == numTests
        break;
    end
end

figure;
plot(R_weights(1:numel(result.numFeasible)), result.numFeasible);

