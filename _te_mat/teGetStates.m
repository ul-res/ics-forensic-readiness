function [xinit, state_phys, state_ctrl] = teGetStates(out)
%TEGETSTATES Extract initial states from the structure (xout) resulting
%from running TE's Simulink simulation.


xout = out.xout;
state_ctrl.error = zeros(17,size(xout.signals(1).values,1));
state_ctrl.u = zeros(12,size(xout.signals(1).values,1));

for i = 1:length(xout.signals)
    switch xout.signals(i).blockName
        case 'tesys_original/KALMAN_FILTER/MemoryX'
            state_phys = xout.signals(i).values;
        case 'tesys_original/CONTROL/DfeedRate/DiscretePI/u0'
            state_ctrl.u(1,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/EfeedRate/DiscretePI/u0'
            state_ctrl.u(2,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/AfeedRate/DiscretePI/u0'
            state_ctrl.u(3,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/CfeedRate/DiscretePI/u0'
            state_ctrl.u(4,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/PurgeRate/DiscretePI/u0'
            state_ctrl.u(6,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/SeparatorFlowRate/DiscretePI/u0'
            state_ctrl.u(7,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/StripperFlowRate/DiscretePI/u0'
            state_ctrl.u(8,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ReactorTemperature/u0'
            state_ctrl.u(10,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/SeparatorTemperature/u0'
            state_ctrl.u(11,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/percGinProduct/u0'
            state_ctrl.Eadj = xout.signals(i).values;
        case 'tesys_original/CONTROL/ProductionRate/u0'
            state_ctrl.fp = xout.signals(i).values;
        case 'tesys_original/CONTROL/DfeedRate/DiscretePI/VelPI/error0'
            state_ctrl.error(16,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/EfeedRate/DiscretePI/VelPI/error0'
            state_ctrl.error(17,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/percGinProduct/VelPI/error0'
            state_ctrl.error(15,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/RatioTrimming/r1_0'
            state_ctrl.r1 = xout.signals(i).values;
        case 'tesys_original/CONTROL/yAcontrol/error0'
            state_ctrl.error(11,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/AfeedRate/DiscretePI/VelPI/error0'
            state_ctrl.error(13,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/yACcontrol/error0'
            state_ctrl.error(12,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/RatioTrimming/r4_0'
            state_ctrl.r4 = xout.signals(i).values;
        case 'tesys_original/CONTROL/CfeedRate/DiscretePI/VelPI/error0'
            state_ctrl.error(14,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ReactorPressure/u0'
            state_ctrl.r5 = xout.signals(i).values;
        case 'tesys_original/CONTROL/PurgeRate/DiscretePI/VelPI/error0'
            state_ctrl.error(4,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ReactorPressure/VelPI/error0'
            state_ctrl.error(3,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/SeparatorLevel/u0'
            state_ctrl.r6 = xout.signals(i).values;
        case 'tesys_original/CONTROL/SeparatorFlowRate/DiscretePI/VelPI/error0'
            state_ctrl.error(6,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/SeparatorLevel/VelPI/error0'
            state_ctrl.error(5,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/StripperLevel/u0'
            state_ctrl.r7 = xout.signals(i).values;
        case 'tesys_original/CONTROL/StripperFlowRate/DiscretePI/VelPI/error0'
            state_ctrl.error(6,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/StripperLevel/VelPI/error0'
            state_ctrl.error(9,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ReactorTemperature/VelPI/error0'
            state_ctrl.error(1,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ReactorLevel/VelPI/error0'
            state_ctrl.error(7,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ReactorLevel/u0'
            state_ctrl.SepTempSp = xout.signals(i).values;
        case 'tesys_original/CONTROL/SeparatorTemperature/VelPI/error0'
            state_ctrl.error(8,:) = xout.signals(i).values;
        case 'tesys_original/CONTROL/ProductionRate/VelPI/error0'
            state_ctrl.error(2,:) = xout.signals(i).values;
    end
end
% Constant values
state_ctrl.u(5,:) = 22.21*ones(1,size(xout.signals(1).values,1));
state_ctrl.u(9,:) = 47.446*ones(1,size(xout.signals(1).values,1));
state_ctrl.u(12,:) = 50*ones(1,size(xout.signals(1).values,1));
state_ctrl.r2 = 36.64*ones(size(xout.signals(1).values,1),1);
state_ctrl.r3 = 45.09*ones(size(xout.signals(1).values,1),1);

% Group them up
ysp = out.ysp(1:size(state_phys,1),:)';
xinit = zeros(size(state_phys,2) + 17 + 12 + 10 + size(ysp,1),size(state_phys,1));
    % Physical state
xinit(1:size(state_phys,2),:) = state_phys';
    % control errors
xinit((size(state_phys,2)+1):(size(state_phys,2)+17),:) = state_ctrl.error;
    % control init states
xinit((size(state_phys,2)+18):(size(state_phys,2)+18+11),:) = state_ctrl.u;
    % other
xinit((size(state_phys,2)+18+11+1),:) = state_ctrl.Eadj';
xinit((size(state_phys,2)+18+11+2),:) = state_ctrl.fp';
xinit((size(state_phys,2)+18+11+3),:) = state_ctrl.SepTempSp';
xinit((size(state_phys,2)+18+11+4),:) = state_ctrl.r1';
xinit((size(state_phys,2)+18+11+5),:) = state_ctrl.r2';
xinit((size(state_phys,2)+18+11+6),:) = state_ctrl.r3';
xinit((size(state_phys,2)+18+11+7),:) = state_ctrl.r4';
xinit((size(state_phys,2)+18+11+8),:) = state_ctrl.r5';
xinit((size(state_phys,2)+18+11+9),:) = state_ctrl.r6';
xinit((size(state_phys,2)+18+11+10),:) = state_ctrl.r7';
xinit((size(state_phys,2)+18+11+11):end,:) = ysp;
            
            
            
            
            
            
            
            
            
            
            
