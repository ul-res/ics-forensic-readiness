function [exectime, data] = task_sensor_concatenate(segment, data)
%TASK_SENSOR_CONCATENATE This task is triggered when the 'sensor_outputs'
%mailbox is full. It concatenates samples in the mailbox, which correspond
%to a vector of sensor outputs, in one-d vector, and sorts according to the
%LTI approximate model of the TEP. 

switch segment
    case 1
        for i = 2:-1:1
            msg = ttTryFetch('sensor_outputs');
            data.y(i,1) = msg.data;
            data.y(i,2) = msg.order;
            data.y(i,3) = msg.timestamp;
        end
        exectime = 1e-7;
    case 2
        data.y = sortrows(data.y,2);
        msg_concat = struct('timestamp', ttCurrentTime, 'data', data.y(:,1), 'destination', [4 2; 4 4]);
        ttSendMsg(msg_concat.destination(1,:), msg_concat, 300);
        ttSendMsg(msg_concat.destination(2,:), msg_concat, 300);
        ttNotify('sensor_vals_ready');
        exectime = -1;
end
        