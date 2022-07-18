function [exectime, data] = ctrlvelpi_reactor_pressure(segment, data)
%CTRLVELPI_REACTOR_PRESSURE Kernel implementation for the reactor pressure
%controller. Standard velocity PI controller + ratio handler.
%
% INPUTS
%   - net message from sensor xmeas7
%   - analog in (1) for setpoint
%   - analog in (2) from production controller (Fp)
%
% OUTPUTS
%   - analog out for purge flowrate setpoint (r5)
%   - net message to EWS kernel with r5_0 and error(3)
%   - net message to EWS kernel with ysp(5)
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
            attack_start = 20;
            if timenow >= attack_start
                attcoef = 0.01;
                ymeas = ymeas - ymeas*attcoef*(ttCurrentTime - attack_start) - attcoef*randn(1);
            end
            % MALICIOUS CODE -- END
                        
            % End-to-end delay
            %ttAnalogOut(2, timenow - msg.timestamp);
            ref = ttAnalogIn(1);
            % Forward ysp(5) to the EWS.
            msg = struct('timestamp', ttCurrentTime, 'data', ref, 'destination', [4 5], 'ysp', 5); % r5_0
            ttSendMsg([2 1], msg, 160);
            % Handle ref.
            data.error = ref - ymeas; data.ref = ref;
            % compute control signal
            data.usignal = data.Kc*(data.error + (data.Ts/data.Ti)*data.error - data.PreviousError) + data.PreviousUsignal;
            if data.usignal > data.Hi
                data.usignal = data.Hi;
            elseif data.usignal < data.Lo
                data.usignal =  data.Lo;
            end
            % Send purge control setpoint over analog channel.
            fp = ttAnalogIn(2);
            ttAnalogOut(1, fp*data.PreviousUsignal);
            % Send current controller state r5 to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousUsignal, 'destination', [4 5], 'order', 19); % r5_0
            ttSendMsg([2 1], msg, 160);
            % Send current error to the EWS for the look-ahead initialisation.
            msg = struct('timestamp', ttCurrentTime, 'data', data.PreviousError, 'destination', [4 5], 'order', 24);
            ttSendMsg([2 1], msg, 160);
            % Check if logging is requested.
            if data.logNext ~= 0
                teforensiclog(ttCurrentTime,data,'CONTROL_REACT_PRESS', data.logNext);
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