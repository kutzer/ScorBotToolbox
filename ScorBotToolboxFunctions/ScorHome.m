function confirm = ScorHome()
% SCORHOME homes the ScorBot 
%   SCORHOME homes the ScorBot and enables control.
%
%   confirm = SCORHOME returns 1 if successful and 0 otherwise.
%
%   See also ScorInit
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorHome.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated to include move-in-place after successful homing
%               successfully setting control to "on". This should allow
%               "ScorIsMoving" to reflect a state of 0 once ScorBot has
%               homed.
%   01Sep2015 - Updated to include set to default speed of 50%

%% Define library alias
libname = 'RobotDll';

%% Check library
isLoaded = libisloaded(libname);
if ~isLoaded
    confirm = false;
    % Error copied from ScorIsReady
    errStruct.Code       = NaN;
    errStruct.Message    = sprintf('TOOLBOX: The ScorBot library "%s" has not been loaded.',libname);
    errStruct.Mitigation = sprintf('Run "ScorInit" to intialize ScorBot.');
    ScorDispError(errStruct);
    return
end

%% Set teach pendant to auto
isAuto = ScorSetPendantMode('Auto');
if ~isAuto
    confirm = false;
    warning('Failed to set ScorBot Teach Pendant to "Auto"');
    return
end

%% Home robot
fprintf('Homing ScorBot...');
isHoming = calllib(libname,'RHome',int8('A'));
if ~isHoming
    confirm = false;
    fprintf('FAILED\n');
    warning('Unable to execute homing.');
    return
end

%% Check if robot is homed
isHome = calllib(libname,'RIsHomeDone');
if ~isHome
    confirm = false;
    fprintf('FAILED\n');
    warning('Unable to reach home position.');
    return
end

%% Enable robot
isOn = ScorSetControl('On');
if ~isOn
    confirm = false;
    fprintf('FAILED\n');
    warning('Failed to set ScorBot Control Mode to "On".');
    return
else
    confirm = true;
    fprintf('SUCCESS\n');
    % Execute "move" to update ScorIsMoving to 0
    XYZPR = ScorGetXYZPR;
    [~] = ScorSetXYZPR(XYZPR);
    % Initialize speed
    [~] = ScorSetSpeed(50);
end

