function confirm = ScorSimSetSpeed(varargin)
% SCORSIMSETSPEED changes the maximum speed of ScorBot to a percent of the
% maximum possible speed.
%   SCORSIMSETSPEED(scorSim,PercentSpeed) changes the maximum speed of the
%   interpolation used by the ScorBot simulation to "PercentSpeed" of the 
%   maximum possible speed.
%       PercentSpeed - scalar integer value, 0 < PercentSpeed <= 100
%
%   confirm = SCORSIMSETSPEED(___) returns 1 if successful and 0 otherwise.
%
%   NOTE: Speed remains fixed until a new speed is declared.
%
%   M. Kutzer, 21Aug2020, USNA

% TODO - ScorSimSetMoveTime

% Updates

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
% Get percent speed
PercentSpeed = -inf;
if nargin > 1
    PercentSpeed = varargin{2};
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end
% Check percent speed
if PercentSpeed <= 0 || PercentSpeed > 100
    error('Percent speed must be greater than 0 and less than or equal to 100');
end

%% Set speed 
PercentSpeed = round(PercentSpeed);
set(scorSim.Speed,'String',sprintf('%d',PercentSpeed));