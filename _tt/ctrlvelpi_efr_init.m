function ctrlvelpi_efr_init

ttInitKernel('prioFP');

data.Kc                  = 1.8e-6;
data.Ti                  = 0.001/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 53.98;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 0;
data.TaskName            = 'task_ctrlvelpi_efr';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_efr', data);
ttAttachNetworkHandler(2, data.TaskName);