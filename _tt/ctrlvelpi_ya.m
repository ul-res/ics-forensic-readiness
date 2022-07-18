function [exectime, data] = ctrlvelpi_ya(segment, data)
%CTRLVELPI_YA Kernel implementation of the yA composition controller.
%Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas2325
%   - analog in 1 for setpoint ysp(7)
%   - analog in 2 for Fp
%
% OUTPUTS
%   - analog out 1 as r1
%   - analog out 2 as loop14
%   - net message with r1 to EWS
%   - net message with error(11) to EWS
%   - net message with ysp(7) to EWS
%   - (performance) end-to-end delay


switch segment
    case 1 % handle incoming message & compute setpoint - measurement error
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
            ref = ttAnalogIn(1);
            t = ttCurrentTime;
            % Forward ysp(7) to EWS.
            msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 7);
            ttSendMsg([2 1], msg, 160);
            % Send current controller state r1 to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 15);
            ttSendMsg([2 1], msg, 160);
            % Send current error to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 32);
            ttSendMsg([2 1], msg, 160);
            exectime = -1;
            return;
        else
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            % End-to-end delay
            timenow = ttCurrentTime();
            ttAnalogOut(3, timenow - msg.timestamp);
        end
        ref = ttAnalogIn(1);
        % Forward ysp(7) to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 7);
        ttSendMsg([2 1], msg, 160);
        % Handle ref.
        data.error = ref - ymeas;
        % compute control signal
        data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError); % data.usignal is now "loop14"        
        % Send control signals over specified channel.
        ttAnalogOut(2, data.usignal); % send "loop14" to yAC control
        data.usignal = data.usignal + data.PreviousUsignal; % data.usignal is now "r1"
        ttAnalogOut(1, data.usignal*ttAnalogIn(2)); % send "r1*fp" to afr_control
        % Send current controller state r1 to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 15);
        ttSendMsg([2 1], msg, 160);
        % Send current error to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 32);
        ttSendMsg([2 1], msg, 160);
        % Refresh values in memory.
        data.PreviousError = data.error;
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end
