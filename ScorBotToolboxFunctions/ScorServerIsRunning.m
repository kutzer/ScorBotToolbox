function isRunning = ScorServerIsRunning
% SCORSERVERISRUNNING checks to see if ScorbotServer is running.
%
%   M. Kutzer, 17Jul2019

% Check if server is running
[~,cmdout] = system('tasklist /fi "imagename eq ScorbotServer.exe"');
% If the server is *not* running, we expect response resembling the
% following:
%   "INFO: No tasks are running which match the specified
%   criteria."
isRunning = ~contains(cmdout,'No tasks are running which match the specified criteria.');