function [exectime, data] = ctrlvelpi_afr(segment, data)
%CTRLVELPI_AFR Kernel implementation of the A feed rate controller.
%Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas1
%   - analog in for setpoint (r1*fp)
%
% OUTPUTS
%   - net message with xmv3_0 to actuator and to EWS
%   - net message with error(13) to EWS
%   - (performance) end-to-end delay


switch segment
    case 1 % handle incoming message & compute setpoint - measurement error
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
        data.error = ref - ymeas;
        % compute control signal
        data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
        if data.usignal > data.Hi
            data.usignal = data.Hi;
        elseif data.usignal < data.Lo
            data.usignal =  data.Lo;
        end
        % Send control signal over specified channel + to EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [3 9; 4 5], 'order', 3);
        ttSendMsg([2 1], msg, 160);
        % Send current error to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 34);
        ttSendMsg([2 1], msg, 160);
        % Refresh values in memory.
        data.PreviousError = data.error;
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end