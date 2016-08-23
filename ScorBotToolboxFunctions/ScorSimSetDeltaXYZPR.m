function confirm = ScorSimSetDeltaXYZPR(varargin)
% SCORSIMSETDELTAXYZPR set the ScorBot visualization by increments 
%   specified in the 5-element task-space vector.
%   SCORSIMSETDELTAXYZPR(scorSim,XYZPR) set the ScorBot visualization 
%   specified in "scorSim" by increments specified in the 5-element 
%   task-space vector "XYZPR".
%
%   confirm = SCORSIMSETDELTAXYZPR(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also ScorSimInit ScorSimSetXYZPR ScorSimSetDeltaBSEPR
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
        '\n\t-> and "%s(scorSim,DeltaXYZPR);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,DeltaXYZPR);" to execute this function.'],txt,mfilename);
    end
end
% No dXYZPR
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoDeltaXYZPR',...
        ['Change in end-effector position and orientation must be specified.',...
        '\n\t-> Use "%s(%s,DeltaXYZPR)".'],mfilename,txt);
end
% Check dXYZPR
if nargin >= 2
    dXYZPR = varargin{2};
    if ~isnumeric(dXYZPR) || numel(dXYZPR) ~= 5
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadDeltaXYZPR',...
            ['Change in end-effector position and orientation must be specified as a 5-element numeric array.',...
            '\n\t-> Use "%s(%s,[DeltaX,DeltaY,DeltaZ,DeltaPitch,DeltaRoll])".'],mfilename,txt);
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Move simulation
XYZPR = ScorSimGetXYZPR(scorSim);
XYZPR = XYZPR + dXYZPR;
confirm = ScorSimSetXYZPR(scorSim,XYZPR);