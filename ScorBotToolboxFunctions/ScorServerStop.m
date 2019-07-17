function status = ScorServerStop


% Check if server is running
[~,cmdout] = system('taskkill /f /im "ScorbotServer.exe"');

% If the server task is killed, we expect the following message:
%   "SUCCESS: The process "ScorbotServer.exe" with PID 11528 has been
%   terminated."
% If the server was not running, or something else happened, we expect the
% following message:
%   "ERROR: The process "ScorbotServer.exe" not found.

status = contains(cmdout,'SUCCESS');