function sensor_xmeas2325_init
%SENSOR_XMEAS2325_INIT Special sensor function for xmeas23 and xmeas25.

ttInitKernel('prioFP');

data.exectime               = 1e-7; % 0.1ms
data.TaskName               = 'sensor_xmeas2325';
%data.Ts                     = 0.1;
data.Ts = 0.1;

ttCreatePeriodicTask(data.TaskName, 0.0, data.Ts, 'sensor_xmeas2325', data);