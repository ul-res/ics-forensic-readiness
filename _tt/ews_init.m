function ews_init(ews_param)

ttInitKernel('prioFP');

data.Gsp = ews_param.Gsp;
data.y0 = ews_param.y0;
data.u0 = ews_param.u0;
data.nPhysicalStates = size(ews_param.Gsp.ThreatModel.System.A,1);
data.numsteps = ews_param.numsteps;
data.isInitialStateReady = 0;
data.xInit = zeros(39,3); data.checklist_xinit = zeros(39,1);
data.ysp = zeros(12,3); data.checklist_ysp = zeros(12,1);
data.susp = 0;
data.perf_exectime = 0;
data.time_crit = -1;
data.violated_const = {};
% Prepare forensic logging
data.log = ews_param.Log; % 1=> log according to our approach; 0=> log everything at all times; -1=> do not log anything
% Refresh logs and create new log file if logging is enabled
if data.log == 1 || data.log == 0
    fclose('all');
    data.logFileId = fopen(strcat('_te_mat/',strrep(strrep(string(datetime),' ','_'),':','-'), '.txt'),'w');
end
ttCreateTask('task_ews',0.1,'ews', data);
ttAttachNetworkHandler(4, 'task_ews');
ttCreateMailbox('xinit_lookahead', 39 + 12); % 17 -> errors, 12-> controller initial values; 10-> fp,Eadj,SepTempSp,r1-r7
ttCreateMailbox('xinit_queue1');
ttCreateMailbox('xinit_queue2');
