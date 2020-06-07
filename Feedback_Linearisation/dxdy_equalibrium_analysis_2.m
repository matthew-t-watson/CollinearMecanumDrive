
close all;
% We require dvx = vy dphi and dvy = -vx dphi (as time variant functions)

% That is, we required both accelerations to exactly equal that due to rotation, i.e. no other acceleration

syms vx(t) vy(t) w1(t) w3(t) dphi(t) theta_p(t) dtheta_p(t) w3;

eqns = [ vy*dphi == diff(vx);
    -vx*dphi == diff(vy);
    diff(vy) == modelData.substituteParameters(modelData.pv.dvy);
    ];

eqns = rhs(eqns) - lhs(eqns);
eqns = simplify(eqns,1000);

eqns = formula(subs(eqns, [dtheta_p, w3], [diff(theta_p,1), diff(theta_p,2)]));

eqns = subs(eqns, dphi, 1);

V = odeToVectorField(eqns);

f = matlabFunction(V,'vars',{'t','Y'});

opt = odeset;
opt.RelTol = 1e-12;
opt.Events = @thetapCrossingEventsFcn;
[t,y,te] = ode45(f, [0 10], [0 1 0 0], opt);

figure; subplot(3,1,1); plot(t,y(:,1:2));
subplot(3,1,2); plot(t,y(:,3));
subplot(3,1,3); plot(t,y(:,4));
%return;

% %% Use fmincon to search for initial conditions
% toSolve = @(x) -fmin(x,f,opt);
% fminconOpt = optimoptions('fmincon', 'Display', 'iter');
% x = fmincon(toSolve, [0.1;0],[],[],[],[],[-0.3;-10],[0.3;10],[],fminconOpt)
% [t,y,te] = ode45(f, [0 2*pi], [0 1 x(1) x(2)], opt);
% figure; subplot(3,1,1); plot(t,y(:,1:2));
% subplot(3,1,2); plot(t,y(:,3));
% subplot(3,1,3); plot(t,y(:,4));
% return;

%% Use globalsearch to find global optimal using fmincon
toSolve = @(x) -fmin([0; 1; x],f,opt);
gs = GlobalSearch;
gs.MaxTime = 1000;
gs.XTolerance = 1e-12;
gs.FunctionTolerance = 1e-12;
gs.NumTrialPoints = 10000;
gs.NumStageOnePoints = 1000;
gs.Display = 'iter';
gs.BasinRadiusFactor = 0.2;
problem = createOptimProblem('fmincon','x0',[0;0],...
    'objective',toSolve,'lb',[-pi/2;-4],'ub',[pi/2;4]);
x = run(gs,problem)
[t,y,te] = ode45(f, [0 100], [0 1 x(1) x(2)], opt);
figure; subplot(3,1,1); plot(t,y(:,1:2));
subplot(3,1,2); plot(t,y(:,3));
subplot(3,1,3); plot(t,y(:,4));
return;

% %% Use multistart to find global minimum using fminunc
% toSolve = @(x) -fmin(x,f,opt);
% ms = MultiStart;
% ms.Display = 'iter';
% ms.UseParallel = 1;
% problem = createOptimProblem('fmincon','x0',[0;0],...
%     'objective',toSolve,'lb',[-0.3;-1],'ub',[0.3;1]);
% x = run(ms,problem,40)
% [t,y,te] = ode45(f, [0 100], [0 1 x(1) x(2)], opt);
% figure; subplot(3,1,1); plot(t,y(:,1:2));
% subplot(3,1,2); plot(t,y(:,3));
% subplot(3,1,3); plot(t,y(:,4));
% return;

%% Perform grid search for initial conditions
theta_p_range = linspace(-0.1, 0.1, 2000);
dtheta_p_range = linspace(-0.5, 0.5, 2000);

clear cost firstViolation;
for i=1:numel(theta_p_range)
    tic;
    parfor j=1:numel(dtheta_p_range)
        [t,y,te] = ode45(f, [0 2*pi], [0 1 theta_p_range(i) dtheta_p_range(j)], opt);
        %cost(i,j) = sum(diff(t).*y(3,2:end).^2);        
        firstViolation(i,j) = te;
    end
    disp(['i=' num2str(i) ' of ' num2str(numel(theta_p_range)) ', duration ' num2str(toc)]);
end

%figure; surf(dtheta_p_range, theta_p_range, log(cost),'EdgeColor','none','LineStyle','none','FaceLighting','phong');
figure; surf(dtheta_p_range, theta_p_range, firstViolation,'EdgeColor','none','LineStyle','none','FaceLighting','phong');

% minCost = min(cost(:));
% [row,col] = find(cost == minCost);
% sol = ode45(f, [0 2*pi], [0 1 theta_p_range(row) dtheta_p_range(col)], opt);
% figure; subplot(3,1,1); plot(sol.x,sol.y(1:2,:));
% subplot(3,1,2); plot(sol.x,sol.y(3,:));
% subplot(3,1,3); plot(sol.x,sol.y(4,:));

latestViolation = max(firstViolation(:));
[row,col] = find(firstViolation == latestViolation);
sol = ode45(f, [0 2*pi], [0 1 theta_p_range(row) dtheta_p_range(col)], opt);
figure; subplot(3,1,1); plot(sol.x,sol.y(1:2,:));
subplot(3,1,2); plot(sol.x,sol.y(3,:));
subplot(3,1,3); plot(sol.x,sol.y(4,:));

function te = fmin(x, f, opt)
    [~,~,te] = ode45(f, [0 100], x, opt);
    if isempty(te)
        te = 100;
    end
end

function [value,isterminal,direction] = thetapCrossingEventsFcn(t,y)
value = abs(y(3)) - pi; % The value that we want to be zero
isterminal = 1;  % Halt integration 
direction = 0;   % The zero can be approached from either direction
end


% w1 is defined to exactly equal acceleration due to rotation, w2 must be zero, so we are left to find a solution for w3
% that satisfies the two above equations. Or perhaps we should be substituting dthetap and w3 for true differentials
% then trying to find an equation for thetap that satisfies the equalities.

% From https://en.wikipedia.org/wiki/System_of_polynomial_equations#What_is_solving? 
% The first thing to do in solving a polynomial system is to decide if it is inconsistent, zero-dimensional or positive
% dimensional. This may be done by the computation of a Gröbner basis of the left-hand sides of the equations. The
% system is inconsistent if this Gröbner basis is reduced to 1. 