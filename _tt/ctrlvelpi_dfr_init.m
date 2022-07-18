function ctrlvelpi_dfr_init

ttInitKernel('prioFP');

data.Kc                  = 1.6e-6;
data.Ti                  = 0.001/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 63.053;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 0;
data.TaskName            = 'task_ctrlvelpi_dfr';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_dfr', data);
ttAttachNetworkHandler(2, data.TaskName);