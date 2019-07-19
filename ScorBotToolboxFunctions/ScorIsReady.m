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

%% Check library or server
switch osbits
    case 32
        [isReady,libname,errStruct] = ScorIsReady32(dispFlag,nOut);
    case 64
        [isReady,libname,errStruct] = ScorIsReady64(dispFlag,nOut);
    otherwise
        error('OSBITS variable not set to known value.');
end
