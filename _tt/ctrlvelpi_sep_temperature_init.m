function ctrlvelpi_sep_temperature_init

ttInitKernel('prioFP');

data.Kc                  = -4;
data.Ti                  = 15/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 18.11;
data.Hi                  = 100;
data.Lo                  = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 65;
data.TaskName            = 'task_ctrlvelpi_sep_temperature';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.logNext             = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpi_sep_temperature', data);
ttAttachNetworkHandler(2, data.TaskName)