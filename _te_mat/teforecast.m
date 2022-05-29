function [output, states, susp, time_crit, exectime, violated_const] = teforecast(gsp, xInit, y0, u0, ysp, numsteps, flagperf, flagsafety, out_selected)
%TEFORECAST Forecast the state of the TE process for a certain number of
%time steps in the future. Evaluate suspicion metric as well.
% INPUTS
%       - gsp:      (GroundSuspicion object)
%       - xInit:    ((n_states+17+12+10)x1 double) initial state vector,
%       containing the initial physical state and the state of the
%       controllers.
%       - y0:       (16x1 double) operating point for system outputs.
%       - u0:       (12x1 double) operating point for system inputs.
%       - numsteps: (1x1 int) number of time steps for prediction.
%       - flagperf: (1x1 bool) flag to perform performance testing. In this
%       mode, the teforecast function is forced to evaluate the worst-case
%       execution time of the suspicion metric algorithm by predicting all
%       the states for the number of timesteps, and evaluating suspicion at
%       every state (default: 0).

% Check if flagperf is on. Default: off.
if nargin < 9
    out_selected = 1:length(y0);
end
if nargin < 8
    flagsafety = 0;
end
if nargin < 7
    flagperf = 0;
end
if flagperf
    % For performance testing, we take this performance threshold to
    % evaluate the worst-case scenario.
    susp_threshold = 1;
else
    susp_threshold = 0.001;
end

% Initialise the control structure by extracting the states from xInit.
[prevstate, datactrl] = get_initial_states(xInit);

% Initialise model, output and states.
sys = gsp.ThreatModel.System;
output      = zeros(size(sys.C, 1),numsteps + 1);
states      = zeros(size(prevstate,1), numsteps + 1);
output(:,1) = sys.C*prevstate;
states(:,1) = prevstate;
safe_check  = zeros(1,numsteps + 1);
exectime_i  = zeros(1, numsteps + 1);

% Perform safety check at current state (before predicting).
[safe_check(1),exectime_sc, violated_const] = gsp.eval(states(:,1)', 0);
exectime_i(1) = exectime_sc;
    % If the safety check is positive (i.e. unsafe), stop prediction and
    % return suspicion.
% if safe_check(1) > susp_threshold
%     susp = safe_check(1);
%     time_crit = 0;
%     exectime = exectime_i(1);
%     return;
% end

% Simulate for numsteps time steps.
% Evaluate suspicion at each step, break if a suspicious state is detected.
for i = 1:numsteps
    tic;
    [u,datactrl] = tectrl(output(out_selected,i) + y0,ysp,datactrl);
    states(:,i+1) = sys.A*states(:,i) + sys.B*(u - u0);
    exectime_pred = toc;
    output(:,i+1) = sys.C*states(:,i+1);
    if sum(abs(output(:,i+1) - output(:,i))) >= 0
        [safe_check(i+1), exectime_sc, violated_const] = gsp.eval(states(:,i+1)', 0);
    else
        safe_check(i+1) = safe_check(i);
        exectime_sc = 0;
    end
    exectime_i(i+1) = exectime_sc + exectime_pred;
    if safe_check(i+1) > susp_threshold
        if flagsafety == 0
            susp = safe_check(i+1)/(1+i);   % penalised by the number of time steps (feas x prox)
        else
            susp = safe_check(i+1);
        end
        time_crit = sys.Ts*(i+1);           % units depending on the system
        exectime = sum(exectime_i);
        return;
    end
end
susp = 0;
time_crit = -1;
exectime = sum(exectime_i);
end

function [prevstate, datactrl] = get_initial_states(xInit)
%GET_INITIAL_STATES Extract physical and control initial states from the
%vector xInit.

% Initial physical state.
n_phys              = length(xInit) - (17 + 12 + 10); % 17-> errors; 12-> init controller signals; 10->fp,Eadj,SepTempSp,r(1->7).
prevstate           = xInit(1:n_phys);

datactrl            = struct();

% Initial controller state.
datactrl.u          = xInit((n_phys+18):(n_phys+29));

% Initial Controller errors.
datactrl.error      = xInit((n_phys+1):(n_phys+17));

% Initial controller internal states.
datactrl.fp         = xInit(n_phys+32);
datactrl.Eadj       = xInit(n_phys+30);
datactrl.r1         = xInit(n_phys+33);
datactrl.r2         = xInit(n_phys+34);
datactrl.r3         = xInit(n_phys+35);
datactrl.r4         = xInit(n_phys+36);
datactrl.r5         = xInit(n_phys+37);
datactrl.r6         = xInit(n_phys+38);
datactrl.r7         = xInit(n_phys+39);
datactrl.SepTempSp  = xInit(n_phys+31);


end