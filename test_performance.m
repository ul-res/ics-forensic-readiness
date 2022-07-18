% Script to automate performance testing

load('basevars_performanceTests.mat');
load_system('tesys');
addpath('_tt');

% Testing under "agnostic" logging...
disp('Running Tennessee-Eastman simulation with agnostic logging enabled...');
disp('          note: simulation may require a large amount of time to complete');

set_param('tesys/EWS/args','struct(''Gsp'', ssid_gsp, ''y0'', y0, ''u0'', u0,''numsteps'',500,''Log'',0)');
out_agnosticLogging = sim('tesys');

% Testing under "Forensic Readiness" logging..
disp('Running Tennessee-Eastman simulation with "forensic readiness" logging enabled...');
disp('          note: simulation may require a large amount of time to complete');

set_param('tesys/EWS/args','struct(''Gsp'', ssid_gsp, ''y0'', y0, ''u0'', u0,''numsteps'',500,''Log'',1)');
out_frLogging = sim('tesys');

% Testing under no logging..
disp('Running Tennessee-Eastman simulation with "forensic readiness" logging enabled...');
disp('          note: simulation may require a large amount of time to complete');

set_param('tesys/EWS/args','struct(''Gsp'', ssid_gsp, ''y0'', y0, ''u0'', u0,''numsteps'',500,''Log'',-1)');
out_noLogging = sim('tesys');

% Results..
disp(['Average controller execution time under agnostic logging: ',num2str(mean(mean(out_agnosticLogging.perf_timeDelay_ContExec)))]);
disp(['Average controller execution time under FR logging: ',num2str(mean(mean(out_frLogging.perf_timeDelay_ContExec)))]);
disp(['Average controller execution time under no logging: ',num2str(mean(mean(out_noLogging.perf_timeDelay_ContExec)))]);
