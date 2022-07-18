function ctrlvelpi_strip_level_init

ttInitKernel('prioFP');

data.Kc                  = -2e-4;
data.Ti                  = 200/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 0.2295;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 50;
data.TaskName            = 'task_ctrlvelpi_strip_level';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_strip_level', data);
ttAttachNetworkHandler(2, data.TaskName);