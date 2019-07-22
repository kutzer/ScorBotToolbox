function [isMoving,errStruct] = ScorIsMoving()
% SCORISMOVING checks if the ScorBot is executing a move.
%   isMoving = SCORISMOVING returns 1 if ScorBot is executing a move and 0
%   otherwise.
%
%   See also: ScorWaitForMove
%       
%   M. Kutzer, 10Aug2015, USNA
%
%   J. Donnal, 28Jun2017, USNA (64-bit Support)

% Updates
%   06Sep2018 - Updated to identify specific error codes that stop movement
%   17Jul2019 - Updated to replace instances of "calllib.m" with
%               "ScorCallLib.m" to include J. Donnal 64-bit solution 

%% Check ScorBot and define library alias
% Check ScorBot
[isReady,libname,errStruct] = ScorIsReady;

% Display critical errors
dispFlag = 'Display Critical';
if errStruct.Code ~= 0
    %fprintf(2,'ScorIsMoving Error Catch: ');
    ScorDispError(errStruct);%,dispFlag);
end

% Return if robot is not ready
if ~isReady
    isMoving = false;
    return
end

% Define special-case error codes that stop the ScorBot
switch errStruct.Code
    case 201
        isMoving = false;
        return
    case 903
        isMoving = false;
        return
    case 911
        isMoving = false;
        return
    otherwise
        if isnan(errStruct.Code)
            isMoving = false;
            return
        end
end
        
%% Check if ScorBot is moving
switch ScorCallLib(libname,'RIsMotionDone')
    case 0 % ScorBot is moving
        isMoving = true;
    case 1 % ScorBot is finished moving
        isMoving = false;
    otherwise
        error('ScorCallLib:NoResponse','Unexpected response from "ScorCallLib(''%s'',''RIsMotionDone'')".',libname);
end
