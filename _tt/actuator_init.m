function actuator_init(actuator_param)
%SENSOR_INIT Initialisation script for Truetime actuator implementation for
%the Tennessee-Eastman process.
% Upon receiving a control signal, the actuator implements the
% corresponding control actions.
% The argument provided to this script in the corresponding kernel block
% should be a struct with the following fields:
%   - Name      <string> Actuator name, used to specify a unique task
%   - x0        <double> Initial control signal
%   

ttInitKernel('prioFP');

data.exectime               = 1e-7; %0.1ms
data.TaskName               = actuator_param.Name;
data.PreviousUsignal        = actuator_param.x0;
data.usignal                = actuator_param.x0;

ttCreatePeriodicTask(data.TaskName, 0, 5e-4, 'actuator', data);
ttAttachNetworkHandler(3,data.TaskName);
