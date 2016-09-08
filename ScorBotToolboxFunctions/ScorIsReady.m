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

% Updates
%   28Aug2015 - Updated to replace ErrorFlag output with errStruct output
%   28Aug2015 - Updated error handling and introduced ScorDispError
%   28Aug2015 - Updated to include control enable/disable tracking using
%               ScorGetControl and error states
%   01Sep2015 - Added special case for Teach Pendant messages so isReady is
%               held true
%   15Sep2015 - Updated to suppress teach pendant messages by default, and
%               display in black if "Display All" flag is set.

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

%% Check library
isLoaded = libisloaded(libname);
if ~isLoaded
    isReady = false;
    errStruct.Code       = NaN;
    errStruct.Message    = sprintf('TOOLBOX: The ScorBot library "%s" has not been loaded.',libname);
    errStruct.Mitigation = sprintf('Run "ScorInit" to intialize ScorBot');
    errStruct.QuickFix   = sprintf('ScorInit;');
    if nargout < 3
        ScorDispError(errStruct);
    end
    return
end

%% Check if ScorBot is homed
isHome = calllib(libname,'RIsHomeDone');
if ~isHome
    isReady = false;
    errStruct.Code       = NaN;
    errStruct.Message    = sprintf('TOOLBOX: The ScorBot has not executed the homing sequence.');
    errStruct.Mitigation = sprintf('Run "ScorHome" to home ScorBot');
    errStruct.QuickFix   = sprintf('ScorHome;');
    if nargout < 3
        ScorDispError(errStruct);
    end
    return
end

%% Check if ScorBot is enabled
isEnabled = ScorGetControl;
if ~strcmpi(isEnabled,'On')
    isReady = false;
    errStruct.Code       = NaN;
    errStruct.Message    = sprintf('TOOLBOX: The control of ScorBot is not enabled.');
    errStruct.Mitigation = sprintf('Use "ScorSetControl(''On'')" to enable control');
    errStruct.QuickFix   = sprintf('ScorSetControl(''On'');');
    if nargout < 3
        ScorDispError(errStruct);
    end
    return
end

%% Check for ScorBot error
sError = calllib(libname,'RIsError');
errStruct = ScorParseErrorCode(sError);
% Special case for control disabled
if sError == 903
    ScorGetControl('SetControl','Off');
end

%% Display error message if user does not get the output
% Check inputs
if nargin == 0
    dispFlag = 'Display Critical';
end

switch lower(dispFlag)
    case 'display all'
        ScorDispError(errStruct,dispFlag);
    case 1
        ScorDispError(errStruct,dispFlag);
    otherwise
        if nargout < 3
            ScorDispError(errStruct,dispFlag);
        end
end

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

