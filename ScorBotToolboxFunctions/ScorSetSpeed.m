function confirm = ScorSetSpeed(PercentSpeed)
% SCORSETSPEED changes the maximum speed of ScorBot to a percent of the
% maximum possible speed.
%   SCORSETSPEED(PercentSpeed) changes the maximum speed of ScorBot to
%   "PercentSpeed" of the maximum possible speed.
%       PercentSpeed - scalar integer value, 0 < PercentSpeed <= 100
%
%   confirm = SCORSETSPEED(___) returns 1 if successful and 0 otherwise.
%
%   NOTE: Changing the speed with the teach pendant will not change the
%   speed when setting waypoint using MATLAB. 
%
%   NOTE: Speed remains fixed until a new speed or move time is declared.
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
%       for PercentSpeed = 10:10:100
%           tic;
%           ScorSetSpeed(PercentSpeed);
%           fprintf('Moving at %d%% of max speed.\n',PercentSpeed);
%           for i = 1:size(BSEPR,1)
%               ScorSetBSEPR(BSEPR(i,:));
%               ScorWaitForMove;
%           end
%           toc
%       end
%       ScorGoHome;
%
%   See also ScorGetSpeed ScorSetMoveTime
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorSetSpeed.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated to include ScorGetSpeed functionality
%   01Sep2016 - Updated help documentation

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check inputs
narginchk(1,1);

if PercentSpeed <= 0 || PercentSpeed > 100
    error('Percent speed must be greater than 0 and less than or equal to 100');
end

%% Set speed 
PercentSpeed = round(PercentSpeed);
isSet = calllib(libname,'RSetSpeed',PercentSpeed);
if isSet
    confirm = true;
    ScorGetSpeed('SetSpeed',PercentSpeed);
    return
else
    confirm = false;
    if nargout == 0
        warning('Failed to set the specified speed.');
    end
    return
end