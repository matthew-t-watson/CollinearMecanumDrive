

% Generate model functions into folder EKF_functions
CMD_state_estimation_model_derivation;

%% Example inputs
nx = 10;
nxk = 5; % no. kalman filter states
w = zeros(3,1);
a = zeros(2,1);
x_old = zeros(nx,1);
P_old = zeros(nxk);
theta_i_prev = zeros(4,1);
theta_i = zeros(4,1);
z=[theta_i; a; 0];
u = w;
dt = 0;

% .DLL
config = coder.config('lib');
config.GenCodeOnly = true;
config.FilePartitionMethod = 'SingleFile';
config.HardwareImplementation.ProdHWDeviceType = 'ARM Compatible->ARM Cortex';
config.EnableOpenMP = false;
config.DynamicMemoryAllocation = 'off';
config.IncludeTerminateFcn = false;
config.SupportNonFinite = false;


codegen -config config -d State_Estimation/codegen/CMD_state_estimation_single_step CMD_state_estimation_single_step -args ...
    {x_old, P_old, u, z, theta_i_prev dt};


