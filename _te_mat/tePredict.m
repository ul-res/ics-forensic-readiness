function [nextState, controllerState] = tePredict(sys, currentState, currentControl, y0, u0)

[currentState,datactrl] = get_initial_states([currentState; currentControl(1:39)]);

currentOut = sys.C*currentState;
[u, datactrl] = tectrl(currentOut + y0, currentControl(40:end), datactrl);
nextState = sys.A*currentState + sys.B*(u-u0);

controllerState = zeros(39+12,1);
controllerState(1:17) = datactrl.error;
controllerState(18:(18+11)) = datactrl.u;
% controllerState(30) = datactrl.Eadj;
% controllerState(31) = datactrl.fp;
% controllerState(32) = datactrl.SepTempSp;
% controllerState(33) = datactrl.r1;
% controllerState(34) = datactrl.r2;
% controllerState(35) = datactrl.r3;
% controllerState(36) = datactrl.r4;
% controllerState(37) = datactrl.r5;
% controllerState(38) = datactrl.r6;
% controllerState(39) = datactrl.r7;
controllerState(30) = datactrl.Eadj;
controllerState(32) = datactrl.fp;
controllerState(31) = datactrl.SepTempSp;
controllerState(33) = datactrl.r1;
controllerState(34) = datactrl.r2;
controllerState(35) = datactrl.r3;
controllerState(36) = datactrl.r4;
controllerState(37) = datactrl.r5;
controllerState(38) = datactrl.r6;
controllerState(39) = datactrl.r7;
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