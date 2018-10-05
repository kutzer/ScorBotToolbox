function logPath = ScorErrorLogDir
% SCORERRORLOGDIR defines the error log directory used for the ScorBot
% Toolbox.
%   logPath = SCORERRORLOGDIR returns the path for the directory used for
%   the ScorBot Toolbox error log.
%   
%   M. Kutzer, 11Sep2018, USNA

%% Define error log path excluding last file seperator
[logPath,~,~] = fileparts(tempdir);

%% Find file seperator and remove MATLAB-created temp folder from path
idx = strfind(logPath,filesep);
logPath(idx(end):end) = [];