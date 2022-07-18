function ctrlvelpiff_prod_moleperc_init

ttInitKernel('prioFP');

data.Kc                  = -0.4;
data.Ti                  = 100/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = 0;
data.PreviousError       = 0;
data.PreviousYmeas       = 53.8;
data.TaskName            = 'task_ctrlvelpiff_prod_moleperc';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignal             = 0;
data.ref                 = 0;

ttCreateTask(data.TaskName,  0.1, 'ctrlvelpiff_prod_moleperc', data);
ttAttachNetworkHandler(2, data.TaskName)