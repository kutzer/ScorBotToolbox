function txt = ScorErrorLogInit
% SCORERRORLOGINIT creates and opens a new error log for tracking ScorBot
% commands and controller errors.
%   txt = SCORERRORLOGINIT returns the handle for the text object created
%   to monitor the error log file ID.
%
%   M. Kutzer, USNA, 25Sep2018

% Updates
%   02Oct2018 - Added shutdown figure check and return

%% Define shutdown figure handle
ShutdownFig = 1845;

% Check for valid shutdown figure
if ~ishandle(ShutdownFig)
    % ScorBot has not been initialized
    txt = nan;
    return
end

%% Get/create axes
% Check for existing axes
axs = findobj(ShutdownFig,'Tag','ScorBot Handle, Shutdown Axes');
% Create axes if one does not exist
if isempty(axs)
    axs = axes('Parent',ShutdownFig,'Visible','off','Tag','ScorBot Handle, Shutdown Axes');
end

%% Create text object to contain the file ID for the error log
% Check for existing handle
txt = findobj(ShutdownFig,'Tag','ScorBot Handle, Error Log ID');
% Create new text handle if one does not exist
if isempty(txt)
    fileID = -1;
    txt = text(0.5,0,sprintf('%d',fileID),...
        'Parent',axs,'Tag','ScorBot Handle, Error Log ID');
end

%% Get the current fileID
fileID = str2double( get(txt,'String') );

%% Create error log
iter = 0;       % Define number of attempts used to create the file ID
iterMAX = 3;    % Define the maximum allowable attempts

% Attempt to locate the error log file in the OS temp directory
%   NOTE: fopen returns -1 if/when the file cannot be opened
while fileID < 0 && iter < iterMAX
    % Define error log path
    pathname = ScorErrorLogDir;
    % Define error log base filename
    basename = ScorErrorLogBase;
    % Get current date & time in string format
    date_str = datestr(now,'yyyy_mm_dd_HH.MM.ss');
    % Define filename
    filename = sprintf('%s%s.log',basename,date_str);
    % Open log file
    [fileID,errmsg] = fopen( fullfile(pathname,filename),'w');
    % Increment iter
    iter = iter+1;
end

% If unsuccessful, attempt to locate file in the default userpath
if fileID < 0
    % Define error log path as user path
    pathname = userpath;
    % Throw warning
    warning('Unable to open the error log file in the default location: "%s"',pathname);
    % Open log file
    [fileID,errmsg] = fopen( fullfile(pathname,filename),'w');
end

%% Update error log file ID 
if fileID ~= -1
    set(txt,'String',sprintf('%d',fileID));
else
    % TODO - display errmsg in warning
    warning('Unable to create an error log file.');
end