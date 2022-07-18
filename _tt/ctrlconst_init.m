function ctrlconst_init

ttInitKernel('prioFP');

data.usignal_xmv5        = 0;
data.usignal_xmv9        = 0;
data.usignal_xmv12       = 100;

ttCreatePeriodicTask('task_ctrlconst', 0.0, 5e-4, 'ctrlconst', data);