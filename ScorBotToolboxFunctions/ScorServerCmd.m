function [status,data] = ScorServerCmd( cmd,varargin )
% SCORSERVERCMD send a command to ScorbotServer
%   SCORSETSPEED(cmd, parameters...)
%       cmd - string name of RobotDll function to call
%       parameters - parameters required by function
%
%   [status,data] = ScorServerCmd(___)
%   status is 1 if successful and 0 otherwise.
%   data is an optional field set by some RobotDll functions (eg RScorGetGripper)
%
%   Example:
%       %%
%       ScorServerCmd('RGripOpen') % opens gripper
%       [status, data] = ScorServerCmd('RGetJaw')
%       data % display grip width
%       ScorServerCmd('RGripMetric',35) % set gripper to 35mm
%
%   J. Donnal, 19Jun2017, USNA 

% Updates
%   16Jul2019 - Corrected JSON message interpretation issue(s), M. Kutzer

base_url='http://localhost:8080/scorbot?cmd=';
param_str='';
if nargin > 1
    param_str = '';
    for i = 1:length(varargin)
        param_str = strcat(param_str,'&param',num2str(i),'=',num2str(varargin{i}));
    end
end
url = strcat(base_url,cmd,param_str);

fprintf(2,'DEBUG ');
fprintf('URL: "%s"\n',url); % Kutzer addition.

options=weboptions('timeout',Inf);
r = webread(url,options);

% Kutzer Update
str = char(r.');    % Convert JSON message to a character string
switch str
    case 'error'
        status = 0;
        data = [];
    case 'ok'
        status = 1;
        data = [];
    otherwise
        status = 1;
        data = jsondecode(str);
end

%{
% ORIGINAL DONNAL CODE
str = strjoin(string(char(r)),'');
if(strcmp(str,'error'))
    status=0;
elseif(strcmp(str,'ok'))
    status=1;
    data = [];
else
    status=1;
    data = jsondecode(char(r));
end
%} 

end
