function isMoving = ScorIsMoving()
% SCORISMOVING checks if the ScorBot is executing a move.
%   isMoving = SCORISMOVING returns 1 if ScorBot is executing a move and 0
%   otherwise.
%
%   See also: ScorWaitForMove
%       
%   M. Kutzer, 10Aug2015, USNA

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    isMoving = false;
    return
end

%% Check if ScorBot is moving
switch calllib(libname,'RIsMotionDone')
    case 0 % ScorBot is moving
        isMoving = true;
    case 1 % ScorBot is finished moving
        isMoving = false;
    otherwise
        error('Unexpected response from "calllib(''%s'',''RIsMotionDone'')".',libname);
end
