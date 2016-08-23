function BSEPR = ScorSimGetBSEPR(varargin)
% SCORSIMGETBSEPR get the current 5-element joint configuration from the 
% ScorBot visualization.
%   BSEPR = SCORSIMGETBSEPR(scorSim) get the current 5-element joint 
%   configuration "BSERP" from the ScorBot visualization specified by 
%   "scorSim". 
%
%   See also ScorSimInit ScorSimGetXYZPR
%
%   M. Kutzer, 13Aug2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "BSEPR = %s(scorSim);" to execute this function.'],mfilename)
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
            '\n\t-> and "BSEPR = %s(scorSim);" to execute this function.'],txt,mfilename);
    end
end
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Get BSEPR
for i = 1:numel(scorSim.Joints)
    H = get(scorSim.Joints(i),'Matrix');
    BSEPR(i) = atan2(H(2,1),H(1,1));
end