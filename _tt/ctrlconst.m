function [exectime, data] = ctrlconst(segment, data)
%CTRLCONST Implements a constant control signal kernel. Reads xmv setpoint
%from analog channel and sends a message if a change is detected. This
%kernel is implemented for xmv5, xmv9, and xmv12.
%
% INPUTS
%   - analog in 1,2,3 for xmv5, xmv9, and xmv12 respectively
%
% OUTPUTS
%   - net messages (xmv5,9,12) to corresponding actuators
%   - net messages (xmv5,9,12) to EWS kernel
%   - net messages (setpoints) to EWS kernel 

switch segment
    case 1
        data.usignal_xmv5  = ttAnalogIn(1);
        data.usignal_xmv9  = ttAnalogIn(2);
        data.usingal_xmv12 = ttAnalogIn(3);
        % Messages meant for actuators.
        msg_xmv5  = struct('timestamp', ttCurrentTime, 'data', data.usignal_xmv5 , 'destination', [3 11; 4 5], 'order', 5 );
        msg_xmv9  = struct('timestamp', ttCurrentTime, 'data', data.usignal_xmv9 , 'destination', [3 12; 4 5], 'order', 9 );
        msg_xmv12 = struct('timestamp', ttCurrentTime, 'data', data.usignal_xmv12, 'destination', [3 13; 4 5], 'order', 12);
        ttSendMsg([2 1], msg_xmv5 , 160);
        ttSendMsg([2 1], msg_xmv9 , 160);
        ttSendMsg([2 1], msg_xmv12, 160);
        % Messages meant for the setpoint.
        msg_xmv5  = struct('timestamp', ttCurrentTime, 'data', data.usignal_xmv5 , 'destination', [4 5], 'ysp', 10 );
        msg_xmv9  = struct('timestamp', ttCurrentTime, 'data', data.usignal_xmv9 , 'destination', [4 5], 'ysp', 11 );
        msg_xmv12 = struct('timestamp', ttCurrentTime, 'data', data.usignal_xmv12, 'destination', [4 5], 'ysp', 12 );
        ttSendMsg([2 1], msg_xmv5 , 160);
        ttSendMsg([2 1], msg_xmv9 , 160);
        ttSendMsg([2 1], msg_xmv12, 160);
        exectime = -1;
end