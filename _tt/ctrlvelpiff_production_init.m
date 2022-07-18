function ctrlvelpiff_production_init

ttInitKernel('prioFP');

data.Kc                  = 3.2;
data.Kp                  = 100/22.89;
data.Ti                  = 120/60;
data.Ts                  = 5e-4;
data.PreviousUsignal     = -0.4489;
data.Hi                  = 30;
data.Lo                  = -30;
data.PreviousError       = 0;
data.PreviousYmeas       = 22.89;
data.TaskName            = 'task_ctrlvelpiff_production';
data.exectime            = 1e-7; % 0.1 ms
data.error               = 0;
data.usignalff           = 0;
data.usignal             = 0;

ttCreateTask(data.TaskName,  0.1,'ctrlvelpiff_production',data);
ttAttachNetworkHandler(2, data.TaskName);