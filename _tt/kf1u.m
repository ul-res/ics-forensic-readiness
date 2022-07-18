function [exectime, data] = kf1u(segment, data)
%KF1Y Receives control inputs, concatenates them, prepares them for Kalman
%filtering by reordering them in a vector 'u', and forwards them to the
%Kalman filter via analog channels.
%
%   Control inputs are received from the gateway over the network. They are
%   queued in the mailbox 'actuator_inputs'. When the mailbox is full,
%   control inputs are sorted and forwarded to the Kalman filter over
%   analog channels. Sensor outputs are also forwarded to the anomaly
%   detector over the network.

switch segment
    case 1
        msg = ttGetMsg(4);
        if ~isempty(msg)
            data.areAllCtrlSignalsReceived = ~ttTryPost('actuator_inputs', msg);
        end
        if isempty(msg) || ~data.areAllCtrlSignalsReceived
            for i = 1:12
                ttAnalogOut(data.u(i,2), data.u(i,1) - data.u0(data.u(i,2)));
            end
        end
        if data.areAllCtrlSignalsReceived
            for i = 1:12
                u_sample = ttTryFetch('actuator_inputs');
                data.u(i,1) = u_sample.data;
                data.u(i,2) = u_sample.order;
                data.u(i,3) = u_sample.timestamp;
            end
            data.u = sortrows(data.u, 2);
            for i = 1:12
                ttAnalogOut(i, data.u(i,1) - data.u0(i));
            end
            data.areAllCtrlSignalsReceived = ~ttTryPost('actuator_inputs', msg);
        end
        exectime = -1;
end
