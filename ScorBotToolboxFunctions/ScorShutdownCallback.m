function ScorShutdownCallback(src,callbackdata)
% SCORSHUTDOWNCALLBACK callback function to enforce ScorSafeShutdown when
% MATLAB is closed.
%
%   NOTE: This function is not intended for general use.
%
%   M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated to include a note to not use ctrl-C during
%               shutdown

clc;
fprintf(2,'"ScorSafeShutdown" was not executed before closing MATLAB.\n');
fprintf(2,'Executing "ScorSafeShutdown"...\n');
fprintf('\n');
fprintf(2,'*DO NOT* USE "Ctrl-C" DURING THIS PROCESS\n');
fprintf('\n');
msg = '!!!ScorBot may move during the shutdown process!!! ';
for i = 1:10
    ScorSound;
    fprintf(2,msg);
    pause(0.5);
    fprintf( char(repmat(8,1,numel(msg))) );
    pause(0.1);
end

ScorSafeShutdown;