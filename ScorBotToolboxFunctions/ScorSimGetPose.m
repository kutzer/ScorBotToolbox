function H = ScorSimGetPose(varargin)
% SCORSIMGETPOSE get the current end-effector pose from the ScorBot
% visualization.
%   H = SCORSIMGETPOSE(scorSim) get the current end-effector pose "H"
%   from the ScorBot visualization specified by "scorSim". 
%
%   See also ScorSimInit ScorSimGetBSEPR ScorSimGetXYZPR 
%
%   M. Kutzer, 13Aug2015, USNA
%
% Updates 
%   29Sep2015 - Updated to correct correct BSEPR2Pose

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "H = %s(scorSim);" to execute this function.'],mfilename)
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
            '\n\t-> and "H = %s(scorSim);" to execute this function.'],txt,mfilename);
    end
end
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Get pose
BSEPR = ScorSimGetBSEPR(scorSim);
H = ScorBSEPR2Pose(BSEPR);