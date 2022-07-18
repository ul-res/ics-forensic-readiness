function [exectime, data] = gateway(segment, data)
%GATEWAY kernel code for gateway. It is assumed that exchanged messages
%contain the following fields:
%   - timestamp     <double>  Message time stamp
%   - data          <void>    Message contents, typically of type double
%   - destination   <kx2 int> Destination address, specified as a kx2
%                             matrix: [network_id1, node_id1; network_id2, 
%                             node_id2...] with k being the number of 
%                             destinations.
%   For sensor and actuator signals included for estimation and anomaly 
%   detection, an additional field is required:
%   - order         <int>     The position of the signal in the
%                             output/input vector (y & u) so that
%                             estimation and anomaly detection is done
%                             correctly.
%   Sensor outputs required for estimation will be forwarded, in addition
%   to their intended destination in the field 'destination', to the
%   Kalman filter/anomaly detection node, specifically node id [4 2]
%   (kf_1y). The same applies for actuator signals which will be forwarded
%   to node [4 3].

switch segment
  case 1
    for nw = data.NetworkList  % read messages from the network list
      msg = ttGetMsg(nw);
      if ~isempty(msg)
%         %MALICIOUS CODE ---- START
%         attack_start = 30;
%         if nw == 1 && msg.order == 6 && ttCurrentTime >= attack_start
%             msg.data = msg.data - msg.data*0.01*(ttCurrentTime - attack_start) + rand();
%         end
%         %MALICIOUS CODE ---- END
        
        % Forward message to the destination
        for i = 1:size(msg.destination, 1)
            ttSendMsg(msg.destination(i,:), msg, 160);
        end
        % SPECIAL MESSAGES ARE FORWARDED TO KALMAN FILTER AND/OR ANOMALY DETECTOR AND/OR EWS.
        if nw == 1 && isfield(msg,'order')
            
            % If the message is a sensor output required for estimation, forward to the Kalman filter receiver.
            ttSendMsg([4  2], msg, 160);
        end
        if nw == 2 && isfield(msg, 'order') && msg.order <= 12 % make sure it's one of the xmv's.
            ttSendMsg([4  3], msg, 160); % if the message is an actuator input required for estimation, forward to the Kalman filter receiver.
        end
      end
     end
    exectime = 1e-7 + 1e-7*rand();
   case 2  
    exectime = -1;
end