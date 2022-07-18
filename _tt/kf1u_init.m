function kf1u_init
%KF1U_INIT Initialises the kernel for the control signals receiver.
%
%   Kernel function: KF1U

ttInitKernel('prioFP');

data.u = zeros(12,3);
data.u0 = [63.5903728914114,54.4416493418354,27.6655437231988,60.7653866389508,0,36.8666202816803,39.1053780631949,46.8183376245777,0,36.8362255004637,15.7681761690613,100];
data.areAllCtrlSignalsReceived = 0;

% Initialize control inputs vector. First column is for values, second
% for the order of each value, and third is for timestamps (used for
% debugging).
data.u(:,1) = data.u0;
data.u(:,2) = 1:12;


%ttCreateTask('task_kf1u', 5e-4, 'kf1u', data);
ttCreatePeriodicTask('task_kf1u', 0.0, 5e-4, 'kf1u', data);
ttAttachNetworkHandler(4, 'task_kf1u');
ttCreateMailbox('actuator_inputs',12);