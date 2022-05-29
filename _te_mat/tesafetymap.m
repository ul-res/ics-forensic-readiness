function [criticalComponentName, criticalComponentId] = tesafetymap(violated_const)
%TESAFETYMAP Returns strings and Truetime Id's denoting TEP components that
%are affected by the violated safety constraints.

criticalComponentName = {};
criticalComponentId = {};

% REACTOR AREA
if ~isempty(find(violated_const == 1, 1)) || ~isempty(find(violated_const == 2, 1)) || ~isempty(find(violated_const == 3,1))
    criticalComponentName = [criticalComponentName; {'REACTOR_CONTROL_PRESSURE'; 'REACTOR_CONTROL_LEVEL';'REACTOR_CONTROL_TEMPERATURE'}];
    criticalComponentId = [criticalComponentId; {[2 3]; [2 6]; [2 2]}];
end

% SEPARATOR AREA
if ~isempty(find(violated_const == 4, 1)) || ~isempty(find(violated_const == 5,1))
    criticalComponentName = [criticalComponentName; {'SEPARATOR_CONTROL_TEMPERATURE'; 'SEPARATOR_CONTROL_LEVEL';'SEPARATOR_CONTROL_FR'}];
    criticalComponentId = [criticalComponentId; {[2 7]; [2 8]; [2 9]}];
end

% STRIPPER AREA
if ~isempty(find(violated_const == 6, 1))
    criticalComponentName = [criticalComponentName; {'STRIPPER_CONTROL_LEVEL'; 'STRIPPER_CONTROL_FLOWRATE' }];
    criticalComponentId = [criticalComponentId; {[2 10]; [2 11]}];
end

end

