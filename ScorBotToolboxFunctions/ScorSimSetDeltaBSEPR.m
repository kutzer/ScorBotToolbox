function confirm = ScorSimSetDeltaBSEPR(varargin)
% SCORSIMSETDELTABSEPR set the ScorBot visualization by increments 
%   specified in the 5-element joint configuration.
%   SCORSIMSETDELTABSEPR(scorSim,BSEPR) set the ScorBot visualization 
%   specified in "scorSim" by increments specified in the 5-element joint 
%   configuration "BSEPR".
%
%   confirm = SCORSIMSETDELTABSEPR(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also ScorSimInit ScorSimSetBSEPR ScorSimSetDeltaXYZPR
%
%   M. Kutzer, 25Sep2015, USNA

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
        '\n\t-> and "%s(scorSim,DeltaBSEPR);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,DeltaBSEPR);" to execute this function.'],txt,mfilename);
    end
end
% No dBSEPR
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoDeltaBSEPR',...
        ['Change in joint configuration must be specified.',...
        '\n\t-> Use "%s(%s,DeltaBSEPR)".'],mfilename,txt);
end
% Check dBSEPR
if nargin >= 2
    dBSEPR = varargin{2};
    if ~isnumeric(dBSEPR) || numel(dBSEPR) ~= 5
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadDeltaBSEPR',...
            ['Change in joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "%s(%s,[DeltaJoint1,DeltaJoint2,...,DeltaJoint5])".'],mfilename,txt);
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Move simulation
BSEPR = ScorSimGetBSEPR(scorSim);
BSEPR = BSEPR + dBSEPR;
confirm = ScorSimSetBSEPR(scorSim,BSEPR);
