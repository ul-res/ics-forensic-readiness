function sensor_init(sensor_param)
%SENSOR_INIT Initialisation script for Truetime sensor implementation for
%the Tennessee-Eastman process.
%
% Sensors are assumed to periodically sample the analog output of the plant
% according to a sampling time Ts, they then send the sampled measurement
% to destination addresses specified by the user.
% The argument provided to this script in the kernel block should be a
% struct with the following fields:
%   - Name          <string> Sensor name, used to initiate a unique task.
%   - Ts            <double> Sampling time
%   - Destination   <1x2 int> destination address, specified as a 1x2
%                             vector: [network_id, node_id]
%
% Sensor messages are structs with the following fields:
%   - timestamp     <double> Message time stamp
%   - data          <void>   Message contents, typically of type double
%   - destination   <1x2 int> destination address, specified as a 1x2
%                             vector: [network_id, node_id]


ttInitKernel('prioFP');

data.exectime               = 1e-7; % 0.1ms
data.TaskName               = sensor_param.Name;
data.Ts                     = sensor_param.Ts;
data.Destination            = sensor_param.Destination;
if isfield(sensor_param, 'order')
    data.order = sensor_param.order;
else
    data.order = 0;
end


ttCreatePeriodicTask(data.TaskName, 0.0, data.Ts, 'sensor', data);

