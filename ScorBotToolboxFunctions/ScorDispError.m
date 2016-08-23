function ScorDispError(varargin)
% SCORDISPERROR display a formatted message from a ScorBot error structure
% to the command prompt.
%   SCORDISPERROR(errStruct) display a formatted message from a ScorBot 
%   error structure to the command prompt. Teach pendant messages are not
%   displayed.
%       errStruct.Code       - ScorBot error code (integer value) 
%       errStruct.Message    - Message describing ScorBot error code
%       errStruct.Mitigation - Suggested mitigation for ScorBot error
%
%   SCORDISPERROR(errStruct,'Display All') display a formatted message from
%   a ScorBot error structure to the command prompt. Teach pendant messages
%   are displayed in black without a "beep."
%   
%   See also ScorParseErrorCode ScorIsReady
%
%   M. Kutzer, 28Aug2015, USNA

% Updates
%   15Sep2015 - Updated to remove beep and red message display for teach
%               pendant messages.
%   15Sep2015 - Updated to ignore teach pendant messages by default, and
%               display in black if "Display All" flag is set.

%% Check inputs 
narginchk(1,2);

if nargin > 0 
    errStruct = varargin{1};
end
if nargin > 1
    switch lower(varargin{2})
        case 'display all'
            dispAll = true;
        case 'display critical'
            dispAll = false;
        case 1
            dispAll = true;
        case 0 
            dispAll = false;
        otherwise 
            error('Unexpected property value for "%s".',varargin{2});
    end
else
    dispAll = false;
end

%% Output special case for Teach Pendant messages
% Teach pendant messages
if errStruct.Code == 970 || errStruct.Code == 971
    if dispAll
        % Display teach/auto messages in black
        fprintf('\nScorBot Message [%d]\n->%s\n\t %s\n',...
            errStruct.Code,errStruct.Message,errStruct.Mitigation);
    else
        % Ignore teach pendant messages
    end
    return
end
% All else
if errStruct.Code ~= 0
    % Beep to notify the user
    beep;
    % Display message in red, fprintf(2,...)
    fprintf(2,'\nScorBot Message [%d]\n->%s\n\t %s\n',...
        errStruct.Code,errStruct.Message,errStruct.Mitigation);
end