function [exectime, data] = ctrlvelpi_reactor_level(segment, data)
%CTRLVELPI_REACTOR_TEMPERATURE Kernel implementation of the reactor
%level controller. Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas11
%   - analog in for setpoint ysp(4)
%
% OUTPUTS
%   - analog out SepTempSP for separator temperature control setpoint
%   - net message with SepTempSP to the EWS.
%   - net message with error(7)
%   - (performance) end-to-end delay


switch segment
    case 1
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        elseif isfield(msg, 'data') % if message received is a sensor message, compute next controller input.
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            tic;
            % End-to-end delay
            %timenow = ttCurrentTime();
            %ttAnalogOut(2, timenow - msg.timestamp);
            ref = ttAnalogIn(1); data.ref = ref;
            % Forward current set-point (ysp(4)) to EWS.
            msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 4);
            ttSendMsg([2 1], msg, 160);
            % Handle ref.
            data.error = ref - ymeas;
            % compute control signal
            data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
            if data.usignal > data.Hi
                data.usignal = data.Hi;
            elseif data.usignal < data.Lo
                data.usignal =  data.Lo;
            end
            % Send separator temperature setpoint over analog channel.
            ttAnalogOut(1,data.PreviousUsignal);
            % Send current controller state SepTempSP to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 39);
            ttSendMsg([2 1], msg, 160);
            % Send current error(7) to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 28);
            ttSendMsg([2 1], msg, 160);
            % Check if logging is requested.
            if data.logNext ~= 0
                teforensiclog(ttCurrentTime,data,'CONTROL_REACT_LEVEL', data.logNext);
                data.logNext = 0;
            end
            % Refresh memory values.
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
