function ctrlvelpi_ya_init

ttInitKernel('prioFP');

data.Kc                  = 2e-4;
data.Ti                  = 1;
%data.Ti                  = 5e-3;
% data.Ts                  = 0.1;
data.Ts                  = 0.1;
data.PreviousUsignal     = 0.0025;
data.PreviousError       = 0;
data.PreviousYmeas       = 0;
data.TaskName            = 'task_ctrlvelpi_ya';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;

%ttCreateTask(data.TaskName, 0.1, 'ctrlvelpi_ya', data);
ttCreatePeriodicTask(data.TaskName, 0, 5e-4, 'ctrlvelpi_ya', data); 
ttAttachNetworkHandler(2, data.TaskName);