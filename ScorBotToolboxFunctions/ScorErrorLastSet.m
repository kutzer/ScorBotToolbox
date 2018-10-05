function ScorErrorLastSet(sError)
% SCORERRORLASTSET updates the last error returned by the ScorBot
% controller.
%   SCORERRORLASTSET(sError) updates the last error to the value provided.
%
%   See also ScorIsReady ScorParseErrorCode
%
%   M. Kutzer, 25Sep2018, USNA

% Updates
%   02Oct2018 - Added shutdown figure check and return

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

%% Set string to error code
set(txt,'String',sprintf('%d',sError));