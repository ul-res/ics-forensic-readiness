function [exectime, data] = ctrlvelpi_stripfr(segment, data)
%CTRLVELPI_STRIPFR Kernel implementation of the stripper flow rate
%controller. Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas17
%   - analog in for setpoint (r7*fp)
%
% OUTPUTS
%   - net message with xmv8 to actuator + to EWS
%   - net message with error(10)
%   - (performance) end-to-end delay


switch segment
    case 1 % handle incoming message & compute setpoint - measurement error
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        elseif isfield(msg,'data') % if message received is a sensor message, compute next controller input.
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            tic;
            % End-to-end delay
%             timenow = ttCurrentTime();
%             ttAnalogOut(1, timenow - msg.timestamp);
            ref = ttAnalogIn(1); data.ref = ref;
            data.error = ref - ymeas;
            % compute control signal
            data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
            if data.usignal > data.Hi
                data.usignal = data.Hi;
            elseif data.usignal < data.Lo
                data.usignal =  data.Lo;
            end
            % Send control signal with xmv8 to actuator + to EWS.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [3 6; 4 5], 'order', 8);
            ttSendMsg([2 1], msg, 160);
            % Send current error(10) to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 31);
            ttSendMsg([2 1], msg, 160);
            % Check if logging is requested.
            if data.logNext ~= 0
                teforensiclog(ttCurrentTime,data,'CONTROL_STRIP_FLOWR', data.logNext);
                data.logNext = 0;
            end
            % Refresh values in memory.
            data.PreviousError = data.error;
            data.PreviousUsignal = data.usignal;
            % Measure execution time (performance)
            ttAnalogOut(1, toc);
        elseif isfield(msg,'forensiclog')
            % If a logging request is received, log data on the next controller execution.
            data.logNext = msg.logid;
        end
        exectime = -1;
end