function [exectime, data] = actuator(segment, data)
%ACTUATOR Truetime implementation of actuator kernels for the networked
%Tennessee-Eastman simulation.

switch segment
    case 1 % receive control signal
        msg = ttGetMsg();
        if isempty(msg)
            data.usignal = data.PreviousUsignal;
        else
            data.usignal = msg.data;
            % End-to-end (controller to actuator) time delay (performance)
            timenow = ttCurrentTime;
            ttAnalogOut(2, timenow - msg.timestamp);
        end
        % Output control signal
        ttAnalogOut(1,data.usignal);
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end