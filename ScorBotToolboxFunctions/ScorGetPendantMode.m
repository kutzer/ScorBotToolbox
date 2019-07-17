function pMode = ScorGetPendantMode()
% SCORGETPENDANTMODE gets the current mode of the ScorBot teach pendant
%   pMode = SCORGETPENDANTMODE gets the current mode of the ScorBot teach 
%   pendant (either "Teach" or "Auto"). 
%
%   See also: ScorSetPendantMode
%       
%   M. Kutzer, 10Aug2015, USNA
%
%   J. Donnal, 28Jun2017, USNA (64-bit Support)

% Updates
%   28Aug2015 - Updated error handling
%   25Sep2015 - Ignore isReady flag
%   17Jul2019 - Updated error handling
%   17Jul2019 - Updated to replace instances of "calllib.m" with
%               "ScorCallLib.m" to include J. Donnal 64-bit solution 

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
% if ~isReady
%     pMode = [];
%     return
% end

%% Get teach pendant mode
isTeach = ScorCallLib(libname,'RIsTeach');
switch isTeach
    case 0
        pMode = 'Auto';
    case 1
        pMode = 'Teach';
    otherwise
        error('ScorCallLib:NoResponse','Unexpected response from "ScorCallLib(''%s'',''RIsTeach'')"',libname);
end