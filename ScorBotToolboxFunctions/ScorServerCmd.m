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
%   16Jul2019 - Updated JSON message interpretation to correct issue(s)
%               M. Kutzer

%% Set debug flag
debugFlag = false;

%% Create url
base_url='http://localhost:8080/scorbot?cmd=';
param_str='';
if nargin > 1
    param_str = '';
    for i = 1:length(varargin)
        param_str = strcat(param_str,'&param',num2str(i),'=',num2str(varargin{i}));
    end
end
url = strcat(base_url,cmd,param_str);

%% Display debug information
if debugFlag
    fprintf(2,'DEBUG ');
    fprintf('URL: "%s"\n',url);
end

%% Read url
options=weboptions('timeout',Inf);
r = webread(url,options);

%% Convert JSON message to character array
str = char(r.');    % Convert JSON message to a character string
if debugFlag
    fprintf(2,'DEBUG ');
    fprintf(' --> "%s"\n',str);
end

%% Parse character array
switch lower( str )
    case 'error'
        status = 0;
        data = [];
    case 'ok'
        status = 1;
        data = [];
    case 'unknown command'
        error('The command "%s" is not recognized by the ScorbotServer.',cmd);
    otherwise
        status = 1;
        try
            data = jsondecode(str);
        catch
            data = [];
            fprintf('\n');
            fprintf(2,'--- Unable to decode JSON ---\n');
            fprintf(2,'\t    url: %s\n',url);
            fprintf(2,'\twebread: r = [');
            fprintf(2,' %d ',r);
            fprintf(2,']\n');
            fprintf(2,'\t string: str = "%s"\n',str);
            fprintf(2,'-----------------------------\n');
        end
end

%% Original content
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
