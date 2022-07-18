function ctrlvelpi_yac_init

ttInitKernel('prioFP');

data.Kc                  = 3e-4;
data.Ti                  = 2;
% data.Ts                  = 0.1;
data.Ts                  = 0.1;
data.PreviousUsignal     = 0.0935;
data.PreviousError       = 0;
data.PreviousYmeas       = 0;
data.TaskName            = 'task_ctrlvelpi_yac';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;

%ttCreateTask(data.TaskName, 0.1, 'ctrlvelpi_yac', data);
ttCreatePeriodicTask(data.TaskName, 0, 5e-4, 'ctrlvelpi_yac', data); 

ttAttachNetworkHandler(2, data.TaskName);