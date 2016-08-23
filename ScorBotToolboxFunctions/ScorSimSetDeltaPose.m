function confirm = ScorSimSetDeltaPose(varargin)
% SCORSIMSETDELTAPOSE set the current end-effector pose of the ScorBot
% visualization relative to the current end-effector pose.
%   SCORSIMSETDELTAPOSE(scorSim,dH) moves the end-effector of the ScorBot 
%   visualization to a specified 4x4 homogeneous transformation 
%   representing the end-effector pose of ScorBot relative to the current 
%   end-effector pose.
%
%   confirm = SCORSIMSETDELTAPOSE(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also ScorSimInit ScorSimSetDeltaBSEPR ScorSimSetDeltaXYZPR 
%
%   M. Kutzer, 30Dec2015, USNA

% Updates
%   30Dec2015 - Updated to add "confirm" output

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,DeltaH);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,DeltaH);" to execute this function.'],txt,mfilename);
    end
end
% No Delta Pose
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoPose',...
        ['Change in end-effector pose must be specified.',...
        '\n\t-> Use "%s(%s,DeltaH)".'],mfilename,txt);
end
% Check Delta Pose
if nargin >= 2
    dH = varargin{2};
    if size(dH,1) ~= 4 || size(dH,2) ~= 4 || ~isSE(dH)
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadPose',...
            ['Change in end-effector pose must be specified as a valid 4x4 element of SE(3).',...
            '\n\t-> Use "%s(%s,DeltaH)".'],mfilename,txt);
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Move simulation
H = ScorSimGetPose(scorSim);
H = H*dH;
confirm = ScorSimSetPose(scorSim,H);