function confirm = ScorInit()
% SCORINIT initialize ScorBot
%   SCORINIT initializes ScorBot by loading applicable DLLs, initializing
%   USB communication, and enabling control.
%
%   confirm = SCORINIT(___) returns 1 if successful and 0 otherwise.
%
%   See also: ScorHome ScorSafeShutdown
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorInit.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss

%% Delete extra shutdown figure handles
ShutdownFig = 1845;
if ishandle(ShutdownFig)
    delete(ShutdownFig);
end

%% Define library alias
libname = 'RobotDll';

%% Create background figure to force ScorSafeShutdown when closing MATLAB
ShutdownFig = figure(ShutdownFig);
set(ShutdownFig,...
    'Color',[0.5,0.5,0.5],...
    'Name','ScorSafeShutdown',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'ToolBar','none',...
    'Units','normalized',...
    'Position',[0.005,0.943,0.167,0.028],...
    'HandleVisibility','off',...
    'Visible','off',...
    'CloseRequestFcn',@ScorShutdownCallback);

%% Check if library is loaded
confirm = true;
wrn = {};
fprintf('Loading ScorBot library...');
if ~libisloaded(libname)
    % Check for dll file
    if exist('RobotDll.dll','file') ~= 3 % MEX-file on MATLAB's search path
        confirm = false;
        wrn{end+1} = '"RobotDll.dll" not found.';
    end
    % Check for header file
    if exist('RobotDll.h','file') ~= 2 % full pathname to a file on MATLAB's search path
        confirm = false;
        wrn{end+1} = '"RobotDll.h" not found.';
    end
    % Return if files do not exist
    if ~confirm
        fprintf('FAILED\n');
        for i = 1:numel(wrn)
            warning(wrn{i});
        end
        return
    end
    % Load library
    [notFound,warnings] = loadlibrary('RobotDll','RobotDll.h','alias',libname);
    if ~isempty(notFound)
        confirm = false;
        fprintf('FAILED\n');
        warning('Failed to load library.');
        warning(warnings);
        return
    end
    % Check for success
    if libisloaded(libname)
        fprintf('SUCCESS\n');
    else
        confirm = false;
        fprintf('FAILED\n');
        warning('Library did not load successfully.');
        return
    end
else
    fprintf('SKIPPED\n');
    fprintf('\tScorBot library "%s" is already loaded.\n',libname);
end

%% Initialize ScorBot
fprintf('\n');
fprintf('Initializing USB interface...');
isCalled = calllib(libname,'RInitialize');
if ~isCalled
    confirm = false;
    fprintf('FAILED\n');
    warning('Unable to initialize.');
    return
end
% Wait for initialization to complete
iter = 0;
while iter < 20 % pause(2)
    if mod(iter,4) == 0
        fprintf(char([8,8,8]));
    else
        fprintf('.');
    end
    iter = iter+1;
	pause(.1);
end
% Wait for initialization completion to be confirmed
while calllib(libname,'RIsInitDone') == 0
    if mod(iter,4) == 0
        fprintf(char([8,8,8]));
    else
        fprintf('.');
    end
    iter = iter+1;
    pause(0.1);
    %TODO - add a FAILED stop condition
end
fprintf( char(repmat(8,1,mod(iter-1,4))) );
fprintf('...');
fprintf('SUCCESS\n');
fprintf('\t"POWER" light on the ScorBot Control Box should be green.\n');

%% Define USNA vector for sending points to the robot
fprintf('\n');
fprintf('Defining default waypoint vector...');
isCreated = ScorCreateVector('USNA',1000);
if ~isCreated
    confirm = false;
    fprintf('FAILED\n');
    warning('Unable to create waypoint vector location.');
    return
end
fprintf('SUCCESS\n\n');
fprintf('Initialization complete.\n');
fprintf('\t(1) Turn teach pendant to AUTO\n');
fprintf('\t(2) Home the ScorBot using "ScorHome"\n')
fprintf('\n'); % add line for cleaner display in the command prompt

%% Confirm and set hidden figure to green
confirm = true;
set(ShutdownFig,'Color',[0.0,1.0,0.0]);
