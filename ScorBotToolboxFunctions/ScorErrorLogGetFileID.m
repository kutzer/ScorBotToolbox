function fileID = ScorErrorLogGetFileID
% SCORERRORLOGGETFILEID gets the file ID for the error log file used for 
% tracking ScorBot commands and controller errors.
%   fileID = SCORERRORLOGGETFILEID returns the file ID for the error log
%   file.
%
%   M. Kutzer, USNA, 26Sep2018

% Updates
%   02Oct2018 - Added shutdown figure check and return

%% Define shutdown figure handle
ShutdownFig = 1845;

% Check for valid shutdown figure
if ~ishandle(ShutdownFig)
    % ScorBot has not been initialized
    fileID = -1;
    return
end

%% Get text object containing file ID
% Check for existing handle
txt = findobj(ShutdownFig,'Tag','ScorBot Handle, Error Log ID');
% If handle does not exist, create error log file
if isempty(txt)
    txt = ScorErrorLogInit;
end

%% Get file ID from text object
if ishandle(txt)
    fileID = str2double( get(txt,'String') );
else
    fileID = -1;
end