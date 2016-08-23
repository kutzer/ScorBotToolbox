function pMode = ScorGetPendantMode()
% SCORGETPENDANTMODE gets the current mode of the ScorBot teach pendant
%   pMode = SCORGETPENDANTMODE gets the current mode of the ScorBot teach 
%   pendant (either "Teach" or "Auto"). 
%
%   See also: ScorSetPendantMode
%       
%   M. Kutzer, 10Aug2015, USNA

% Updates
%   28Aug2015 - Updated error handling
%   25Sep2015 - Ignore isReady flag

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
% if ~isReady
%     pMode = [];
%     return
% end

%% Get teach pendant mode
isTeach = calllib(libname,'RIsTeach');
switch isTeach
    case 0
        pMode = 'Auto';
    case 1
        pMode = 'Teach';
    otherwise
        error('Unexpected response from "calllib(''RobotDll'',''RIsTeach'')"');
end