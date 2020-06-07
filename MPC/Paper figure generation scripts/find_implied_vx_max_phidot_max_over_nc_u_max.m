
close all;
clearvars;

%% 2D plot of implied xdot and psidot constraint vs nc
nc = 1:16;
umax=0.1:-0.02:0.04;
for i=1:numel(umax)
    for j=1:numel(nc)
        MPC = Derive_MPC_Reference_Previewing(...
            'Ts', 0.02... Increasing this allows greater access to the constrained set for an equivalent nc
            , 'nc', nc(j) ...
            , 'nr', nc(j) ...  Surprisingly nr>nc gives good results on figure 8 simulation
            , 'Q', diag([0.2 1 1 0 0 0 0 0]) ...
            , 'R', 0.1*eye(4) ...
            , 'umax', umax(i)*ones(4,1) ... 0.05 reduces peak theta_p, 0.065 is same as 0.1
            , 'theta_p_max', 0.3 ...
            , 'v_y_max', 1 ...
            , 'v_x_max', 1 ...
            , 'phi_dot_max', 4 ...
            , 'MAS', 'minimal' ...
            , 'MAS_tolerance', 1E-3 ... % 3E-3 seems to cause instability, 1E-3 seems ok
            , 'removeConstraints', 1 ...
            , 'slackType', 'individualToNiForThetaPAndVyThenShared' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
            ... , 'slackType', 'individualToNiThenShared' ...
            , 'ni', 2 ... 3 appears to be optimal for smooth transitions between constrained and unconstrained regions
            , 'cinf_weighting', 1E-20 ...
            , 's_weight', [1E-3 1E-3 1E-5 1E-3] ...
            , 's_weight_inf' , [1E4 1E2 1 1E0] ... % 1E3 for theta_p gives willingful violation, 1E4 gives a small overshoot on theta_p, 1E5 gives tight constraint tracking
            , 'generateCode', false ...
            , 'verbosity', 0 ...
            , 'forceRegen', true ...
            );
        
        x0FreeElementIndices = 5;
        x0FixedElementIndices = 1:MPC.nx;
        x0FixedElementIndices(x0FreeElementIndices) = [];
        
        opt = optimoptions('linprog');
        opt.Display = 'off';
        opt.Algorithm = 'interior-point-legacy';
        opt.MaxIterations = 10000;
        opt.ConstraintTolerance = 1e-9; % Neither this nor optimality tolerance seem to change the output.
        opt.OptimalityTolerance = 1e-9;
        
        x0 = [0 0 0 0 0 0 0 0]';
        
        % Solve linear program
        try
            opt.Algorithm = 'dual-simplex';
            [xMax,~,exitflagMax] = linprog([-ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        catch
            opt.Algorithm = 'interior-point-legacy';
            [xMax,~,exitflagMax] = linprog([-ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        end
        try
            opt.Algorithm = 'dual-simplex';
            [xMin,~,exitflagMin] = linprog([ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        catch
            opt.Algorithm = 'interior-point-legacy';
            [xMin,~,exitflagMin] = linprog([ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        end
        xmax(i,j) = xMax(1:numel(x0FreeElementIndices));
        xmin(i,j) = xMin(1:numel(x0FreeElementIndices));
    end
end
for i=1:numel(umax)
    parfor j=1:numel(nc)
        MPC = Derive_MPC_Reference_Previewing(...
            'Ts', 0.02... Increasing this allows greater access to the constrained set for an equivalent nc
            , 'nc', nc(j) ...
            , 'nr', nc(j) ...  Surprisingly nr>nc gives good results on figure 8 simulation
            , 'Q', diag([0.2 1 1 0 0 0 0 0]) ...
            , 'R', 0.01*eye(4) ...
            , 'umax', umax(i)*ones(4,1) ... 0.05 reduces peak theta_p, 0.065 is same as 0.1
            , 'theta_p_max', 0.3 ...
            , 'v_y_max', 1 ...
            , 'v_x_max', 1 ...
            , 'phi_dot_max', 4 ...
            , 'MAS', 'minimal' ...
            , 'MAS_tolerance', 1E-6 ... % 3E-3 seems to cause instability, 1E-3 seems ok
            , 'removeConstraints', 1 ...
            , 'slackType', 'individualToNiForThetaPAndVyThenShared' ... % Managed 1000 feasible with individualToNiThenShared with ni=2
            ... , 'slackType', 'individualToNiThenShared' ...
            , 'ni', 2 ... 3 appears to be optimal for smooth transitions between constrained and unconstrained regions
            , 'cinf_weighting', 1E-20 ...
            , 's_weight', [1E-3 1E-3 1E-5 1E-3] ...
            , 's_weight_inf' , [1E4 1E2 1 1E0] ... % 1E3 for theta_p gives willingful violation, 1E4 gives a small overshoot on theta_p, 1E5 gives tight constraint tracking
            , 'generateCode', false ...
            , 'verbosity', 0 ...
            , 'forceRegen', true ...
            );
        
        x0FreeElementIndices = 7;
        x0FixedElementIndices = 1:MPC.nx;
        x0FixedElementIndices(x0FreeElementIndices) = [];
        
        opt = optimoptions('linprog');
        opt.Display = 'off';
        opt.Algorithm = 'interior-point-legacy';
        opt.MaxIterations = 10000;
        opt.ConstraintTolerance = 1e-9; % Neither this nor optimality tolerance seem to change the output.
        opt.OptimalityTolerance = 1e-9;
        
        x0 = [0 0 0 0 0 0 0 0]';
        
        % Solve linear program
        try
            opt.Algorithm = 'dual-simplex';
            [xMax,~,exitflagMax] = linprog([-ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        catch
            opt.Algorithm = 'interior-point-legacy';
            [xMax,~,exitflagMax] = linprog([-ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        end
        try
            opt.Algorithm = 'dual-simplex';
            [xMin,~,exitflagMin] = linprog([ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        catch
            opt.Algorithm = 'interior-point-legacy';
            [xMin,~,exitflagMin] = linprog([ones(1, numel(x0FreeElementIndices)), zeros(1,MPC.nc*MPC.nu+MPC.nu+MPC.ns)], [MPC.Fx(:,x0FreeElementIndices), MPC.Fc, MPC.Fci, MPC.Fs], MPC.t -MPC.Fx(:,x0FixedElementIndices)*x0(x0FixedElementIndices) -MPC.Fr*zeros(MPC.nx*MPC.nr,1),[],[],[],[],opt);
        end
        phidotmax(i,j) = xMax(1:numel(x0FreeElementIndices));
        phidotmin(i,j) = xMin(1:numel(x0FreeElementIndices));
    end
end

figure('Position', [680 558 560 420]);
for i=1:numel(umax)
    legendText{i} = ['\(\overline{u}=' num2str(umax(i)) '\)'];
end
subplot(2,1,1);
plot(nc,xmax);
legend(legendText,'Location','northwest');
ylabel('\(\overline{\dot{x}}\)');
%         xticks([]);
%         yticks([1 2]);

subplot(2,1,2);
plot(nc,phidotmax);
xlabel('\(n_c\)');
ylabel('\(\overline{\dot{\phi}}\)');
%         yticks([0 10 20])


cleanfigure;
matlab2tikz('D:\Google_Drive\Matlab\Matt_MPC\Figures\Implied_xdot_constraint_over_nc_umax.tex' ...
    , 'width', '0.6\linewidth' ...
    , 'parseStrings', false ...
    , 'extraaxisoptions',[ ...
    'title style={font=\footnotesize},'...
    'xlabel style={font=\footnotesize},'...
    'ylabel near ticks,'... 'every axis y label/.style={font=\footnotesize,at={(ticklabel cs:0.5,0.3)},rotate=90,anchor=center},'  ...
    'ticklabel style={font=\scriptsize},' ...
    'legend style={font=\scriptsize,at={(1.45,1)},anchor=north east},' ...
    ...'legend pos=outer north east,' ...
    ... 'height=0.3\linewidth,'...
    ...' scaled y ticks = false,' ...
    ...' y tick label style={/pgf/number format/fixed},' ...
    ]);


