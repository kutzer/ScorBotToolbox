function confirm = ScorHome(varargin)
% SCORHOME homes the ScorBot 
%   SCORHOME homes the ScorBot and enables control.
%
%   confirm = SCORHOME returns 1 if successful and 0 otherwise. If homing
%   has already been executed, a pop-up dialog will prompt the user to see
%   if re-homing is the desired course of action.
%
%   confirm = SCORHOME(true) will bypass the user dialog and execute the
%   homing sequence regardless of prior homing.
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
%   08Sep2016 - Updated to include check for previously homed ScorBot with
%               pop-up (suggested by MIDN Jaunich)
%   13Jan2017 - Updated documentation

%% Define persistent variable for homing
persistent priorHome

% Set default prior home value to false
if isempty(priorHome)
    priorHome = false;
end

% Check if ScorBot has been shutdown
ShutdownFig = 1845;
if ~ishandle(ShutdownFig)
    % Implies ScorBot has been shutdown
    priorHome = false;
end

%% Check inputs
% TODO - update error dialog for too many inputs
narginchk(0,1);
if nargin == 1
    bypassDialog = varargin{1};
    % TODO - Consider lightening this to include 0 and 1
    if ~isscalar(bypassDialog) || ~islogical(bypassDialog)
        error('ScorHome:BadInput',...
            'Input argument must be a scalar logical value (e.g. "true" or "false").');
    end
else
    bypassDialog = false;
end

if bypassDialog
    % Run homing
    priorHome = false;
end

%% Pop-up to ask user if they really want to rehome the ScorBot
if priorHome
    cState = ScorGetControl;
    switch lower(cState)
        case 'on'
            % Define dialog message for "Control On" scenario
            dlgMsg = ...
                sprintf(...
                    ['ScorBot was previously homed and control appears to be enabled. \n',...
                     '\n',...
                     '  Note: You can use "ScorGoHome" as a faster alternative to the "ScorHome" \n',...
                     '        command if ScorBot has already been homed and is operating \n',...
                     '        correctly. \n',...
                     '\n',...
                     'Would you like ScorBot to run the homing sequence?']...
                 );
             % "Fast Option"
             btn3 = 'Execute "ScorGoHome"';
             fcn3 = 'ScorGoHome'; % NOTE: @ScorGoHome is a better option
        case 'off'
            % Define dialog message for "Control Off" scenario
            dlgMsg = ...
                sprintf(...
                    ['ScorBot was previously homed but control appears ',...
                     'to be disabled. \n',...
                     '\n',...
                     '  Note: You can use "ScorSetControl(''On'')" to attempt to recover control \n',...
                     '        of ScorBot without running the entire homing sequence. \n',...
                     '        -> If this does not work, re-homing is required. \n',...
                     '\n',...
                     'Would you like ScorBot to run the homing sequence?']...
                 );
             % "Fast Option"
             btn3 = 'Execute "ScorSetControl(''On'')"';
             fcn3 = 'ScorSetControl(''On'')';
        otherwise
            error('Unexpected response from ScorGetControl.');
    end
    % Prompt user
    choice = questdlg(dlgMsg,'Execute Homing Sequence','Yes','No',btn3,'Yes');
    switch lower(choice)
        case 'yes'
            % Run homing
            priorHome = false;  % Reset prior home status
        case 'no'
            % Skip homing
            confirm = 1;        % Assume ScorBot is homed
            priorHome = true;   % Maintain prior home status
            return
        case lower(btn3)
            % Execute fast option
            eval( sprintf('confirm = %s;',fcn3) );
            priorHome = true;
            return
        otherwise
            % Action cancelled
            fprintf('Action Cancelled.\n');
            % Run homing
            priorHome = false;  % Reset prior home status
    end
end

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
    % Set prior home value to true
    priorHome = true;
end

