function ctrlvelpi_sepfr_init

ttInitKernel('prioFP');

data.Kc                  = 4e-4;
data.Ti                  = 0.001/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 38.1;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 50;
data.TaskName            = 'task_ctrlvelpi_sepfr';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_sepfr', data);
ttAttachNetworkHandler(2, data.TaskName);