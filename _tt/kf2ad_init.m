function kf2ad_init(ad_param)

ttInitKernel('prioFP');

data.CovMatrix  = inv(ad_param.CovMatrix);
data.Threshold  = ad_param.Threshold;
data.Alarm      = 0;
data.Residual   = 0;
data.y_meas     = zeros(16,1);
data.y_estim    = zeros(16,1);
data.diff       = 0;

ttCreatePeriodicTask('task_kf_ad', 0.0, 5e-4, 'kf_ad', data);