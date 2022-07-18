function [exectime, data] = ctrlvelpi_purgefr(segment, data)
%CTRLVELPI_PURGEFR Kernel implementation of the purge flow rate
%controller. Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas10
%   - analog in for setpoint (r5*fp)
%
% OUTPUTS
%   - net message xmv6 to actuator + to EWS
%   - net message with error(5) to EWS
%   - (performance) end-to-end delay

switch segment
    case 1 % compute setpoint - measurement error
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        else
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            % End-to-end delay
            timenow = ttCurrentTime();
            ttAnalogOut(1, timenow - msg.timestamp);
        end
        ref = ttAnalogIn(1);
        data.error = ref - ymeas; data.ref = ref;
        % compute control signal
        data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
        if data.usignal > data.Hi
            data.usignal = data.Hi;
        elseif data.usignal < data.Lo
            data.usignal =  data.Lo;
        end
        % Send control signal xmv6 over specified channel to actuator + to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [3 3; 4 5], 'order', 6);
        ttSendMsg([2 1], msg, 160);
        % Send current error(4) to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 25);
        ttSendMsg([2 1], msg, 160);
        % Refresh values in memory.
        data.PreviousError = data.error;
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end