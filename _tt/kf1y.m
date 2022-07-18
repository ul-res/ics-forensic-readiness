function [exectime, data] = kf1y(segment, data)
%KF1Y Receives sensor outputs, concatenates them, prepares them for Kalman
%filtering by reordering them in an output vector 'y', and forwards them to
%the Kalman filter via analog channels.
%
%   Sensor outputs are received from the gateway over the network. They are
%   queued in the mailbox 'sensor_outputs'. When the mailbox is full,
%   sensor outputs are sorted and forwarded to the Kalman filter over
%   analog channels. Sensor outputs are also forwarded to the anomaly
%   detector over the same analog channel.

switch segment
    case 1
        msg = ttGetMsg(4);
        if ~isempty(msg)
            data.areAllMeasReceived = ~ttTryPost('sensor_outputs', msg);
        end
        if isempty(msg) || ~data.areAllMeasReceived % if no message is received, send previous outputs
            for i = 1:16
                ttAnalogOut(data.y(i,2), data.y(i,1) - data.y0(data.y(i,2)));
            end
        end
        if data.areAllMeasReceived % if mailbox is full, it means sensor outputs are ready for estimation/anomaly detection.
            for i = 1:16
                meas_sample = ttTryFetch('sensor_outputs');
                data.y(i,1) = meas_sample.data;
                data.y(i,2) = meas_sample.order;
                data.y(i,3) = meas_sample.timestamp;
                ttAnalogOut(meas_sample.order, meas_sample.data - data.y0(meas_sample.order));
            end
            %ttSendMsg([4 4], data.y(:,1:2), 160); % also forward the received sensor measurements to the anomaly detector. Note: timestamps are disregarded. Sorting is performed by the anomaly detector kernel.
            data.areAllMeasReceived = ~ttTryPost('sensor_outputs', msg); % try to post the message again.
        end
        exectime = -1;
end
