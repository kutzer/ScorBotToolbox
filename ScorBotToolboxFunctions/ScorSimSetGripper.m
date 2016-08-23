function confirm = ScorSimSetGripper(varargin)
% SCORSIMSETGRIPPER set the ScorBot visualization gripper state in 
% millimeters above fully closed.
%   SCORSIMSETGRIPPER(scorSim,grip) set the ScorBot visualization gripper 
%   state in millimeters. State is measured as the distance between the 
%   gripper fingers. A fully closed gripper has a "grip" of 0 mm. A fully 
%   open gripper has a "grip" of 70 mm.
%       grip - scalar gripper state in millimeters
%
%   Binary (Open/Close) Commands:
%       SCORSIMSETGRIPPER(scorSim,'Open') fully opens the gripper
%       SCORSIMSETGRIPPER(scorSim,'Close') fully closes the gripper
%
%   confirm = SCORSIMSETGRIPPER(___) returns 1 if successful and 0 otherwise.
%
%   Note: Actual hardware resolution is rounded to millimeters. Fractions
%       of millimeter grip precision is possible in the simulation only.
%       Rounding is not included to enable smooth animations for 
%       interpolated grip data.
%
%   See also ScorSimInit ScorSimGetGripper
%
%   M. Kutzer, 30Sep2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated to add "confirm" output

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,grip);" to execute this function.'],mfilename)
end
% Check scorSim
if nargin >= 1
    scorSim = varargin{1};
    if ~isScorSim(scorSim)
        if isempty(inputname(1))
            txt = 'The specified input';
        else
            txt = sprintf('"%s"',inputname(1));
        end
        error('ScorSet:BadSimObj',...
            ['%s is not a valid ScorSim object.',...
            '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
            '\n\t-> and "%s(scorSim,grip);" to execute this function.'],txt,mfilename);
    end
end
% No Grip
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoGrip',...
        ['Gripper state must be specified.',...
        '\n\t-> Use "%s(%s,grip);" to open the gripper to the value contained in "grip",'...
        '\n\t-> Use "%s(%s,''Open'');" to fully open the gripper, or'...
        '\n\t-> Use "%s(%s,''Close'');" to fully close the gripper.'],...
        mfilename,txt,mfilename,txt,mfilename,txt);
else
    grip = varargin{2};
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Parse inputs
if ischar(grip)
    switch lower(grip)
        case 'open'
            grip = 70;
        case 'close'
            grip = 0;
        otherwise
            if isempty(inputname(1))
                txt = 'scorSim';
            else
                txt = inputname(1);
            end
            error('ScorSimSet:BadGripState',...
                ['Gripper state must be set to a single value, to ''Open'', or to ''Close''.',...
                '\n\t-> Use "%s(%s,grip);" to open the gripper to the value contained in "grip",'...
                '\n\t-> Use "%s(%s,''Open'');" to fully open the gripper, or'...
                '\n\t-> Use "%s(%s,''Close'');" to fully close the gripper.'],...
                mfilename,txt,mfilename,txt,mfilename,txt);
    end
end

%% Check grip
if grip > 70 || grip < 0
    %confirm = false;
    error('ScorSimSet:BadGripVal',...
         'Gripper value must be between 0 and 70 millimeters.');
end
%grip = round(grip); % round off to match ScorBot hardware functionality

%% Move simulation
g0 = 34.00+21.6-0.028; % this value must match in get and set command
o = (grip - g0)/2;
h = 47.22; % this value must match in get and set command

ang = -asin(o/h);

%% Right fingers
for i = 1:2
    set(scorSim.Finger(i),'Matrix',Rx(ang));
end

%% Right fingertip
set(scorSim.FingerTip(1),'Matrix',Rx(-ang));

%% Left fingers
for i = 3:4
    set(scorSim.Finger(i),'Matrix',Rx(-ang));
end

%% Right fingertip
set(scorSim.FingerTip(2),'Matrix',Rx(ang));

%% Update plot
confirm = true;
drawnow