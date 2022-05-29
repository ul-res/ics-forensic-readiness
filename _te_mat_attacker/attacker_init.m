function attacker_init(att_param)
%SENSOR_INIT Initialisation script for Truetime attack node implementation
%   

ttInitKernel('prioFP');

data.start = att_param.Start;
data.falseAlarmRate = att_param.FalseAlarmRate;
data.AttackedSensors = sort(att_param.AttackedSensors);
data.AttackCoef = att_param.AttackCoef;

ttCreatePeriodicTask('attack_node', 0, 5e-4, 'attacker', data);
