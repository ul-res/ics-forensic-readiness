function ctrlvelpi_sep_level_init

ttInitKernel('prioFP');
data = struct();

data.Kc                  = -1e-3;
data.Ti                  = 200/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 0.2516;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 50;
data.TaskName            = 'task_ctrlvelpi_sep_level';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_sep_level', data);
ttAttachNetworkHandler(2, data.TaskName);