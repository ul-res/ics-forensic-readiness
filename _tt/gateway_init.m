function gateway_init
%GATEWAY_INIT Initialises the gateway kernel for communication between
%networks.
%
%   Kernel function: GATEWAY

ttInitKernel('prioFP');

data.NetworkList = 1:4;

ttCreateTask('task_gateway', 0.1, 'gateway', data);

for i = data.NetworkList
    ttAttachNetworkHandler(i, 'task_gateway');
end
