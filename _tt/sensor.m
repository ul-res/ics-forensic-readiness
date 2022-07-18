function [exectime, data] = sensor(segment, data)
%SENSOR Truetime implementation of sensor kernels for the networked
%Tennessee Eastman simulation.

%persistent ymeas;
switch segment
    case 1 % read
        data.ymeas = ttAnalogIn(1);
        % send to gateway
        msg = struct('timestamp', ttCurrentTime, 'data', data.ymeas, 'destination', data.Destination);
        if data.order ~= 0 % This sensor measurement IS included for anomaly detection.
            msg.order = data.order;
        end
        ttSendMsg([1 1], msg, 160);
        exectime = -1;
end
