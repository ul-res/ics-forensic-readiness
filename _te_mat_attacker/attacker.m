function [exectime, data] = attacker(segment, data)
%ACTUATOR Truetime implementation of attacker node.

switch segment
    case 1 % receive control signal
        if ttCurrentTime >= data.start
            attSensors = data.AttackedSensors;
            attSensorsInd = 1;
            num_in = length(attSensors);
            real_val = zeros(1,num_in);
            bias = zeros(1,num_in);
            attcoef = data.AttackCoef;
            for i = 1:16
                if attSensorsInd <= length(attSensors) && i == attSensors(attSensorsInd)
                    real_val(attSensorsInd) = ttAnalogIn(attSensorsInd);
                    bias(attSensorsInd) = -real_val(attSensorsInd)*attcoef*(ttCurrentTime - data.start) - attcoef*randn(1);
                    ttAnalogOut(i,bias(attSensorsInd));
                    attSensorsInd = attSensorsInd + 1;
                else
                    ttAnalogOut(i,0);
                end
                
            end
        else
            for i = 1:16
                ttAnalogOut(i,0);
            end
        end
        exectime = -1;
end