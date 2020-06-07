
close all;
clearvars;

%% 2D plot of implied theta_p constraint vs initial vy for different nc
theta_p_dot = [0, 4];
for k = 1:numel(theta_p_dot)
    nc = 2.^(0:4);
    for i=1:numel(nc)
        MPC = Derive_MPC_Reference_Previewing(...
            'Ts', 0.035 ... Increasing this allows greater access to the constrained set for an equivalent nc
            , 'nc', nc(i) ...
            , 'nr', nc(i) ...  Surprisingly nr>nc gives good results on figure 8 simulation
            , 'Q', diag([1 1 1 0 0 0 0 0]) ...
            , 'R', 0.1*eye(4) ...
            , 'umax', 0.1*ones(4,1) ... 0.05 reduces peak theta_p, 0.065 is same as 0.1
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
        
        freeVarMax = [];
        freeVarMin = [];
        x0FreeElementIndices = 4;
        x0FixedElementIndices = 1:MPC.nx;
        x0FixedElementIndices(x0FreeElementIndices) = [];
        x0Constraints = [];
        
        opt = optimoptions('linprog');
        opt.Display = 'off';
        
        vy0 = -5:0.01:5;
        j = 1;
        while j <= numel(vy0)
            x0 = [0 0 0 0 0 vy0(j) 0 theta_p_dot(k)]';
            
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
            if exitflagMax == 1 && exitflagMin == 1
                freeVarMax = [freeVarMax xMax(1:numel(x0FreeElementIndices))];
                freeVarMin = [freeVarMin xMin(1:numel(x0FreeElementIndices))];
                j=j+1;
            else
                vy0(j) = [];
            end
        end
        res{k,i}.nc = nc(i);
        res{k,i}.vy0 = vy0;
        res{k,i}.freeVarMax = freeVarMax;
        res{k,i}.freeVarMin = freeVarMin;
    end
end

figure('Position', [680 679 411 219]);
hold on;
% Plot hatched background plot
for i=size(res,2):-1:1
    h = plot([res{2,i}.vy0 fliplr(res{2,i}.vy0)],[res{2,i}.freeVarMax fliplr(res{2,i}.freeVarMin)]);
    c = get(h,'Color');
    f(2,i) = fill([res{2,i}.vy0 fliplr(res{2,i}.vy0)],[res{2,i}.freeVarMax fliplr(res{2,i}.freeVarMin)], c);
    legendStrings{2,i} = ['\(n_c = ' num2str(res{2,i}.nc) '\)'];
    hh = hatchfill(f(2,i),'single',45,3,[1 1 1]);
    set(hh,'color',c);
end

ax = gca;
ax.ColorOrderIndex = 1;

% Plot normal foreground plot
for i=size(res,2):-1:1
    h = plot([res{1,i}.vy0 fliplr(res{1,i}.vy0)],[res{1,i}.freeVarMax fliplr(res{1,i}.freeVarMin)]);
    c = get(h,'Color');
    f(1,i) = fill([res{1,i}.vy0 fliplr(res{1,i}.vy0)],[res{1,i}.freeVarMax fliplr(res{1,i}.freeVarMin)], c);
    legendStrings{1,i} = ['\(n_c = ' num2str(res{1,i}.nc) '\)'];
end


xlabel('$\dot{y} (\unit{ms^{-1}})$');
ylabel('$\theta_{p} (\unit{rad})$');
ylim([-1.5 1.5]);
xlim([-5 5]);

legend(f(1,:),legendStrings(1,:));



cleanfigure;
matlab2tikz(...
    'D:\Google_Drive\Matlab\Matt_MPC\Figures\Implied_theta_p_constraint_over_nc_vy.tex'...
    , 'width', '0.75\linewidth' ...
    , 'parseStrings', false ...
    , 'extraaxisoptions',[ ...
    'title style={font=\footnotesize},'...
    'xlabel style={font=\footnotesize},'...
    'every axis y label/.style={font=\footnotesize,at={(ticklabel cs:0.5)},rotate=90,anchor=center},'  ... Attempts to shift ylabel in a bit
    'ticklabel style={font=\scriptsize},' ...
    'legend style={font=\scriptsize, cells={anchor=east}, at={(1,1)},anchor=north,},' ...
    ... 'height=0.3\linewidth,'...
    ...' scaled y ticks = false,' ...
    ...' y tick label style={/pgf/number format/fixed},' ...
    ]);

