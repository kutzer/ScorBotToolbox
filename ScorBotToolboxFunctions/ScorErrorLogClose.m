function ScorErrorLogClose
% SCORERRORLOGCLOSE closes and, if applicable, uploads the ScorBot error
% log for review.
%
%   M. Kutzer, USNA, 26Sep2018

% Updates
%   03Oct2018 - Display status to user.

%% Get file ID from current error log
fileID = ScorErrorLogGetFileID;

%% Close file if valid ID is found
% Get error log filename
logFile = fopen(fileID);
if ~isempty(logFile)
    % Close error log file
    fclose(fileID);
end

%% Check for toolbox debug patch
if exist('ToolboxDebug_MailReport.m','file') == 2
    warning('M-file of "ToolboxDebug_MailReport" was inadvertently installed.');
elseif exist('ToolboxDebug_MailReport.p','file') == 6
    % P-File is correctly installed with patch.
else
    % TODO - consider providing the user with a message stating the path
    % and file name for the error log file.
    return
end

%% Find all instances of error logs and, if applicable, send logs
% Logs contained in the ScorBot error log directory
pathname = ScorErrorLogDir;
logFiles = ScorErrorLogFind(pathname);
for i = 1:numel(logFiles)
    filename = fullfile(pathname,logFiles{i});
    fprintf('Sending error log "%s"...',logFiles{i});
    isSent = ToolboxDebug_MailReport(filename);
    if isSent
        fprintf('SUCCESS\n');
        delete(filename);
    else
        fprintf('FAILED\n');
    end
end

% Logs contained in the userpath
pathname = userpath;
logFiles = ScorErrorLogFind(pathname);
for i = 1:numel(logFiles)
    filename = fullfile(pathname,logFiles{i});
    fprintf('Sending error log "%s"...',logFiles{i});
    isSent = ToolboxDebug_MailReport(filename);
    if isSent
        fprintf('SUCCESS\n');
        delete(filename);
    else
        fprintf('FAILED\n');
    end
end
