function spd = ScorSimGetSpeed(varargin)
% SCORGETSPEED gets the current speed of ScorBot as a percent of the
% maximum possible speed.
%   spd = SCORGETSPEED gets the current speed of the ScorBot simulation as 
%       a percent of the maximum possible speed.
%
%   See also: ScorSimSetSpeed 
%
%   M. Kutzer, 28Aug2015, USNA

% TODO - ScorSimSetMoveTime

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim);" to execute this function.'],txt,mfilename);
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Get speed
spd = str2double( get(scorSim.Speed,'String') );