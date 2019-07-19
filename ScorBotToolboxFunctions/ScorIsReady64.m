function [isReady,libname,errStruct] = ScorIsReady64(dispFlag,nOut)
% 64-bit VERSION OF ScorIsReady <-- This is a desperate attempt to solve 
% 201 error issues.
%
% See help documentation for ScorIsReady


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


%% Check input(s) and set default(s)
% nOut = nargout;
% if nargin == 0
%     dispFlag = 'Display Critical';
% end

%% Set default error structure
errStruct = ScorParseErrorCode([]);

%% Define library alias
libname = []; % The 64-bit version of this interface accesses the USBC 
              % library using ScorbotServer.exe

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

%% Check for error & check if server is initialized
try 
    % Check for error
    sError = ScorCallLib(libname,'RIsError');
catch
    % Server is *probably* refusing a connection (meaning it is likely not
    % running.
    isReady = false;
    errStruct.Code       = NaN;
    errStruct.Message    = sprintf('TOOLBOX: The ScorBot server "%s" is not running.','ScorbotServer.exe');
    errStruct.Mitigation = sprintf('Run "ScorInit" to intialize ScorBot');
    errStruct.QuickFix   = sprintf('ScorInit;');
    
    ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
    ShowErrorToUser;                    % Show error to user
    return
end

% Parse & check error
errStruct = ScorParseErrorCode(sError);
% Special case for control disabled
if sError == 903
    ScorGetControl('SetControl','Off');
end

%% If no error was found, get the last error available.
if sError == 0
    % Get prior error information
    sError = ScorErrorLastGet;
else
    % Write to "ErrorLast" and show to user
    ScorErrorLastSet(errStruct.Code);   % Update the "last error" code
    ShowErrorToUser;                    % Show error to user
end
    
%% Respond to specific error(s)
switch sError
    case 0
        isReady = true;
        return
    case 908
        % Out of workspace
        isReady = true;
        return
    case 970
        % Switched to teach mode
        isReady = true;
        return
    case 971
        % Switched to auto mode
        isReady = true;
        return
    otherwise
        isReady = false;
        return
end
    
% THIS METHOD IS STREAMLINED! 
%  -> It no longer checks if the USB connection is initialized
%  -> It no longer checks if the robot is homed

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