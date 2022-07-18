function [exectime, data] = ctrlvelpiff_prod_moleperc(segment, data)
%CTRLVELPIFF_PROD_MOLEPERC Kernel implementation of production mole percent
%controller. Standard velocity PI controller + feedforward + some ratio
%handlers.
%
% INPUTS
%   - net message from sensor xmeas40
%   - analog in for setpoint (ysp(6))
%   - analog in for Fp (from production controller)
%
% OUTPUTS
%   - analog out 1 r2*fp
%   - analog out 2 r3*fp
%   - net message with ysp(6) to EWS.
%   - net message with Eadj to EWS.
%   - net message with r2 to EWS.
%   - net message with r3 to EWS.
%   - net message with error(15) to EWS.
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
            ttAnalogOut(3, timenow - msg.timestamp);
        end
        data.ref = ttAnalogIn(1);
        % Forward ysp(6) to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', data.ref, 'destination', [4 5], 'ysp', 6);
        ttSendMsg([2 1], msg, 160);
        % Handle ref.
        data.error = data.ref - ymeas;
        % compute control signal
        data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal; % This yields Eadj       
        % Compute feedforward signals
        fp = ttAnalogIn(2);
        r2 = (polyval([1.5192e-003  5.9446e-001  2.7690e-001], data.ref) - 32*data.PreviousUsignal/fp);
        r3 = (polyval([-1.1377e-003 -8.0893e-001  9.1060e+001], data.ref) + 46*data.PreviousUsignal/fp);
        % Send r2 to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', r2, 'destination', [4 5], 'order', 16);
        ttSendMsg([2 1], msg, 160);
        % Send r3 to EWS.
        msg = struct('timestamp', ttCurrentTime, 'data', r3, 'destination', [4 5], 'order', 17);
        ttSendMsg([2 1], msg, 160);
        % Output r2 and r3 on the analog channels.
        ttAnalogOut(1, r2*fp);
        ttAnalogOut(2, r3*fp);
        % Send current controller state Eadj to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 13);
        ttSendMsg([2 1], msg, 160);
        % Send current error(15) to the EWS for the look-ahead initialisation.
        msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 36);
        ttSendMsg([2 1], msg, 160);
        % Refresh values in memory.
        data.PreviousError = data.error;
        data.PreviousUsignal = data.usignal;
        exectime = -1;
end
