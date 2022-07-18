function ctrlvelpi_reactor_pressure_init

ttInitKernel('prioFP');

data.Kc                  = -1e-4;
data.Ti                  = 20/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 0.0034;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 2800;
data.TaskName            = 'task_ctrlvelpi_reactor_pressure';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_reactor_pressure', data);
ttAttachNetworkHandler(2, data.TaskName);