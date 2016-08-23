function ScorSimQuitTeachCallback(src,callbackdata)
% SCORSIMQUITTEACHCALLBACK callback function to disable teach mode of the
% ScorBot Simulation.
%
%   NOTE: This function is not intended for general use.
%
%   M. Kutzer, 16Oct2015, USNA

% Updates
%   23Oct2015 - Updates to status indicator.

%% Declare globals
global scorSimGlobalVariable scorSimTeachBSEPR scorSimTeachXYZPR

%% Update simulation status
if ~isempty(scorSimGlobalVariable.Figure)
    if ishandle(scorSimGlobalVariable.TeachFlag)
        set(scorSimGlobalVariable.TeachFlag,'FaceColor','w');
        set(scorSimGlobalVariable.TeachText,'String','Inactive.');
        set([scorSimGlobalVariable.TeachFlag,scorSimGlobalVariable.TeachText],'Visible','off');
    else
        scorSimGlobalVariable.Figure = [];
    end
end
                    
%% Update teach mode
tag_src = get(src,'Tag');
tag_XYZPR = 'ScorSim XYZPR Teach, Do Not Change';
tag_BSEPR = 'ScorSim BSEPR Teach, Do Not Change';

%% Update global variable
switch tag_src
    case tag_XYZPR
        scorSimTeachXYZPR = false;
    case tag_BSEPR
        scorSimTeachBSEPR = false;
    otherwise
        warning('Unexpected figure tag.');
end

%% Delete figure
delete(src);
