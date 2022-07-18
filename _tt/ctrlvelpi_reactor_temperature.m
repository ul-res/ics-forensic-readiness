function [exectime, data] = ctrlvelpi_reactor_temperature(segment, data)
%CTRLVELPI_REACTOR_TEMPERATURE Kernel implementation of the reactor
%temperature controller. Standard velocity PI controller.
%
% INPUTS
%   - net message from sensor xmeas9
%   - analog in for setpoint
%
% OUTPUTS
%   - net message with xmv10 to actuator + to EWS.
%   - net message with ysp(9) to EWS
%   - net message with error(1) to EWS
%   - (performance) end-to-end delay



switch segment
    case 1
        msg = ttGetMsg();
        if isempty(msg)
            ymeas = data.PreviousYmeas;
        elseif isfield(msg,'data') % if message received is a sensor message, compute next controller input.
            ymeas = msg.data;
            data.PreviousYmeas = ymeas;
            timenow = ttCurrentTime();
            tic;
            % MALICIOUS CODE -- START
%             attack_start = 0.005;
%             if timenow >= attack_start
%                 ymeas = ymeas - ymeas*0.01*(ttCurrentTime - attack_start) + rand();
%             end
            % MALICIOUS CODE -- END
            
            % End-to-end delay
            %ttAnalogOut(1, timenow - msg.timestamp);
            ref = ttAnalogIn(1); data.ref= ref;
            % Forward ysp(9) to EWS
            msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 9); % r5_0
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
            % Send control signal over specified channel.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [3 2; 4 5], 'order', 10);
            ttSendMsg([2 1], msg, 160);
            % Send current error to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 22);
            ttSendMsg([2 1], msg, 160);
            % Check if logging is requested.
            if data.logNext ~= 0
                teforensiclog(ttCurrentTime,data,'CONTROL_REACT_TEMPE', data.logNext);
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
