function confirm = ScorSimSetPose(varargin)
% SCORSIMSETPOSE set the current end-effector pose of the ScorBot
% visualization.
%   SCORSIMSETPOSE(scorSim,H) moves the end-effector of the ScorBot 
%   visualization to a specified 4x4 homogeneous transformation 
%   representing the end-effector pose of ScorBot relative to the base
%   frame.
%
%   confirm = SCORSIMSETPOSE(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorSimInit ScorSimSetBSEPR ScorSimSetXYZPR 
%
%   M. Kutzer, 14Aug2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated help documentation
%   30Dec2015 - Updated to add "confirm" output

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,H);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,H);" to execute this function.'],txt,mfilename);
    end
end
% No Pose
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoPose',...
        ['End-effector pose must be specified.',...
        '\n\t-> Use "%s(%s,H)".'],mfilename,txt);
end
% Check Pose
if nargin >= 2
    H = varargin{2};
    if size(H,1) ~= 4 || size(H,2) ~= 4 || ~isSE(H)
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadPose',...
            ['End-effector pose must be specified as a valid 4x4 element of SE(3).',...
            '\n\t-> Use "%s(%s,H)".'],mfilename,txt);
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Move simulation
BSEPR = ScorPose2BSEPR(H);
if ~isempty(BSEPR)
    confirm = ScorSimSetBSEPR(scorSim,BSEPR);
else
    warning('Specified pose may be unreachable.');
    confirm = false;
end