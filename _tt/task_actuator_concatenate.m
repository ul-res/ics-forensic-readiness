function [exectime, data] = task_actuator_concatenate(segment, data)
%TASK_ACTUATOR_CONCATENATE This task is triggered when the 'actuator_inputs'
%mailbox is full. It concatenates samples in the mailbox, which correspond
%to a vector of actuator inputs, in one-d vector, and sorts according to the
%LTI approximate model of the TEP. 

switch segment
    case 1
        for i = 12:-1:1
            msg = ttTryFetch('actuator_inputs');
            data.u(i,1) = msg.data;
            data.u(i,2) = msg.order;
        end
        exectime = 1e-7;
    case 2
        data.u = sortrows(data.u,2);
        msg_concat = struct('timestamp', ttCurrentTime, 'data', data.u(:,1), 'destination', [4 3]);
        ttSendMsg(msg_concat.destination, msg_concat, 300);
        exectime = -1;
end
        