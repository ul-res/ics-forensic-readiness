function ctrlvelpi_purgefr_init

ttInitKernel('prioFP');

data.Kc                  = 0.01;
data.Ti                  = 0.001/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 40.064;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 0;
data.TaskName            = 'task_ctrlvelpi_purgefr';
data.exectime            = 1e-7; % 0.1 ms

ttCreateTask(data.TaskName,  0.1,'ctrlvelpi_purgefr',data);
ttAttachNetworkHandler(2, data.TaskName);