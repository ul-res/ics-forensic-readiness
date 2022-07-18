function [exectime, data] = ctrlvelpi_sep_level(segment, data)
%CTRLVELPI_SEP_LEVEL Kernel implementation for the separator level
%controller. Standard velocity PI controller + ratio handler.
%
% INPUTS
%   - net message from sensor xmeas12
%   - analog in (1) for setpoint
%   - analog in (2) from production controller (Fp)
%
% OUTPUTS
%   - analog out r6 for separator flowrate setpoint
%   - net message with r6 to EWS.
%   - net message with error(5).
%   - net message with ysp
%   - (performance) end-to-end delay


switch segment
    case 1
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        elseif isfield(msg,'data') % if message received is a sensor message, compute next controller input.
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            % End-to-end delay
            %timenow = ttCurrentTime();
            %ttAnalogOut(2, timenow - msg.timestamp);
            tic;
            
            ref = ttAnalogIn(1); data.ref = ref;
            % Forward ysp(3) to EWS.
            msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 3);
            ttSendMsg([2 1], msg, 160);
            % Handle ref
            data.error = ref - ymeas;
            % compute control signal
            data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
            if data.usignal > data.Hi
                data.usignal = data.Hi;
            elseif data.usignal < data.Lo
                data.usignal =  data.Lo;
            end
            % Send r6*fp (sep flowrate sp) over analog channel.
            ttAnalogOut(1, ttAnalogIn(2)*data.PreviousUsignal);
            % Send current controller state r6 to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 20);
            ttSendMsg([2 1], msg, 160);
            % Send current error to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 26);
            ttSendMsg([2 1], msg, 160);
            % Check if logging is requested.
            if data.logNext ~= 0
                teforensiclog(ttCurrentTime,data,'CONTROL_SEPAR_LEVEL', data.logNext);
                data.logNext = 0;
            end
            % Refresh values in memory.
            data.PreviousError = data.error;
            data.PreviousUsignal = data.usignal;
            % Measure execution time (performance)
            ttAnalogOut(2, toc);
        elseif isfield(msg,'forensiclog')
            % If a logging request is received, log data on the next controller execution.
            data.logNext = msg.logid;
        end
        exectime = -1;
end