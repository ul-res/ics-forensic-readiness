function [exectime, data] = ctrlvelpiff_production(segment, data)
%CTRLPVELPIFF_PRODUCTION Kernel implementation of the production
%controller. Standard velocity PI with a feedforward component.
%
% INPUTS
%   - net message from sensor xmeas17
%   - analog in for setpoint ysp(1)
%
% OUTPUTS
%   - analog out for Fp (used by multiple other nodes) % TODO: update to
%   broadcast a message.
%   - net message with fp to EWS.
%   - net message with error(2) to EWS.
%   - net message with ysp(1) to EWS.
%   - (performance) end-to-end delay


switch segment
    case 1 % Handle incoming message & compute setpoint - measurement error
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        else
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            % End-to-end delay
            timenow = ttCurrentTime();
            ttAnalogOut(2, timenow - msg.timestamp);
        end
        ref = ttAnalogIn(1);
        % Forward ysp(1) to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 1);
        ttSendMsg([2 1], msg, 160);
        % Handle ref.
        data.error = ref - ymeas;
        data.usignalff = ref*data.Kp; % FF control
        % compute control signal
        data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
        if data.usignal > data.Hi
            data.usignal = data.Hi;
        elseif data.usignal < data.Lo
            data.usignal =  data.Lo;
        end
        % Send control signal over specified channel.
        ttAnalogOut(1, data.PreviousUsignal + data.usignalff);
        % Send current controller state fp to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 14);
        ttSendMsg([2 1], msg, 160);
        % Send current error error(2) to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 23);
        ttSendMsg([2 1], msg, 160);
        % Refresh values in memory.
        data.PreviousError = data.error;
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end