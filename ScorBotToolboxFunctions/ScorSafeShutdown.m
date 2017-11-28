function confirm = ScorSafeShutdown()
% SCORSAFESHUTDOWN runs all processes to safely shutdown ScorBot.
%   SCORSAFESHUTDOWN moves the ScorBot to the home position, disables 
%   control, and unloads the ScorBot library. This function should be run 
%   prior to closing MATLAB.
%
%   confirm = SCORSAFESHUTDOWN(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also ScorInit ScorHome
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorSafeShutdown.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   25Aug2015 - Updated to make unload library "SUCCESS" occur after 
%               library is actually unloaded.
%   28Aug2015 - Updated to delete ScorGetSpeed/ScorGetMoveTime file
%   31Aug2015 - Updated to delete ScorGetControl file
%   31Aug2015 - Updated to reorder turning off digital out and deleting the
%               ScorGetControl file
%   01Sep2015 - Added ScorWaitForMove prior to entering shutdown
%   15Sep2015 - Added ScorSetPendantMode('Auto') prior to ScorWaitForMove.
%   28Nov2017 - Updated to override ScorHome prompt

%% Create global shutdown figure handle
ShutdownFig = 1845;

%% Setup confirmation flags array
confirm = [];

%% Set Teach Pendant to Auto Mode
isAuto = ScorSetPendantMode('Auto');
if ~isAuto
    confirm(end+1) = false;
    warning('ScorBot must be in Auto mode during shutdown.');
end

%% Wait for any/all previous moves
ScorWaitForMove;

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    ScorSetControl('On');
end

%% Open/close gripper 
ScorSetGripper('Open');
ScorWaitForMove;
ScorSetGripper('Close');
ScorWaitForMove;

%% Home ScorBot
ScorSetSpeed(50);
isMovedHome = ScorGoHome;
ScorWaitForMove;
pause(2);
if ~isMovedHome
    isHome = ScorHome(true);
    if ~isHome
        confirm(end+1) = false;
        warning('Unable to home ScorBot.');
    else
        confirm(end+1) = true;
    end 
else
    confirm(end+1) = true;
end

%% Move gripper to neutral state
ScorSetGripper(35);
ScorWaitForMove;

%% Delete speed and move time file
ScorGetSpeed('DeleteSpeed');

%% Turn off digital outputs
fprintf('Turning off digital outputs...');
isDig = ScorSetDigitalOutput(zeros(1,8));
if ~isDig
    fprintf('FAILED\n');
    confirm(end+1) = false;
    warning('Unable to set ScorBot digital outputs to "Off".');
else
    fprintf('SUCCESS\n');
    confirm(end+1) = true;
end

%% Disable robot
fprintf('Setting ScorBot Control Mode to "Off"...'); 
isOff = ScorSetControl('Off');
if ~isOff
    fprintf('FAILED\n');
    confirm(end+1) = false;
    warning('Unable to set ScorBot Control Mode to "Off".');
else
    fprintf('SUCCESS\n');
    confirm(end+1) = true;
end

%% Delete control file
ScorGetControl('DeleteControl');

%% Unload library
fprintf('Unloading "%s" library...',libname); 
try
    unloadlibrary(libname);
    fprintf('SUCCESS\n');
    confirm(end+1) = true;
    fprintf('ScorBot library has been unloaded.\n')
    fprintf('\tRun "ScorInit" and "ScorHome" to continue using ScorBot\n');
catch
    fprintf('FAILED\n');
    confirm(end+1) = false;
    warning('Unable to unload "%s".',libname);
end

%% Define final confirmation state
confirm = min(confirm);

%% Delete "ShutdownFig"
if ishandle(ShutdownFig)
    delete(ShutdownFig);
end
