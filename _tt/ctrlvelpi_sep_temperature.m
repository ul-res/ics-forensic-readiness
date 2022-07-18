function [exectime, data] = ctrlvelpi_sep_temperature(segment, data)
%CTRLVELPI_SEP_TEMPERATURE Kernel implementation of the separator
%temperature controller. Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas11
%   - analog in for setpoint
%
% OUTPUTS
%   - net message with xmv11 to actuator + to EWS
%   - net message with error(8) to EWS
%   - (performance) end-to-end delay


switch segment
    case 1 % handle incoming message & compute setpoint - measurement error
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        elseif isfield(msg,'data')
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            % End-to-end delay
            %timenow = ttCurrentTime();
            %ttAnalogOut(1, timenow - msg.timestamp);
            tic;
            ref = ttAnalogIn(1);
            data.error = ref - ymeas; data.ref = ref;
            % compute control signal
            data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
            if data.usignal > data.Hi
                data.usignal = data.Hi;
            elseif data.usignal < data.Lo
                data.usignal =  data.Lo;
            end
            % Send control signal xmv11 over specified channel to actuator + to EWS
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [3 4; 4 5], 'order', 11);
            ttSendMsg([2 1], msg, 160);
            % Send current error(8) to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 29);
            ttSendMsg([2 1], msg, 160);
            % Check if logging is requested.
            if data.logNext ~= 0
                teforensiclog(ttCurrentTime,data,'CONTROL_SEPAR_TEMPE', data.logNext);
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