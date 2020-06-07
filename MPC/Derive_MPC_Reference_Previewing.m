
function [MPC] = Derive_MPC_Reference_Previewing(modelData, varargin )


%% Default Variables
Ts = 0.02;
Q = diag([1 1 0.1 zeros(1,5)]);
R = 0.1*eye(4);
nc = 3;
nr = 0;
umax = 0.1*ones(4,1);
theta_p_max = 0.3;
v_x_max = 1;
v_y_max = 1;
phi_dot_max = 5;
removeConstraints = 0;
generateCode = false;
MAS = 'minimal';
slackType = 'individualToNiThenShared';
constraintBlockingSize = 5;
ncon = 1000; % Only used in lazy MAS derivation
nconLarge = 300; % Used to ensure constructMAS has as many slacks as it needs
ni = 1; % Constraint horizon to not block over
MAS_tolerance = 1E-9;
s_weight = [1E5 1E3 1E3 1E2];
s_weight_inf = s_weight*100;
cinf_weighting = 1E-15;
forceRegen = false;
verbosity = 0;
move_blocking_size = 1;

%% Overwrite Variables if Specified in Function Call
for i = 1:(nargin-2)
    if strcmp(varargin{i}, 'Ts')
        Ts = varargin{i+1};
    elseif strcmp(varargin{i}, 'Q')
        Q = varargin{i+1};
    elseif strcmp(varargin{i}, 'R')
        R = varargin{i+1};
    elseif strcmp(varargin{i}, 'nc')
        nc = varargin{i+1};
    elseif strcmp(varargin{i}, 'nr')
        nr = varargin{i+1};
    elseif strcmp(varargin{i}, 'umax')
        if numel(varargin{i+1}) == 4
            umax = varargin{i+1};
        else
            error('Invalid umax');
        end
    elseif strcmp(varargin{i}, 'theta_p_max')
        theta_p_max = varargin{i+1};
    elseif strcmp(varargin{i}, 'v_x_max')
        v_x_max = varargin{i+1};
    elseif strcmp(varargin{i}, 'v_y_max')
        v_y_max = varargin{i+1};
    elseif strcmp(varargin{i}, 'phi_dot_max')
        phi_dot_max = varargin{i+1};
    elseif strcmp(varargin{i}, 'removeConstraints')
        removeConstraints = varargin{i+1};
    elseif strcmp(varargin{i}, 'slackType')
        slackType = varargin{i+1};
    elseif strcmp(varargin{i}, 'constraintBlockingSize')
        constraintBlockingSize = varargin{i+1};
    elseif strcmp(varargin{i}, 'ni')
        ni = varargin{i+1};
    elseif strcmp(varargin{i}, 'generateCode')
        generateCode = varargin{i+1};
    elseif strcmp(varargin{i}, 'MAS')
        MAS = varargin{i+1};
    elseif strcmp(varargin{i}, 'MAS_tolerance')
        MAS_tolerance = varargin{i+1};
    elseif strcmp(varargin{i}, 'cinf_weighting')
        cinf_weighting = varargin{i+1};
    elseif strcmp(varargin{i}, 's_weight')
        s_weight = varargin{i+1};
    elseif strcmp(varargin{i}, 's_weight_inf')
        s_weight_inf = varargin{i+1};
    elseif strcmp(varargin{i}, 'forceRegen')
        forceRegen = varargin{i+1};
    elseif strcmp(varargin{i}, 'verbosity')
        verbosity = varargin{i+1};
    end
end

if nr==0
    nr=nc;
end

persistent prevArgs
if ~isempty(prevArgs)
    if isequal(prevArgs.varargin, varargin) && prevArgs.derivationComplete && forceRegen == false
        MPC = prevArgs.MPC;
        disp('Input unchanged, reusing existing derivation');
        return;
    end
end

prevArgs.varargin = varargin;
prevArgs.derivationComplete = false;




%% Discretise model
dscrt_sys = c2d(modelData.linsys,Ts,'zoh');
A = dscrt_sys.A; B = dscrt_sys.B; C = [eye(3) zeros(3,5)]; D = zeros(3,4);


%% Define dimensions
nx = size(A,1);
ny = size(C,1);
nu = size(B,2);

%% Derive Mx and Mu
% M = [C D; A-eye(nx) B];
% warning('off','MATLAB:rankDeficientMatrix')
% Minv = M\[eye(3) zeros(3,nx-3); zeros(nx-3,nx); zeros(nx)];
% warning('on','MATLAB:rankDeficientMatrix')
% Minv = round(Minv); % Result is binary
% 
% Mx = Minv(1:nx,1:nx);
% Mu = Minv(nx+1:nx+nu,1:nx);
Mx = pinv(C);
Mu = B\((A-eye(nx))*pinv(C));

%% Calculate unconstrained optimal feedback K
try
    K = dlqr(A,B,Q,R);
catch
    error('dlqr failed to stabilise system');
end
Phi = A - B*K;

%% Form autonomous model z_{k+1} = Psi z_k
% For move blocking implementation see http://www.dcsc.tudelft.nl/~bdeschutter/private_20100705_acc_2010/data/papers/0489.pdf
Dr = [zeros(ny*(nr-1),ny) eye(ny*(nr-1)); zeros(ny,(nr-1)*ny), eye(ny)];   % r_fut_k+2 = Dr*r_fut_k+1
Dc = [zeros(nu*(nc-1),nu) eye(nu*(nc-1)); zeros(nu,(nc)*nu)];              % c_fut_k+1 = Dc*c_fut_k
Dck = [eye(nu), zeros(nu,nu*(nc-1))];                                      % c_k = Dck*c_fut_k
Drk1 = [eye(ny), zeros(ny,ny*(nr-1))];                                     % r_k+1 = Drk1*r_fut_k+1
Ec = [zeros((nc-1)*nu,nu); eye(nu)];                                       % c_{k+nc} = c_infty

Psi = [Phi,                 B*Dck,                  zeros(nx,nu),    (eye(nx)-Phi)*Mx*Drk1;
       zeros(nc*nu,nx),     Dc,                     Ec,              zeros(nc*nu,nr*ny);
       zeros(nu,nx),        zeros(nu,nc*nu),        eye(nu),         zeros(nu,nr*ny);
       zeros(nr*ny,nx),     zeros(nr*ny,nc*nu),     zeros(nr*ny,nu), Dr];
   
Psi(end-ny+1:end,end-ny+1:end)=eye(ny)*(1-1E-15); % Fix Lyapunov for r_infty
Psi(nx+nc*nu+1:nx+nc*nu+nu,nx+nc*nu+1:nx+nc*nu+nu)=eye(nu)*(1-1E-15); % Fix Lyapunov for c_infty

%% Define cost function
Kxss = [eye(nx), zeros(nx,nc*nu), zeros(nx,nu), -Mx*Drk1];
Kuss = [-K, Dck, zeros(nu), -Mu*Drk1];

W = Psi'*Kxss'*Q*Kxss*Psi + Kuss'*R*Kuss;
S = dlyap(Psi', W);

% Force symmetry - should already be symmetric to within rounding error
S = (S+S')/2;

Sx = S(1:nx,1:nx);
Sxc = S(1:nx, nx+1:nx+nc*nu);
Sxci = S(1:nx, nx+nc*nu+1:nx+nc*nu+nu);
Sxr = S(1:nx, nx+nc*nu+nu+1:end);
Sc = S(nx+1:nx+nc*nu, nx+1:nx+nc*nu);
Scci = S(nx+1:nx+nc*nu, nx+nc*nu+1:nx+nc*nu+nu);
Scr = S(nx+1:nx+nc*nu, nx+nc*nu+nu+1:end);
Sci = S(nx+nc*nu+1:nx+nc*nu+nu, nx+nc*nu+1:nx+nc*nu+nu);
Scir = S(nx+nc*nu+1:nx+nc*nu+nu, nx+nc*nu+nu+1:end);
Sr = S(nx+nc*nu+nu+1:end, nx+nc*nu+nu+1:end);

if ~isequal([Sx Sxc Sxci Sxr; Sxc' Sc Scci Scr; Sxci' Scci' Sci Scir; Sxr' Scr' Scir' Sr], S)
    error('Bad matrix');
end

Sc(abs(Sc)<1e-11) = 0; % Reintroduce sparsity

% Define constraints
x_A = zeros(1,nx);
x_A(1,4) = 1;
x_A(2,7) = 1;

xmax = [theta_p_max; phi_dot_max];

% Derive velocity constraint polytope
M=8;
for m=-(M-1):M
%     m=m+0.5;
    x_A(end+1,5:6) = -[(sin(2*pi*(m+1)/M) - sin(2*pi*m/M)), (cos(2*pi*(m+1)/M) - cos(2*pi*m/M))];
    xmax(end+1) =  (v_x_max*cos(2*pi*m/M))*(sin(2*pi*(m+1)/M) - sin(2*pi*m/M)) - (v_y_max*sin(2*pi*m/M))*(cos(2*pi*(m+1)/M) - cos(2*pi*m/M));
    if xmax(end) > 0 % Ensure all inequalities are the same sign
        xmax(end) = -xmax(end);
        x_A(end,:) = -x_A(end,:);
    end
    x_A(end,:) = x_A(end,:)/xmax(end); % Normalise inequalities to 1
    xmax(end) = 1;
end
% m=m-0.5; % Remove shift again
m=m*2;

f = [umax; umax; xmax; xmax];

if strcmp(slackType, 'none')
    Ds = [];
    Ss = [];
    Dsk = [];
    ns = 0;
elseif strcmp(slackType, 'individual')
%     % Slack shift matrix
%     Ds = [zeros(numel(xmax)*(nconLarge-1),numel(xmax)) eye(numel(xmax)*(nconLarge-1)); zeros(numel(xmax),nconLarge*numel(xmax))];
%     Ss = diag(repmat(s_weight, [1 nconLarge]));
%     Dsk = [eye(numel(xmax)), zeros(numel(xmax),numel(xmax)*(nconLarge-1))];
%     ns = numel(xmax)*nconLarge;
elseif strcmp(slackType, 'individualToNc')
%     % Slack shift matrix
%     Ds = [zeros(numel(xmax)*(nc-1),numel(xmax)) eye(numel(xmax)*(nc-1)); zeros(numel(xmax),(nc)*numel(xmax))];
%     Ss = diag(repmat(s_weight, [1 nc]));
%     Dsk = [eye(numel(xmax)), zeros(numel(xmax),(numel(xmax)*(nc-1)))];
%     ns = numel(xmax)*nc;
elseif strcmp(slackType, 'individualToNi')
%     % Slack shift matrix
%     Ds = [zeros(numel(xmax)*(ni-1),numel(xmax)) eye(numel(xmax)*(ni-1)); zeros(numel(xmax),(ni)*numel(xmax))];
%     Ss = diag(repmat(s_weight, [1 ni]));
%     Dsk = [eye(numel(xmax)), zeros(numel(xmax),(numel(xmax)*(ni-1)))];
%     ns = numel(xmax)*ni;
elseif strcmp(slackType, 'individualToNcThenShared') || strcmp(slackType, 'blockedToNcThenShared') || strcmp(slackType, 'sharedToNcThenShared') || strcmp(slackType, 'individualToNiBlockedToNcThenShared')
%     % One set of slacks per nc, then one set to the infinite horizon
%     Ds = [zeros(numel(xmax)*(nc),numel(xmax)) eye(numel(xmax)*(nc)); zeros(numel(xmax),numel(xmax)*(nc)) eye(numel(xmax))];
%     %Ss = diag([repmat(s_weight/nc, [1 nc]) s_weight_inf]);
%     Dsk = [eye(numel(xmax)), zeros(numel(xmax),(numel(xmax)*(nc)))];
%     ns = numel(xmax)*nc + numel(xmax);
elseif strcmp(slackType, 'individualToNiThenShared')
    % One set of slacks per ni, then one set to the infinite horizon
    Ds = [zeros(numel(s_weight)*(ni),numel(s_weight)) eye(numel(s_weight)*(ni)); zeros(numel(s_weight),numel(s_weight)*(ni)) eye(numel(s_weight))];
    Ss = diag([repmat(s_weight, [1 ni]) s_weight_inf]);
    Dsk = [blkdiag(1, ones(m,1), 1), zeros(size(x_A,1),(numel(s_weight)*(ni)))];
    ns = numel(s_weight)*ni + numel(s_weight);
elseif strcmp(slackType, 'individualToNiForThetaPAndVyThenShared') % We don't need to give quite as much freedom to phi and x subsystems
%     % One slack for x and phi's first constraint, ni slacks for y and
%     % thetap constraints, then one shared slack for x y phi thetap.
%     % Could this be extended to use only ni-1 ydot/theta_p constraints? One
%     % of them should be possible to reduce, not immediately certain which
%     Ds = [zeros(numel(xmax)*(ni),numel(xmax)) diag([repmat([1 0 1 0],[1 (ni-1)]) [1 1 1 1]]); zeros(numel(xmax),numel(xmax)*(ni)) diag([1 1 1 1])];
%     Ss = diag([repmat(s_weight, [1 ni]) s_weight_inf]);
%     Dsk = [diag([1 0 1 0]) zeros(numel(xmax),numel(xmax)*(ni-2)) diag([0 1 0 1]) zeros(numel(xmax))];
%     ns = numel(xmax)*ni + numel(xmax);
elseif strcmp(slackType, 'individualToNiForThetaPAndVyThenSharedv2') % We don't need to give quite as much freedom to phi and x subsystems
%     % One slack for x y and phi's first constraint, ni slacks for 
%     % thetap constraint, then one shared slack for x y phi thetap.
%     % Could this be extended to use only ni-1 ydot/theta_p constraints? One
%     % of them should be possible to reduce, not immediately certain which
%     Ds = [zeros(numel(xmax)*(ni),numel(xmax)) diag([repmat([1 0 0 0],[1 (ni-1)]) [1 1 1 1]]); zeros(numel(xmax),numel(xmax)*(ni)) diag([1 1 1 1])];
%     Ss = diag([repmat(s_weight, [1 ni]) s_weight_inf]);
%     Dsk = [diag([1 0 0 0]) zeros(numel(xmax),numel(xmax)*(ni-2)) diag([0 1 1 1]) zeros(numel(xmax))];
%     ns = numel(xmax)*ni + numel(xmax);
elseif strcmp(slackType, 'individualToNiForThetaPAndVyThenSharedv3') % We don't need to give quite as much freedom to phi and x subsystems
%     % One slack for x thetap and phi's first constraint, ni slacks for 
%     % y constraint, then one shared slack for x y phi thetap.
%     % Could this be extended to use only ni-1 ydot/theta_p constraints? One
%     % of them should be possible to reduce, not immediately certain which
%     Ds = [zeros(numel(xmax)*(ni),numel(xmax)) diag([repmat([0 0 1 0],[1 (ni-1)]) [1 1 1 1]]); zeros(numel(xmax),numel(xmax)*(ni)) diag([1 1 1 1])];
%     Ss = diag([repmat(s_weight, [1 ni]) s_weight_inf]);
%     Dsk = [diag([0 0 1 0]) zeros(numel(xmax),numel(xmax)*(ni-2)) diag([1 1 0 1]) zeros(numel(xmax))];
%     ns = numel(xmax)*ni + numel(xmax);
elseif strcmp(slackType, 'shared')
%     ns = numel(xmax);
%     % Slack cost
%     Ss = diag(s_weight_inf);
%     Ds = eye(ns);
%     Dsk = eye(ns);
else
    error('Invalid slack type');
end


%% Redefine Psi to incorporate feedforward term and slacks before we use Psi for constraint derivation
Psi = [
    Phi,                B*Dck,              zeros(nx,nu),       B*Dck*-(Sc\Scr) + (eye(nx)-Phi)*Mx*Drk1,    zeros(nx,ns);
    zeros(nc*nu,nx),    Dc,                 Ec,                 zeros(nc*nu,nr*ny),                         zeros(nc*nu,ns);
    zeros(nu,nx),       zeros(nu,nc*nu),    eye(nu),            zeros(nu,nr*ny),                            zeros(nu,ns);
    zeros(nr*ny,nx),    zeros(nr*ny,nc*nu), zeros(nr*ny,nu),    Dr,                                         zeros(nr*ny,ns);
    zeros(ns,nx),       zeros(ns,nc*nu),    zeros(ns,nu),       zeros(ns,nr*ny),                            Ds];
    

%% Define constraint matrices G and f
G = [
    -K,     Dck,                        zeros(nu),                  -Dck*(Sc\Scr) + (K*Mx+Mu)*Drk1, zeros(nu,ns);
    K,      -Dck,                       zeros(nu),                  Dck*(Sc\Scr) - (K*Mx+Mu)*Drk1,  zeros(nu,ns);
    x_A, 	zeros(size(x_A,1),nc*nu), zeros(size(x_A,1),nu),    zeros(size(x_A,1),ny*nr),     -Dsk;
    -x_A, zeros(size(x_A,1),nc*nu), zeros(size(x_A,1),nu),    zeros(size(x_A,1),ny*nr),     -Dsk;
    ];

% % Remove redundant rows - for some reason this currently yields a different
% % polytope?!?!?
% [~,iA] = uniquetol([G f],'ByRows',true);
% G = G(iA,:);
% f = f(iA);

%% Construct MAS
if strcmp(MAS,'minimal')
    try
        [F, t] = construct_mas(Psi,G,f,removeConstraints,ns,MAS_tolerance,verbosity,forceRegen); 
        ncon = numel(t);
    catch err
        error([err.message '\nFailed to derive MAS'],'char');
    end
elseif strcmp (MAS,'lazy')
    F = [];
    t = [];
    for i=0:ncon
        F = [F; G*Psi^i];
        t = [t;f];
    end
end

%% Correct elements of F that are near zero
F(abs(F)<1E-12) = 0;

%% Populate constraint matrices
Fx=F(:,1:nx);
% Fx_half=F_half(:,1:nx);
Fc=F(:,nx+1:nx+nu*nc);
Fci=F(:,nx+nu*nc+1:nx+nu*nc+nu);
Fr=F(:,nx+nu*nc+nu+1:nx+nu*nc+nu+ny*nr);
% Fr_half=F_half(:,nx+nu*nc+nu+1:nx+nu*nc+nu+nx*nr);
Fs=F(:,nx+nu*nc+nu+ny*nr+1:end);

% % Make some slacks shared
% if strcmp(slackType, 'blockedToNcThenShared') 
%     numBlocks = nc / constraintBlockingSize;
%     if rem(nc, constraintBlockingSize) ~= 0
%         error('Constraint block size does not divide into nc');
%     end
%     
%     FsNew = [];
%     for i=1:numBlocks
%         for k=1:numel(xmax)
%             FsNew = [FsNew sum(Fs(:,(i-1)*constraintBlockingSize*numel(xmax) + (k:numel(xmax):k+(constraintBlockingSize-1)*numel(xmax))),2) ];
%         end
%     end
%     
%     FsNew = [FsNew Fs(:,end-numel(xmax)+1:end)];
%     Fs = FsNew;
%     
%     Ss = diag([repmat(s_weight*constraintBlockingSize, [numBlocks 1])     s_weight_inf]);
%     
%     ns = size(Ss,1);
%     
% elseif strcmp(slackType, 'individualToNiBlockedToNcThenShared') 
%     numBlocks = (nc-ni) / constraintBlockingSize;
%     if rem(nc-ni, constraintBlockingSize) ~= 0
%         error('Constraint block size does not divide into nc-ni');
%     end
%     
%     FsNew = Fs(:,1:ni*numel(xmax));
%     for i=1:numBlocks
%         for k=1:numel(xmax)
%             FsNew = [FsNew ...
%                 sum( ...
%                 Fs(:,(i-1)*constraintBlockingSize*numel(xmax) + ni*numel(xmax) + (k:numel(xmax):k+(constraintBlockingSize-1)*numel(xmax))) ...
%                 ,2) ];
%         end
%     end
%     
%     FsNew = [FsNew Fs(:,end-numel(xmax)+1:end)];
%     Fs = FsNew;
%     
%     Ss = diag([repmat(s_weight, [ni 1])    repmat(s_weight*constraintBlockingSize, [numBlocks 1])     s_weight_inf]);
%     
%     ns = size(Ss,1);
%         
% elseif strcmp(slackType, 'sharedToNcThenShared')
%     Fs = [sum(Fs(:,1:numel(xmax):nc*numel(xmax)),2) ...
%         sum(Fs(:,2:numel(xmax):nc*numel(xmax)),2) ...
%         sum(Fs(:,3:numel(xmax):nc*numel(xmax)),2) ...
%         sum(Fs(:,4:numel(xmax):nc*numel(xmax)),2) ...
%         Fs(:,nc*numel(xmax)+1:end)];
%     Ss = diag([s_weight*nc    s_weight_inf]);
%     ns = numel(xmax)*2;
% end


% Trim Fs and Ss
i = 1;
previousNs = ns;
while i<=size(Fs,2)
    if nnz(Fs(:,i)) == 0
        Fs(:,i) = [];
        Ss(:,i) = [];
        Ss(i,:) = [];
        ns = ns-1;
        i=i-1;
    end
    i=i+1;
end
if verbosity >= 1
    disp(['Trimmed slacks from ' num2str(previousNs) ' to ' num2str(ns)]);
end



%% Define Hessian
H = blkdiag(Sc, cinf_weighting*Sci, Ss);
H = (H+H')/2; % Make Hessian symmetrical

% Fr(abs(Fr)<1E-13) = 0; % Not thoroughly tested for robustness
% Fx(abs(Fx)<1E-13) = 0;

A = [Fc, Fci, Fs];

Ginf = C*inv(eye(nx)-Phi)*B;
Ginfinv = pinv(Ginf);

%% Define Anonymous functions
calculate_b = @(x, r) t-Fx*x-Fr*r;
calculate_b_lb = @(x, r) -t-Fx*x-Fr*r;
calculate_u = @(x,r,c) -K*x + (K*Mx + Mu)*Drk1*r + Dck*-(Sc\Scr)*r + Dck*c;

% Remove unwanted memory
calculate_b = afclean(calculate_b);
calculate_b_lb = afclean(calculate_b_lb);
calculate_u = afclean(calculate_u);

%% Generate additional functions
if generateCode
        
    Pr = (K*Mx+Mu)*Drk1 + Dck*-(Sc\Scr);
        
    config = coder.config('LIB','ecoder',true);
    config.FilePartitionMethod = 'SingleFile';
    %config.GenerateCodeReplacementReport = true;
    %config.CodeReplacementLibrary = 'BLAS Replacement Examples';
    config.GenCodeOnly = true;
    config.IncludeTerminateFcn = false;
    config.InitFltsAndDblsToZero = false;
    config.SupportNonFinite = false;
    config.GenerateExampleMain = 'DoNotGenerate';
    config.GenerateMakefile = false;
    config.TargetLang = 'C++';
    config.DataTypeReplacement = 'CoderTypedefs';
    codegen calculate_b -d MPC/codegen/calculate_b -config config -args {zeros(nx,1), zeros(ny*nr,1), coder.Constant(Fr), coder.Constant(Fx), coder.Constant(t)};
    codegen calculate_u -d MPC/codegen/calculate_u -config config -args {zeros(nx,1), zeros(ny*nr,1), zeros(nc*nu,1), coder.Constant(Pr), coder.Constant(K)};
    codegen calculate_cinf -d MPC/codegen/calculate_cinf -config config -args {zeros(nx,1), zeros(ny*nr,1), coder.Constant(Ginfinv), coder.Constant(ny)};
    
    % Copy files to D:\Google_Drive\GitHub\MPC_qpOASES
    copyfile('MPC/codegen/calculate_b/calculate_b.cpp', 'D:\Google_Drive\GitHub\MPC_qpOASES\src\calculate_b.cpp');
    copyfile('MPC/codegen/calculate_b/calculate_b.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\calculate_b.h');
    copyfile('MPC/codegen/calculate_u/calculate_u.cpp', 'D:\Google_Drive\GitHub\MPC_qpOASES\src\calculate_u.cpp');
    copyfile('MPC/codegen/calculate_u/calculate_u.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\calculate_u.h');
    copyfile('MPC/codegen/calculate_cinf/calculate_cinf.cpp', 'D:\Google_Drive\GitHub\MPC_qpOASES\src\calculate_cinf.cpp');
    copyfile('MPC/codegen/calculate_cinf/calculate_cinf.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\calculate_cinf.h');
    copyfile('MPC/codegen/calculate_u/calculate_u_types.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\calculate_u_types.h');
    copyfile('MPC/codegen/calculate_b/calculate_b_types.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\calculate_b_types.h');
    copyfile('MPC/codegen/calculate_cinf/calculate_cinf_types.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\calculate_cinf_types.h');
    copyfile('MPC/codegen/calculate_u/rtwtypes.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\rtwtypes.h');
    
    % Other matlab files needed to compile
    copyfile('C:\Program Files\MATLAB\R2018a\extern\include\tmwtypes.h', 'D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\tmwtypes.h');
   
    
    H_nrows = size(H,1);
    H_ncols = size(H,2);
    A_nrows = size(A,1);
    A_ncols = size(A,2);
    
    % Convert constants to C
    variableToCDefine('D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\MPC_defines.hpp', nx, nu, nc, ns, nr, ncon, H_nrows, H_ncols, A_nrows, A_ncols);
    variableToCDoubleDefinition('D:\Google_Drive\GitHub\MPC_qpOASES\include\MPC_qpOASES\MPC_double_consts.hpp', H, A, Fr, Fx, t, K, Pr, Ginfinv);
end

%% Package up MPC data
MPC.dscrt_sys = dscrt_sys;
MPC.Phi = Phi;
MPC.Psi = Psi;
MPC.Scr = Scr;
MPC.Sc = Sc;
MPC.H = H;
MPC.Fx = Fx;
% MPC.Fx_half = Fx_half;
MPC.Fc = Fc;
MPC.Fci = Fci;
MPC.Fr = Fr;
% MPC.Fr_half = Fr_half;
MPC.Fs = Fs;
MPC.A = A;
MPC.t = t;
MPC.K = K;
MPC.Drk1 = Drk1;
MPC.Dck = Dck;
MPC.Mx = Mx;
MPC.Mu = Mu;
MPC.Ts = Ts;
MPC.nc = nc;
MPC.nr = nr;
MPC.nx = nx;
MPC.ny = ny;
MPC.nu = nu;
MPC.ns = ns;
MPC.ncon = ncon;
MPC.umax = umax;
MPC.umin = -umax;
MPC.theta_p_max = theta_p_max;
MPC.v_x_max = v_x_max;
MPC.v_y_max = v_y_max;
MPC.phi_dot_max = phi_dot_max;
MPC.calculate_b = calculate_b;
MPC.calculate_b_lb = calculate_b_lb;
MPC.calculate_u = calculate_u;
MPC.calculate_r_hat = @(cinf) (dscrt_sys.C*((eye(nx)-Phi)\dscrt_sys.B))*cinf;
MPC.calculate_r_hat = afclean(MPC.calculate_r_hat);
MPC.Ginfinv = Ginfinv;

if verbosity >= 1
    disp(['Derivation complete, ncon = ' num2str(ncon)]);
end
    
prevArgs.MPC = MPC;
prevArgs.derivationComplete = true;

end
