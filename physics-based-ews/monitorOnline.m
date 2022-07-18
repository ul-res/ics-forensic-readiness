function [suspmetric,time_crit, violatedConstraints, exectime] = monitorOnline(monitorParameters,statePhysical,stateController,horizonLength, predictionFunction)


% Initialise required variables.
vshrink         = monitorParameters.VSHRINK;
reach_matrix    = monitorParameters.ReachMatrix;
suspmetric      = zeros(1, size(statePhysical,2));
exectime        = suspmetric;
time_crit       = suspmetric;

if nargout > 2
    violatedConstraints = cell(1, size(statePhysical,2));
end

for i = 1:size(statePhysical,2)
    currentState = statePhysical(:,i);
    currentControlState = stateController(:,i);
    % Start the stopwatch for performance measurement.
    tic;
    for j = 1:horizonLength
        % Does the reach ellipsoid actually intersect the unsafe set?
        alpha = zeros(1,length(monitorParameters.UnsafeSet));
        for k = 1:length(monitorParameters.UnsafeSet)
            alpha(k) = (monitorParameters.UnsafeSet{k}.Normal'*currentState - monitorParameters.UnsafeSet{k}.Scalar)/monitorParameters.UnsafeSetParams(k);
        end
        alphamin = min(abs(alpha));
        if alphamin < 1 % => intersection is non-empty
            % What constraints were violated?
            violatedConstraints{i} = find(abs(alpha) < 1);
            alpha_ = alpha(abs(alpha) < 1);
            for k = 1:length(alpha_)
                alpha_(k) =  vshrink.*(1 - alpha_(k)).*(1 - alpha_(k).^2).^((size(reach_matrix,1) - 1)/2);
            end
            suspmetric(i) = max(alpha_);
            time_crit(i) = (j-1)*monitorParameters.sys.Ts;
            %exectime(i) = toc;
            break;
        else
            [currentState,currentControlState] = predictionFunction(currentState, currentControlState);
        end
    end
    if j == horizonLength
        suspmetric(i) = 0;
        time_crit(i) = -1;
        violatedConstraints{i} = [];
    end
    exectime(i) = toc;
end
end