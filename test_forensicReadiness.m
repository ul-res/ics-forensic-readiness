%% ADD RELEVANT FOLDERS TO PATH

addpath('physics-based-ews','_te_clib', '_te_mat', '_te_mat_attacker','lib\SDPT3-4.0','lib\truetime-2.0','lib\ellipsoid','lib\YALMIP-master');
run('lib\truetime-2.0\init_truetime.m');
run('lib\SDPT3-4.0\Installmex.m');
run('lib\SDPT3-4.0\startup.m');

clc;

%% LOAD BASE VARIABLES
load('basevars.mat');


%% FORENSIC READINESS TESTS
%For an attack that causes damage before it gets
%detected by the anomaly detector, we check whether data was collected in
%the timecrit steps before damage happened. We particularly check whether
%data was collected in the right part of the system. The general steps
%undertaken for this evaluation are as follows:
%       - Choose a random (set of) sensor(s) and construct a random attack
%       satisfying the threat model;
%       - run the simulation (and the monitoring algorithm)
%       - check what constraints were predicted to be violated by the
%       monitoring algorithm
%       - if a constraint that was actually violated was not included in
%       the predictions, then it is a miss (i.e. the simulation was a MISS,
%       monitoring algorithm missed RELEVANT data.)

% % Number of tests to perform.
 num_tests = 1;
% % A vector to store test results.
 test_results = zeros(3,num_tests); %First row: 1 => general warning happened; 0 otherwise /Second row: 1 => no relevant data is missed; 0 at least one relevant data is/Third row: 1 => attack detected; 0 otherwise
% Sensors set for testing (safety-critical).
% Reactor pressure, reactor level, reactor temperature (removed), separator temperature, separator level, stripper level.
test_sensors = [5 6 7 9 10 12];
% Keep track of "accurate" simulations
results_numMisses = 0;
% For minimality, we want to compare the number of "data entries" held by
% our FR specification to the case where everything is preserved.
test_numEvents = zeros(1,num_tests);

load_system('tesys_original');
% Run simulations
for i = 1:num_tests
    % Choose a random number of sensors to attack at the same time.
    test_numAttackedSensors = randi(length(test_sensors));
    disp(['Test ', num2str(i),' out of ', num2str(num_tests),'... ', num2str(test_numAttackedSensors),' sensor(s) attacked...']);
    % Set up the attacker kernel according to the number of attacked sensors.
    set_param('tesys_original/ATTACKER','ninputsoutputs',['[',num2str(test_numAttackedSensors),' 16]']);
    % Select sensors to be attacked.
    test_sensorsAttacked = sort(test_sensors(randperm(length(test_sensors),test_numAttackedSensors)));
    set_param('tesys_original/Attacked_Sensors','Indices',['[',num2str(test_sensorsAttacked),']']);
    set_param('tesys_original/ATTACKER','args',['struct(''FalseAlarmRate'',0.1,''Start'',20,''AttackedSensors'',[',num2str(test_sensorsAttacked),'],''AttackCoef'',', num2str(0.01*rand()),')']);
    
    % Vary operating conditions.
    % Randomize the operating conditions by changing switches in the
    % variables' set-points.
    test_manualswitches = 0;
    for k = 1:4
        test_manualswitches = ~(rand() < 0.5);
        set_param(['tesys_original/ms',num2str(k)], 'sw', num2str(test_manualswitches));
    end
    % Simulate system
    out = sim('tesys_original');
    % Prepare and run monitoring algorithm
    for k = 1:length(out.xout.signals)
        out.xout.signals(k).values = out.xout.signals(k).values(rem(out.tout,0.01) == 0,:);
    end
    xinit = teGetStates(out);
    test_safecheck = 0;
    out.tout = out.tout((rem(out.tout,0.01)==0),:);
    
    % We are only interested in safety checks performed within K steps
    % of damage taking place.
    test_safecheck_start = find(out.tout >= out.tout(end) - 500*0.01,1);
    
    for j = test_safecheck_start:size(xinit,2)
        %[~,~,test_safecheck, ~, ~, violated_const] = teforecast(ssid_gsp, xinit(:,j), y0, u0, out.ysp(j,:)', 500, 0, 1, y0_selectedinv);
        [test_safecheck, ~, violatedConstraints] = monitorOnline(safetyMonitorParameters,xinit(1:84,j),xinit(85:end,j),100,@(x,y)tePredict(ssid_est,x,y,y0,u0));
        if test_safecheck > 0.004
            test_results(1,i) = 1;
            test_numEvents(i) = length((violated_const{1}));
            break;
        end
    end
    % Did damage happen?
    for n = 1:length(test_sensors)
        test_results(2,i) = 1;
        if ~isempty(find(out.output_real(:,test_sensors(n)) >= -ssid_unsafe{tesafetySensorMap(test_sensors(n))}.Scalar + y0(test_sensors(n)),1)) && sum(violated_const{1} == tesafetySensorMap(test_sensors(n))) <=0
            % i.e. damage in given area happened and appropriate violated
            % constraints NOT included => relevant data missed.
            test_results(2,i) = 0;
            break;
        end
    end
    if ~test_results(1,i), test_results(2,i) = 0; end
    
    % Did anomaly detector go off after the attack and before the damage
    % happened?
    % Attack is detected <- number of alarms before attack < number of alarms after attack starts 
    test_results(3,i) = sum(out.alarms(out.attack(:,test_sensorsAttacked(1)) ~= 0)) > sum(out.alarms(out.attack(:,test_sensorsAttacked(1)) == 0));
    if (~test_results(2,i) && ~test_results(3,i))% data is missed and attack is not detected before damage => simulation is a "miss"
        results_numMisses = results_numMisses + 1;
    end
%     save('sim_experiments_tests/2022.01.19.Tests_ForensicReadiness.mat');
end

results_avgLogSizeReduction = 100*(1 - mean(test_numEvents)/8);
clc;
disp('Results...');
disp(['Percentage of ''missed'' data:   ', num2str(results_numMisses)]);
disp(['Average Log Size Reduction:    ', num2str(results_avgLogSizeReduction)]);

clear i j k n;



