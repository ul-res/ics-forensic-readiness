function teforensiclog(timestamp, ctrlData, ctrlName, forensicLogID)
%TEFORENSICLOG Log controller events.

fprintf(forensicLogID,'%12.5f | %20s | %20.5f | %20.5f \n',timestamp*3600,ctrlName, ctrlData.Kc, ctrlData.PreviousUsignal);
