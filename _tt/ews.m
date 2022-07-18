function [exectime, data] = ews(segment, data)
%EWS (part of the) Early warning system.

switch segment
    case 1
        % The code here will create a mailbox that stores all initial states values.
        msg = ttGetMsg();
        if ~isempty(msg)
            if isfield(msg,'ysp') % Messages meant to represent set-points.
                if data.checklist_ysp(msg.ysp) == 0 % if it's not already received, don't store it
                    data.checklist_ysp(msg.ysp) = 1; % this one is checked that it's received.
                    ttTryPost('xinit_lookahead', msg);
                % Else we queue it in another mailbox/cell array until the next available
                % mailbox.
                else
                    ttTryPost('xinit_queue1', msg);
                end
            else % same for initial states.
                if data.checklist_xinit(msg.order) == 0
                    data.checklist_xinit(msg.order) = 1;
                    ttTryPost('xinit_lookahead', msg);
                else
                    ttTryPost('xinit_queue1', msg);
                end
            end
            % xInit is ready when the checklists are complete.
            data.isInitialStateReady = sum(data.checklist_xinit) == 39 && sum(data.checklist_ysp) == 12;
        end
        if data.isInitialStateReady % mailbox full
            
            yspcount = 1;
            xinitcount = 1;
            for i = 1:(39 + 12)
                data_sample = ttTryFetch('xinit_lookahead');
                if isfield(data_sample,'ysp') % if the sample represents a setpoint, store it in data.ysp.
                    data.ysp(yspcount,1) = data_sample.data;
                    data.ysp(yspcount,2) = data_sample.ysp;
                    data.ysp(yspcount,3) = data_sample.timestamp;
                    yspcount = yspcount+1;
                else                         % if not then it's one of the initial states.
                    data.xInit(xinitcount, 1) = data_sample.data;
                    data.xInit(xinitcount, 2) = data_sample.order;
                    data.xInit(xinitcount, 3) = data_sample.timestamp;
                    xinitcount = xinitcount+1;
                end
            end
            
            % FOR TESTING
            timedelay1 = ttCurrentTime - mean(data.xInit(:,3));
            timedelay2 = ttCurrentTime - mean(data.ysp(:,3));
            
            % Refresh the checklists
            data.isInitialStateReady = 0;
            data.checklist_ysp = zeros(12,1);
            data.checklist_xinit = zeros(39,1);
            
            %Get the messages stuck in the primary queue.
            queue_msg = ttTryFetch('xinit_queue1');
            while ~isempty(queue_msg)
                if isfield(queue_msg,'ysp')
                    if data.checklist_ysp(queue_msg.ysp) == 0 % if it's not already received, store it
                        data.checklist_ysp(queue_msg.ysp) = 1; % this one is checked that it's received.
                        ttTryPost('xinit_lookahead', queue_msg);
                    else
                        ttTryPost('xinit_queue2', queue_msg); % if it's already received, move the secondary queue
                    end
                else
                    if data.checklist_xinit(queue_msg.order) == 0
                        data.checklist_xinit(queue_msg.order) = 1;
                        ttTryPost('xinit_lookahead', queue_msg);
                    else
                        ttTryPost('xinit_queue2', queue_msg);
                    end
                end
                queue_msg = ttTryFetch('xinit_queue1');
            end
            % Move the contents of the secondary queue back into the
            % primary one.
            queue2_msg = ttTryFetch('xinit_queue2');
            while ~isempty(queue2_msg)
                ttTryPost('xinit_queue1', queue2_msg);
                queue2_msg = ttTryFetch('xinit_queue2');
            end
            % Update the ready-condition.
            data.isInitialStateReady = sum(data.checklist_xinit) == 39 && sum(data.checklist_ysp) == 12;
            
            % Sort xInit and ysp.
            data.xInit = sortrows(data.xInit, 2);
            data.ysp = sortrows(data.ysp, 2);
            
            % Get physical state estimate via analog channels
            state_estim = zeros(data.nPhysicalStates,1);
            for i = 1:length(state_estim)
                state_estim(i) = ttAnalogIn(i);
            end
            % Concatenate controller and physical states.
            state_xinit = [data.xInit(:,1); state_estim];
            
            % Simulate system for k steps and evaluate suspicion metric.
            [~, ~, susp, ~, data.perf_exectime, violated_const] = teforecast(data.Gsp, state_xinit, data.y0, data.u0, data.ysp(:,1), data.numsteps);
            
            % Logging for forensics.
            % If a new suspicion metric value exceeds the threshold for a
            % warning, we perform the VoI analysis and specify which data
            % to collect.
            if data.log == 1 && susp >= 0.004
                data.violated_const = violated_const;
                data.susp = susp;
                [~, criticalCompID, percDamageArea] = tesafetymap(data.violated_const{1});
                criticalCompID = teCollectData(criticalCompID, data.susp, 1, percDamageArea);
                for i = 1:length(criticalCompID)
                    msglog = struct('forensiclog', 1, 'destination', criticalCompID{i},'logid', data.logFileId);
                    ttSendMsg([4 1], msglog, 160);
                end
            elseif data.log == 0 %log everything at all times.
                [~, criticalCompID] = tesafetymap(1:6);
                for i = 1:size(criticalCompID,1)
                    msglog = struct('forensiclog', 1, 'destination', criticalCompID{i,1},'logid', data.logFileId);
                    ttSendMsg([4 1], msglog, 160);
                end
            end
            
            % Output required values.
            ttAnalogOut(1, data.susp              );
            ttAnalogOut(2, data.time_crit         );
            ttAnalogOut(3, data.perf_exectime     ); % performance.
            for i = 1:length(state_xinit)
                ttAnalogOut(i + 3, state_xinit(i));
            end
            for i = 1:length(data.ysp(:,1))
                ttAnalogOut(i + length(state_xinit), data.ysp(i,1));
            end % Should be n_physical_states + 39 + n_ysp variables composing ews_xinit
            
        end
        exectime = -1;
end
        