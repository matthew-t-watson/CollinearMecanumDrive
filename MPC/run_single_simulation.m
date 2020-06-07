function [ res ] = run_single_simulation( modelData, MPC, modelType, solver, x0, ref, previewing )


if ~strcmp(modelType, 'Linear') && ~strcmp(modelType, 'Nonlinear')
    error('Invalid model type');
end

if ~strcmp(solver, 'qpOASES') && ~strcmp(solver, 'quadprog')
    error('Invalid solver type');
end

res.feasible = true;
res.modelType = modelType;

numSteps = size(ref,2) - MPC.nr;

% Initialise state
res.x = x0;
res.state.t = 0;
res.MPC.t = 0;

for i = 1:numSteps
    
    if previewing
        % Extract previewed part of reference
        res.MPC.r(:,i) = reshape(ref(:,i+1:i+MPC.nr), [MPC.ny*MPC.nr 1]);
    else
        res.MPC.r(:,i) = repmat(ref(:,i), [MPC.nr 1]); 
    end
    
    res.MPC.t(:,i) = (i-1)*MPC.Ts;
    
    if strcmp(solver,'quadprog')
        opt = mskoptimset('MSK_DPAR_INTPNT_QO_TOL_DFEAS', 1e-6);
        
        tic;
        [z,res.MPC.cost(i), res.MPC.exitflag(i)] = quadprog(MPC.H, zeros(size(MPC.H,1),1), MPC.A, calculate_b(res.x(:,end),res.MPC.r(:,i), MPC.Fr_half, MPC.Fx_half, MPC.t), [],[],[],[],[], opt);
        res.MPC.t_exec(i) = toc;
       
    elseif strcmp(solver,'qpOASES')
        
        % Initialise solver
        if i == 1
            opt = qpOASES_options('MPC');
            opt.printLevel = 0;
            auxInput = qpOASES_auxInput;
            auxInput.hessianType = 4; % 2 = strictly positive definite, 4 = positive semi-definite
            [QP,~,~,res.MPC.exitflag(i)] = qpOASES_sequence('i',MPC.H,zeros(size(MPC.H,1),1),MPC.A,[],[],[],MPC.calculate_b(res.x(:,end),res.MPC.r(:,i)),opt,auxInput);
            if res.MPC.exitflag < 0
                error('Initial QP problem is infeasible');
            end
        end
        
        % Run hotstarted solver
        [z,res.MPC.cost(i),res.MPC.exitflag(i), res.MPC.iter(i),~,auxOutput] = qpOASES_sequence('h',QP,zeros(size(MPC.H,1),1),[],[],[],MPC.calculate_b(res.x(:,end),res.MPC.r(:,i)),opt);
        
        res.MPC.t_exec(i) = auxOutput.cpuTime;
        
    end
    
    % Return if infeasible
    if res.MPC.exitflag(i) < 0
        res.MPC.feasible = false;
        
        warning(['qpOASES error code' num2str(res.MPC.exitflag(end))]);
        
        % Resize simulation matrices to end size
        res.MPC.u = res.MPC.u(:,1:i-1);
        res.MPC.c = res.MPC.c(:,1:i-1);
        res.MPC.c_inf = res.MPC.c_inf(:,1:i-1);
        res.MPC.s = res.MPC.s(:,1:i-1);
        res.MPC.r_hat = res.MPC.r_hat(:,1:i-1);
        res.MPC.t_exec = res.MPC.t_exec(1:i-1);
        res.MPC.cost = res.MPC.cost(1:i-1);
        res.MPC.r = res.MPC.r(:,1:i-1);
        res.MPC.t = res.MPC.t(:,1:i-1);
        res.MPC.exitflag = res.MPC.exitflag(:,1:i-1);
        break;
    end
    
    % Extract decision variables
    res.MPC.c(1:MPC.nc*MPC.nu,i) = z(1:MPC.nc*MPC.nu);
    res.MPC.c_inf(1:MPC.nu,i) = z(MPC.nc*MPC.nu+1:MPC.nc*MPC.nu+MPC.nu);
    res.MPC.s(1:MPC.ns,i) = z(MPC.nc*MPC.nu+MPC.nu+1:MPC.nc*MPC.nu+MPC.nu+MPC.ns);
        
    % Calculate input
    res.MPC.u(:,i) = MPC.calculate_u(res.x(:,end), res.MPC.r(:,i), res.MPC.c(:,i));
    
    % Calculate r_hat
    res.MPC.r_hat(:,i) = MPC.calculate_r_hat(res.MPC.c_inf(:,i));
    
    if i ~= numSteps
        % Update state
        if strcmp(modelType, 'Linear')
            res.x(:,i+1) = MPC.dscrt_sys.A*res.x(:,i) + MPC.dscrt_sys.B*res.MPC.u(:,i);
            res.state.t(i+1) = res.state.t(i) + MPC.Ts;
        elseif strcmp(modelType, 'Nonlinear')
            [tout,yout] = ode45(@(t,y) modelData.dpdv(y,[res.MPC.u(1,i); res.MPC.u(2,i); res.MPC.u(3,i); res.MPC.u(4,i)]), [res.state.t(end) res.state.t(end)+MPC.Ts], res.x(:,end));
            res.x = [res.x yout(2:end,:)'];
            res.state.t = [res.state.t tout(2:end)'];
        end
    end
end

% Convert x to state
res.state.x =           res.x(1,:);
res.state.y =           res.x(2,:);
res.state.phi =         res.x(3,:);
res.state.theta_p =     res.x(4,:);
res.state.x_dot =       res.x(5,:);
res.state.y_dot =       res.x(6,:);
res.state.phi_dot =     res.x(7,:);
res.state.theta_p_dot = res.x(8,:);
res = rmfield(res,'x');

res.ref.x = res.MPC.r(1,:);
res.ref.y = res.MPC.r(2,:);
res.ref.phi = res.MPC.r(3,:);

% Clean up memory
if strcmp(solver,'qpOASES')
    qpOASES_sequence( 'c',QP )
end
    
end

