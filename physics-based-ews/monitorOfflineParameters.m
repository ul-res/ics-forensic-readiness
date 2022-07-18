function [safetyMonitorParameters] = monitorOfflineParameters(sys, kalGain, chisqSigma, processNoiseBound, chisqThreshold, unsafeSet)
%OFFLINE_INIT 

safetyMonitorParameters.sys    = sys;
dimSys                  = size(sys.A,1);
b                       = 0.01;%:0.01:0.99;
logdets                 = zeros(2,length(b));
Pcurrent                = cell(1,length(b));
P                       = sdpvar(dimSys,dimSys);
omegaBar                = chisqThreshold + processNoiseBound;
numSensors              = size(sys.C,1);
options = sdpsettings('solver','sdpt3','verbose', 1, 'debug',1,'sdpt3.maxit', 1000, 'showprogress', 1, 'convertconvexquad', 0);
% Other solvers. Uncomment to test other solvers.
%options = sdpsettings('solver','logdetppa','debug',1,'verbose', 1);
%   options = sdpsettings('solver','fmincon','debug',1, 'verbose', 1);
for i = 1:length(b)
    Constraints = [P >= 0,...
        [b(i)*P,                      sys.A'*P,                    zeros(dimSys,dimSys+numSensors);...
        P*sys.A,                  P,                              P,                                                  -P*kalGain*sqrtm(chisqSigma);...
        zeros(dimSys),               P,                              ((1-b(i))/omegaBar)*eye(dimSys),                    zeros(dimSys,numSensors);...
        zeros(numSensors,dimSys),    -sqrtm(chisqSigma)*kalGain'*P,  zeros(numSensors,dimSys),                           ((1-b(i))/omegaBar)*eye(numSensors)] >=0];% zeros(3*dimSys + numSensors)];
    Objective = -logdet(P);
    sol = optimize(Constraints, Objective, options);
    if sol.problem == 0 || 4
        Pcurrent{i} = value(P);
        logdets(1,i) = -logdet(value(P));
        if sol.problem == 4
            logdets(2,i) = 1;
        end
        %                     if min(eig(value(P))) < -1e4
        %                         logdets(1,i) = Inf;
        %                     elseif min(eig(value(P))) < 0
        %                         Pcurrent{i} = nearestSPD(Pcurrent{i});
        %                     end
    end
end
% Get the optimal solution from the grid search.
[~,optSol] = min(logdets(1,:));
% The reachable ellipsoid computed using the previous procedure
% actually has P^(-1) as the shape matrix as the reachable set
% is defined as: {e \in \R^n | e'*P*e <= 1}. To ensure
% consistency, this matrix is inverted before being passed as
% an argument to the Ellipsoid library.
Pcurrent{optSol} = inv(Pcurrent{optSol});
if min(eig(Pcurrent{optSol})) < 0
    Pcurrent{optSol} = nearestSPD(Pcurrent{optSol});
end
safetyMonitorParameters.ReachMatrix = Pcurrent{optSol};
safetyMonitorParameters.NoiseLimProcess = processNoiseBound;
safetyMonitorParameters.AnomalyDetector = struct('KalmanGain',kalGain,'ChiSquaredCov',chisqSigma,'DetectionThreshold',chisqThreshold);
if logdets(2,optSol) == 1
    warning('Numerical problems faced.');
    safetyMonitorParameters.Info.Warnings = {'4','Numerical problems faced.'};
else
    safetyMonitorParameters.Info.Warnings = {};
end
safetyMonitorParameters.Info.GridSearch = logdets;
safetyMonitorParameters.Info.GridSearchMat = Pcurrent;
% MATSCALE is a scaling factor added to avoid numerical
% problems in high dimensional situations.
safetyMonitorParameters.MATSCALE = 1;
% VMAX is the volume of the reachable ellipsoid
safetyMonitorParameters.VMAX     = volume(Ellipsoid(zeros(dimSys,1),safetyMonitorParameters.MATSCALE*safetyMonitorParameters.ReachMatrix));
% VSHRINK is a factor used in the computation of the ratio of
% the volume of the reachable ellipsoid to that of its
% intersection with a halfspace as proven in [2] (see Lemma 2).
safetyMonitorParameters.VSHRINK  = (dimSys^dimSys)/((1+dimSys)*(dimSys^2-1)^((dimSys-1)/2));
% Unsafe set
safetyMonitorParameters.UnsafeSet = unsafeSet;
% UnsafeSetParams pre-computes certain parameters that
% are used to approximate andcheck emptiness of ellipsoid
% intersections (see [2], Lemma 1, formula for \alpha).
safetyMonitorParameters.UnsafeSetParams = zeros(1,length(unsafeSet));
for i = 1:length(unsafeSet)
    safetyMonitorParameters.UnsafeSetParams(i) = sqrt(safetyMonitorParameters.UnsafeSet{i}.Normal'*safetyMonitorParameters.ReachMatrix*safetyMonitorParameters.UnsafeSet{i}.Normal);
end

end

