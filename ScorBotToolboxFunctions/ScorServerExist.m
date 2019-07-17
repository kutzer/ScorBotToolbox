function out = ScorServerExist()
% SCORSERVEREXIST checks if ScorbotServer exists in default install 
% location.
%
%   M. Kutzer, 17Jul2019, USNA

out = false;
if exist('C:\Program Files (x86)\USNA\ScorbotServer\ScorbotServer.exe','file') == 2
    out = true;
end