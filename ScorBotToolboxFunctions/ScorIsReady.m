function [isReady,libname,errStruct] = ScorIsReady(dispFlag)
%SCORISREADY checks if ScorBot is ready for use.
%   isReady = SCORISREADY returns 1 if ScorBot is ready for use and 0
%   otherwise. Any errors encountered by ScorBot will be printed to the
%   command window. No actual MATLAB error is thrown.
%
%   [isReady,libname] = SCORISREADY returns a binary value indicating if
%   ScorBot is ready, and returns the library alias for ScorBot. Any errors
%   encountered by ScorBot will be printed to the command window. No actual
%   MATLAB error is thrown.
%
%   [isReady,libname,errStruct] = SCORISREADY returns a binary value
%   indicating if ScorBot is ready, the library alias for ScorBot, and any
%   error flags returned by ScorBot. Errors encountered by ScorBot are
%   available in errStruct. No MATLAB errors are thrown and there is no
%   error text printed to the command prompt.
%       errStruct.Code       - ScorBot error code (integer value)
%       errStruct.Message    - Message describing ScorBot error code
%       errStruct.Mitigation - Suggested mitigation for ScorBot error
%
%   [___] = SCORISREADY('Display All') displays all messages, including
%       non-critical teach/auto messages returned by ScorBot. "Display All"
%       also prints all messages to the command prompt, regardless of
%       specified outputs.
%
%   See also ScorInit ScorHome
%
%   M. Kutzer 10Aug2015, USNA
%
%   J. Donnal, 28Jun2017, USNA (64-bit Support)

% Updates
%   28Aug2015 - Updated to replace ErrorFlag output with errStruct output
%   28Aug2015 - Updated error handling and introduced ScorDispError
%   28Aug2015 - Updated to include control enable/disable tracking using
%               ScorGetControl and error states
%   01Sep2015 - Added special case for Teach Pendant messages so isReady is
%               held true
%   15Sep2015 - Updated to suppress teach pendant messages by default, and
%               display in black if "Display All" flag is set.
%   25Sep2018 - Updated to include "last error" tracking and check
%   17Jul2019 - Updated to replace instances of "calllib.m" with
%               "ScorCallLib.m" to include J. Donnal 64-bit solution 
%   17Jul2019 - Updated to include "libisloaded" equivalent check for
%               64-bit, "system('tasklist..." 
%   18Jul2019 - Added error-check prior to IsHomeDone query

persistent osbits

%% Check operating system
if isempty(osbits)
    switch computer
        case 'PCWIN'
            % 32-bit OS
            osbits = 32;
        case 'PCWIN64'
            % 64-bit OS
            osbits = 64;
    end
end

%% Check input(s) and set default(s)
nOut = nargout;
if nargin == 0
    dispFlag = 'Display Critical';
end

%% Set default error structure
errStruct = ScorParseErrorCode([]);

%% Define library alias
libname = 'RobotDll';

%% Check for exceptions
[ST,~] = dbstack;
ST = rmfield(ST,{'file','line'});
cST = struct2cell(ST);
callExceptions = ...
    {'ScorInit',...
    'ScorHome',...
    'ScorSetControl'};
for i = 1:numel(callExceptions)
    isException = max( strcmp(cST,callExceptions{i}) );
    if isException
        isReady = true;
        return
    end
end

%% Check library or server
switch osbits
    case 32
        % 32-bit OS
        % -> [...] = calllib(libname,funcname,...);
        isLoaded = libisloaded(libname);
        if ~isLoaded
            isReady = false;
            errStruct.Code       = NaN;
            errStruct.Message    = sprintf('TOOLBOX: The ScorBot library "%s" has not been loaded.',libname);
            errStruct.Mitigation = sprintf('Run "ScorInit" to intialize ScorBot');
            errStruct.QuickFix   = sprintf('ScorInit;');
            
            ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
            ShowErrorToUser;                    % Show error to user
            return
        end
    case 64
        % 64-bit OS
        % -> ScorServerCMD using ScorbotServer.exe
        % Check if server is running
        isRunning = ScorServerIsRunning;
        if ~isRunning
            isReady = false;
            errStruct.Code       = NaN;
            errStruct.Message    = sprintf('TOOLBOX: The ScorBot server "%s" is not running.','ScorbotServer.exe');
            errStruct.Mitigation = sprintf('Run "ScorInit" to intialize ScorBot');
            errStruct.QuickFix   = sprintf('ScorInit;');
            
            ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
            ShowErrorToUser;                    % Show error to user
            return
        end
    otherwise
        error('OSBITS variable not set to known value.');
end

%% Check if ScorBot is homed
t0 = tic;   % Current time
tf = 30.0;  % Timeout threshold
while true
    % Check for ScorBot error
    sError = ScorCallLib(libname,'RIsError');
    errStruct = ScorParseErrorCode(sError);
    % Special case for control disabled
    if sError == 903
        ScorGetControl('SetControl','Off');
    end
    % If/when no error is found, check if homing is finished
    if sError == 0
        isHome = ScorCallLib(libname,'RIsHomeDone');
        if ~isHome
            isReady = false;
            errStruct.Code       = NaN;
            errStruct.Message    = sprintf('TOOLBOX: The ScorBot has not executed the homing sequence.');
            errStruct.Mitigation = sprintf('Run "ScorHome" to home ScorBot');
            errStruct.QuickFix   = sprintf('ScorHome;');
            
            ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
            ShowErrorToUser;                    % Show error to user
            return
        end
        break
    else
        ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
        ShowErrorToUser;                    % Show error to user
    end
    % Timeout if tf is exceeded
    % Throw timeout
    t = toc(t0);
    if t > tf
        isReady = false;
        errStruct.Code       = NaN;
        errStruct.Message    = sprintf('TOOLBOX: The ScorBot is throwing recurring errors.');
        errStruct.Mitigation = sprintf('Run "ScorHome" to home ScorBot');
        errStruct.QuickFix   = sprintf('ScorHome;');
        
        ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
        ShowErrorToUser;                    % Show error to user
        return
    end
end

%% Check for prior errors
% TODO - Update list of known errors to check
sError = ScorErrorLastGet;
switch sError
    case 201
        isReady = false;
        errStruct = ScorParseErrorCode(sError);
        
        ShowErrorToUser; % Show error to user
        return
    case 903
        isReady = false;
        errStruct = ScorParseErrorCode(sError);
        
        ShowErrorToUser; % Show error to user
        return
    otherwise
        % Continue through code
end

%% Check if ScorBot is enabled
isEnabled = ScorGetControl;
if ~strcmpi(isEnabled,'On')
    isReady = false;
    errStruct.Code       = NaN;
    errStruct.Message    = sprintf('TOOLBOX: The control of ScorBot is not enabled.');
    errStruct.Mitigation = sprintf('Use "ScorSetControl(''On'')" to enable control');
    errStruct.QuickFix   = sprintf('ScorSetControl(''On'');');
    
    ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
    ShowErrorToUser;                    % Show error to user
    return
end

%% Check for ScorBot error
% -> Replaced by while loop
% sError = ScorCallLib(libname,'RIsError');
% errStruct = ScorParseErrorCode(sError);
% % Special case for control disabled
% if sError == 903
%     ScorGetControl('SetControl','Off');
% end

%% Display error message if user does not get the output
ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
ShowErrorToUser;                    % Show error to user

%% Output special case for Teach Pendant messages
if errStruct.Code == 970 || errStruct.Code == 971
    isReady = true;
    return
end

%% Output isReady (true or false)
if errStruct.Code ~= 0
    isReady = false;
else
    isReady = true;
end

%% Internal function(s) with Shared workspace
    function ShowErrorToUser
        % Write to error log
        % TODO - Consider ignoring redundant (i.e. *ErrorLast errors to 
        %        reduce file size
        if errStruct.Code ~= 0
            ScorErrorLogWrite(errStruct.Code);
        end
        
        % Impose dispay condition
        switch lower(dispFlag)
            case 'display all'
                ScorDispError(errStruct,dispFlag);
            case 1
                ScorDispError(errStruct,dispFlag);
            otherwise
                % Only display if the calling function does not ask for the
                % error structured variable as an output
                if nOut < 3
                    ScorDispError(errStruct,dispFlag);
                end
        end
        % 
    end

end % END CONTAINING FUNCTION