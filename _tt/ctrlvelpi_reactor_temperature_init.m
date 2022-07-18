function ctrlvelpi_reactor_temperature_init

ttInitKernel('prioFP');

data.Kc                  = -8;
data.Ti                  = 7.5/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 41.106;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 122.9;
data.TaskName            = 'task_ctrlvelpi_reactor_temperature';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1,'ctrlvelpi_reactor_temperature',data);
ttAttachNetworkHandler(2, data.TaskName);