function isMoving = ScorSimIsMoving(varargin)
% SCORSIMISMOVING checks if the ScorBot simulation is executing a move.
%   isMoving = SCORSIMISMOVING(scorSim) returns a 1 is the ScorBot
%   simulation is executing a move and a 0 otherwise.
%
%   See also: ScorSimWaitForMove
%
%   M. Kutzer, 21Aug2020, USNA

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSimSet:NoSimObj',...
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
        error('ScorSimSet:BadSimObj',...
            ['%s is not a valid ScorSim object.',...
            '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
            '\n\t-> and "%s(scorSim);" to execute this function.'],txt,mfilename);
    end
end

%% Get or Set scorSim.IsMoving
if nargin == 1
    isMoving = logical(str2double(get(scorSim.IsMoving,'String')));
else
    isMoving = logical(varargin{2});
    set(scorSim.IsMoving,'String',sprintf('%d',isMoving));
end