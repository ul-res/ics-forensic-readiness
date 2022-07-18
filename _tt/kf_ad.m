function [exectime, data] = kf_ad(segment, data)
%KF_AD Anomaly detector. Receives sensor measurements over the network from
%KF1Y, and output estimates from the Kalman filter over analog channel.

switch segment
    case 1
        % Get Kalman estimates
        for i = 1:16
            data.y_estim(i) = ttAnalogIn(i);
        end
        for i = 17:32
            data.y_meas(i-16) = ttAnalogIn(i);
        end
        data.diff = abs(data.y_estim - data.y_meas);
        data.Residual = data.diff'*data.CovMatrix*data.diff;
        if data.Residual >= data.Threshold, data.Alarm = 1; else, data.Alarm = 0; end
        ttAnalogOut(1,data.Residual);
        ttAnalogOut(2,data.Alarm);
        exectime = -1;
end