function kf1y_init(kf1y_param)
%KF1Y_INIT Initialises the kernel for the sensor outputs receiver.
%
%   Kernel function: KF1Y


ttInitKernel('prioFP');

data.y = zeros(16,3);
data.y0 = kf1y_param.y0;
data.areAllMeasReceived = 0;
% Initialize measurement vector. First column is for values, second
% for the order of each value, and third is for timestamps (used for
% debugging).
data.y(:,1) = data.y0;
data.y(:,2) = 1:16;

%ttCreateTask('task_kf1y', 5e-4, 'kf1y', data);
ttCreatePeriodicTask('task_kf1y', 0.0, 5e-4, 'kf1y', data);
ttAttachNetworkHandler(4, 'task_kf1y');
ttCreateMailbox('sensor_outputs', 16);
