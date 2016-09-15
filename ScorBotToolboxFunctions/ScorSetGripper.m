function confirm = ScorSetGripper(grip)
% SCORSETGRIPPER sets the gripper state in millimeters above fully closed.
%   SCORSETGRIPPER(grip) sets the gripper state in millimeters. State is
%   measured as the distance between the gripper fingers. A fully closed 
%   gripper has a "grip" of 0 mm. A fully open gripper has a "grip" of 
%   70 mm.
%       grip - scalar gripper state in millimeters
%
%   Binary (Open/Close) Commands:
%       SCORSETGRIPPER('Open') fully opens the gripper
%       SCORSETGRIPPER('Close') fully closes the gripper
%
%   confirm = SCORSETGRIPPER(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorGetGripper
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorSetGripper.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 12Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated to maintain speed even after changing the gripper 
%               state using the ScorGetSpeed/ScorGetMoveTime functionality
%   15Sep2016 - Updated to correct error text "closed" to "close"
%               Christian Jaunich
%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check inputs
narginchk(1,1);

%% Confirm that ScorBot is in Auto
isAuto = ScorSetPendantMode('Auto');
if ~isAuto
    confirm = false;
    return
end

%% Set gripper state
if ischar(grip) % Binary Open/Close
    switch lower(grip)
        case 'open'
            isOpen = calllib(libname,'RGripOpen');
            if isOpen
                confirm = true;
            else
                confirm = false;
                if nargout == 0
                    warning('Failed to set the gripper to open.');
                end
            end
        case 'close'
            isClose = calllib(libname,'RGripClose');
            if isClose
                confirm = true;
            else
                confirm = false;
                if nargout == 0
                    warning('Failed to set the gripper to closed.');
                end
            end
        otherwise
            error('Binary gripper commands must be either "Open" or "Close"');
    end
else % Metric grip state
    if grip > 70 || grip < 0
        error('Gripper value must be between 0 and 70 millimeters.');
    end
    grip = round(grip);
    isGrip = calllib(libname,'RGripMetric',grip);
    if isGrip
        confirm = true;
    else
        confirm = false;
        if nargout == 0
            warning('Failed to set the gripper to %d mm.',grip);
        end
    end
end

%% Reset speed or move time 
spd = ScorGetSpeed;
mTime = ScorGetMoveTime;
if ~isempty(spd)
    ScorSetSpeed(spd);
elseif ~isempty(mTime)
    ScorSetMoveTime(mTime);
else
    error('Unexpected ScorGetSpeed/ScorGetMoveTime state.');
end