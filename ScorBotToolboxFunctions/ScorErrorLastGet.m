function sError = ScorErrorLastGet
% SCORERRORLASTGET gets the last error returned from the ScorBot
% controller. 
%   sError = SCORERRORLASTGET returns the last error code returned from the
%   ScorBot controller.
%
%   See also ScorParseErrorCode
%
%   M. Kutzer, 25Sep2018, USNA

%% Define shutdown figure handle
ShutdownFig = 1845;

% Check for valid shutdown figure
if ~ishandle(ShutdownFig)
    % ScorBot has not been initialized
    return
end

%% Get text object
txt = findobj(ShutdownFig,'Tag','ScorBot Handle, Last Error');

%% Check for valid text object
if isempty(txt)
    % Initialize the last error text object
    txt = ScorErrorLastInit;
end

%% Get string and return error value
err_str = get(txt,'String');
sError = str2double(err_str);
