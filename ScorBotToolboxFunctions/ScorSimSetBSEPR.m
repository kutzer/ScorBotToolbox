function confirm = ScorSimSetBSEPR(varargin)
% SCORSIMSETBSEPR set the ScorBot visualization to the specified 5-element
% joint configuration.
%   SCORSIMSETBSEPR(scorSim,BSEPR) set the ScorBot visualization specified 
%   by "scorSim" to the specified 5-element joint configuration "BSEPR".
%
%   confirm = SCORSIMSETBSEPR(___) returns 1 if successful and 0 otherwise.
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also ScorSimInit ScorSimSetDeltaBSEPR ScorSimSetXYZPR
%
%   M. Kutzer, 13Aug2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated to add "confirm" output
%   01Sep2016 - Updated to include BSEPR/XYZPR pitch distinction

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,BSEPR);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,BSEPR);" to execute this function.'],txt,mfilename);
    end
end
% No BSEPR
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:BadPose',...
        ['Joint configuration must be specified.',...
        '\n\t-> Use "%s(%s,BSEPR)".'],mfilename,txt);
end
% Check BSEPR
if nargin >= 2
    BSEPR = varargin{2};
    if ~isnumeric(BSEPR) || numel(BSEPR) ~= 5
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadBSEPR',...
            ['Joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "%s(%s,[Joint1,Joint2,...,Joint5]);".'],mfilename,txt);
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Move simulation
for i = 1:numel(scorSim.Joints)
    set(scorSim.Joints(i),'Matrix',Rz(BSEPR(i)));
end
confirm = true;
drawnow