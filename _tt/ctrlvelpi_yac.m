function [exectime, data] = ctrlvelpi_yac(segment, data)
%CTRLVELPI_YAC Kernel implementation of the yAC composition controller.
%Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas2325
%   - analog in 1 for "loop14"
%   - analog in 2 for setpoint
%   - analog in 3 for "Fp"
%
% OUTPUTS
%   - analog out 1 as r4
%   - net message with r4 to EWS
%   - net message with ysp(8) to EWS
%   - net message with error(12) to EWS
%   - (performance) end-to-end delay


switch segment
    case 1 % handle incoming message & compute setpoint - measurement error
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
            ref = ttAnalogIn(2);
            % Forward ysp(8) to EWS.
            msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 8);
            ttSendMsg([2 1], msg, 160);
            % Send current controller state r4 to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 18);
            ttSendMsg([2 1], msg, 160);
            % Send current error to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 33);
            ttSendMsg([2 1], msg, 160);
            exectime = -1;
        return;
        else
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            % End-to-end delay
            timenow = ttCurrentTime();
            ttAnalogOut(2, timenow - msg.timestamp);
        end
        ref = ttAnalogIn(2);
        % Forward ysp(8) to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 8);
        ttSendMsg([2 1], msg, 160);
        % Handle ref.
        data.error = ref - ymeas;
        % compute control signal
        data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError); % data.usignal is now "loop15"        
        % preprocess and send control signal over specified channel.
        loop14 = ttAnalogIn(1);
        data.usignal = data.usignal + data.PreviousUsignal - loop14; % data.usignal is now "r4"
        ttAnalogOut(1, data.usignal*ttAnalogIn(3)); % send "r4*fp" to cfr_control
        % Send current controller state r4 to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 18);
        ttSendMsg([2 1], msg, 160);
        % Send current error to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 33);
        ttSendMsg([2 1], msg, 160);
        % Refresh values in memory.
        data.PreviousError = data.error;
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end
