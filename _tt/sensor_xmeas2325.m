function [exectime, data] = sensor_xmeas2325(segment, data)
%SENSOR_XMEAS2325 Truetime implementation of sensor kernels for xmeas23 and
%xmeas25 for the networked Tennessee-Eastman Simulation.
%
% INPUTS
%   - analog in 1 for xmeas23
%   - analog in 2 for xmeas25
%
% OUTPUTS
%   - net message (yA) to YA_CONTROL
%   - net message (yAC) to YAC_CONTROL
%
% NOTE
%   - this kernel preprocesses sensor measurements according to the scheme
%   in the "A & C Measurement block in the original TE simulation.


switch segment
    case 1 % read
        data.xmeas23 = ttAnalogIn(1);
        data.xmeas25 = ttAnalogIn(2);
        % pre-process to obtain yA and yAC
        data.xmeas25 = data.xmeas23 + data.xmeas25; % yAC
        data.xmeas23 = data.xmeas23*100/data.xmeas25; % yA
        % send to gateway
        msg_xmeas23 = struct('timestamp', ttCurrentTime, 'data', data.xmeas23, 'destination', [2 15], 'order', 14);
        msg_xmeas25 = struct('timestamp', ttCurrentTime, 'data', data.xmeas25, 'destination', [2 16], 'order', 15);
        ttSendMsg([1 1], msg_xmeas23, 160);
        ttSendMsg([1 1], msg_xmeas25, 160);
        exectime = -1;
end
