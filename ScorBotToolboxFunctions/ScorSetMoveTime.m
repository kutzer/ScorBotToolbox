function confirm = ScorSetMoveTime(t)
% SCORSETMOVETIME sets the duration for the next move in seconds.
%   SCORSETMOVE(t) sets the duration for the next move to "t" seconds.
%
%   confirm = SCORSETMOVETIME(___) returns 1 if successful and 0 otherwise.
%
%   NOTE: Move time remains fixed until a new speed or move time is
%   declared.
%   
%   Example:
%       %% Initialize and home ScorBot
%       ScorInit;
%       ScorHome;
%
%       %% Define two joint positions
%       BSEPR(1,:) = [0,pi/2,-pi/2,-pi/2,0];
%       BSEPR(2,:) = [0,pi/2,-0.10,-pi/2,0];
%       % Initialize arm configuration
%       ScorSetSpeed(100); 
%       ScorSetBSEPR(BSEPR(2,:));
%       ScorWaitForMove;
%
%       %% Evaluate various speeds
%       for MoveTime = linspace(2,15,10)
%           tic;
%           ScorSetMoveTime(MoveTime);
%           fprintf('Moving with Move Time of %.3f seconds.\n',MoveTime);
%           for i = 1:size(BSEPR,1)
%               ScorSetBSEPR(BSEPR(i,:));
%               ScorWaitForMove;
%               toc
%           end
%       end
%       ScorGoHome;
%
%   See also ScorGetMoveTime ScorSetSpeed
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorSetMovetime.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated to include ScorGetMoveTime functionality

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check inputs
narginchk(1,1);

%% Set move time
ms = round(t*1e3);
isTime = calllib(libname,'RSetTime',ms);
if isTime
    confirm = true;
    ScorGetMoveTime('SetMoveTime',t);
    return
else
    confirm = false;
    if nargout == 0
        warning('Failed to set the move time to %d ms.',ms);
    end
    return
end