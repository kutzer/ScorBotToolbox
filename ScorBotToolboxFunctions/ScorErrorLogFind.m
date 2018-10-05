function logFiles = ScorErrorLogFind(varargin)
% SCORERRORLOGFIND searches for ScorBot Toolbox error logs
%   logFiles = SCORERRORLOGFIND searches in the default error log directory
%   returned by SCORERRORLOGDIR for ScorBot Toolbox error logs. Log file
%   names are returned as a cell array.
%
%   logFiles = SCORERRORLOGFIND(pathname) searches in the specified
%   directory for ScorBot Toolbox error logs. Log file names are returned
%   as a cell array.
%
%   M. Kutzer, 11Sep2018, USNA

%% Check input(s)
if nargin < 1
    logPath = ScorErrorLogDir;
else
    logPath = varargin{1};
    if ~isdir(logPath)
        %warning('Specified path is not valid, using default error log directory.');
    end
end

%% Find all error log files
logBase = ScorErrorLogBase;
D = dir(logPath);

logFiles = {};
% TODO - this can be MUCH faster
for i = 1:numel(D)
    if ~D(i).isdir
        if numel(D(i).name) > numel(logBase)
            testBase = D(i).name(1:numel(logBase));
            if isequal(logBase,testBase)
                logFiles{end+1,1} = D(i).name;
            end
        end
    end
end

