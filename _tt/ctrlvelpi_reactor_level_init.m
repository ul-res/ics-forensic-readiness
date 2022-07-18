function ctrlvelpi_reactor_level_init

ttInitKernel('prioFP');

data.Kc                  = 0.8;
data.Ti                  = 60/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 80.1;
data.Hi                  = 120;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 65;
data.TaskName            = 'task_ctrlvelpi_reactor_level';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_reactor_level', data);
ttAttachNetworkHandler(2, data.TaskName)