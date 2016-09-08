function installScorBotToolbox(replaceExisting)
% INSTALLSCORBOTTOOLBOX installs ScorBot Toolbox for MATLAB.
%   INSTALLSCORBOTTOOLBOX installs ScorBot Toolbox into the following 
%   locations:
%                        Source: Destination
%       ScorBotToolboxFunctions: matlabroot\toolbox\scorbot
%         ScorBotToolboxSupport: matlabroot\bin\win32 
%
%   INSTALLSCORBOTTOOLBOX(true) installs ScorBot Toolbox regardless of
%   whether a copy of the ScorBot toolbox exists in the MATLAB root.
%
%   INSTALLSCORBOTTOOLBOX(false) installs ScorBot Toolbox only if no copy 
%   of the ScorBot toolbox exists in the MATLAB root.
%
%   NOTE: This toolbox requires a 32-bit Windows Operating System.
%
%   M. Kutzer 10Aug2015, USNA

% Updates
%   26Aug2015 - Updated to include replaceExisting to support
%               "ScorUpdate.m"
%   26Aug2015 - Updated to include rehash of toolbox cache
%   26Aug2015 - Updated to include drawnow before rehash of toolbox cache
%   08Sep2016 - Updated to correct questdlg default and title

% TODO - Allow users to create a local version if admin rights are not
% possible.

%% Install/Update required toolboxes
ToolboxUpdate('Transformation');
ToolboxUpdate('Plotting');

%% Check inputs
if nargin == 0
    replaceExisting = [];
end

%% Installation error solution(s)
adminSolution = sprintf(...
    ['Possible solution:\n',...
     '\t(1) Close current instance of MATLAB\n',...
     '\t(2) Open a new instance of MATLAB "as administrator"\n',...
     '\t\t(a) Locate MATLAB shortcut\n',...
     '\t\t(b) Right click\n',...
     '\t\t(c) Select "Run as administrator"\n']);

%% Check operating system info and compiler
if ispc
    switch computer
        case 'PCWIN'
            fprintf('32-bit Windows Operating System detected.\n');
            cc = mex.getCompilerConfigurations('C');
            switch cc.Name
                case 'lcc-win32'
                    fprintf('Mex compiler: "%s"\n',cc.Name);
                otherwise
                    fprintf('Unexpected Mex compiler: "%s"\n',cc.Name);
            end
            fullInstall = true;
        otherwise
            warning('Interaction with the ScorBot hardware requires a 32-bit Windows OS.');
            choice = questdlg(...
                sprintf(...
                    ['Full installation of the ScorBot Toolbox requires\n',...
                    'a 32-bit Windows OS.\n',...
                    '\n',...
                    '  - Installing on this OS will only enable\n',...
                    '    simulation capabilities.\n',...
                    '\n',...
                    'Would you like to install the simulation tools?']...
                 ),...
                 'Install Simulation Tools',...
                 'Yes','No','Yes');
            
            fullInstall = false;
            switch choice
                case 'Yes'
                    % Run installation
                case 'No'
                    fprintf('Installation cancelled.\n');
                    return
                case 'Cancel'
                    fprintf('Action cancelled.\n');
                    return
                otherwise
                    error('Unexpected response.');
            end
    end
else
    warning('Interaction with the ScorBot hardware requires a 32-bit Windows OS.');
    warndlg(sprintf(['This install and code has only been tested on\n',...
                     '32-bit and 64-bit Windows operating systems.']),...
                     'OS Warning');
    choice = questdlg(sprintf(...
        ['Full installation of the ScorBot Toolbox requires\n',...
        'a 32-bit Windows OS.\n',...
        '\n',...
        '  - Installing on this OS will only enable\n',...
        '    simulation capabilities.\n',...
        '\n',...
        'Would you like to install the simulation tools?']),...
        'Yes','No');
    
    fullInstall = false;
    switch choice
        case 'Yes'
            % Run installation
        case 'No'
            fprintf('Installation cancelled.\n');
            return
        case 'Cancel'
            fprintf('Action cancelled.\n');
            return
        otherwise
            error('Unexpected response.');
    end
end

%% Check for 32-bit bin directory
if fullInstall
    win32binRoot = fullfile(matlabroot,'bin','win32');
    
    isWin32bin = exist(win32binRoot,'file');
    if isWin32bin == 7
        %bin\win32 exists as expected
    else
        error('MATLAB root does not contain the directory:\n\t"%s"\n',isWin32bin);
    end
end

%% Check for toolbox directory
toolboxRoot  = fullfile(matlabroot,'toolbox','scorbot');
isToolbox = exist(toolboxRoot,'file');
if isToolbox == 7
    % Apply replaceExisting argument
    if isempty(replaceExisting)
        choice = questdlg(sprintf(...
            ['MATLAB Root already contains the ScorBot Toolbox.\n',...
            'Would you like to replace the existing toolbox?']),...
            'Yes','No');
    elseif replaceExisting
        choice = 'Yes';
    else
        choice = 'No';
    end
    % Replace existing or cancel installation
    switch choice
        case 'Yes'
            if libisloaded('RobotDll')
                unloadlibrary('RobotDll');
            end
            rmpath(toolboxRoot);
            [isRemoved, msg, msgID] = rmdir(toolboxRoot,'s');
            if isRemoved
                fprintf('Previous version of ScorBot Toolbox removed successfully.\n');
            else
                fprintf('Failed to remove old ScorBot Toolbox folder:\n\t"%s"\n',toolboxRoot);
                fprintf(adminSolution);
                error(msgID,msg);
            end
        case 'No'
            fprintf('ScorBot Toolbox currently exists, installation cancelled.\n');
            return
        case 'Cancel'
            fprintf('Action cancelled.\n');
            return
        otherwise
            error('Unexpected response.');
    end
end

%% Create Scorbot Toolbox Path
[isDir,msg,msgID] = mkdir(toolboxRoot);
if isDir
    fprintf('ScorBot toolbox folder created successfully:\n\t"%s"\n',toolboxRoot);
else
    fprintf('Failed to create Scorbot Toolbox folder:\n\t"%s"\n',toolboxRoot);
    fprintf(adminSolution);
    error(msgID,msg);
end

%% Migrate toolbox folder contents
toolboxContent = 'ScorBotToolboxFunctions';
if ~isdir(toolboxContent)
    error(sprintf(...
        ['Change your working directory to the location of "installScorBotToolbox.m".\n',...
         '\n',...
         'If this problem persists:\n',...
         '\t(1) Unzip your original download of "ScorBotToolbox" into a new directory\n',...
         '\t(2) Open a new instance of MATLAB "as administrator"\n',...
         '\t\t(a) Locate MATLAB shortcut\n',...
         '\t\t(b) Right click\n',...
         '\t\t(c) Select "Run as administrator"\n',...
         '\t(3) Change your "working directory" to the location of "installScorBotToolbox.m"\n',...
         '\t(4) Enter "installScorBotToolbox" (without quotes) into the command window\n',...
         '\t(5) Press Enter.']));
end
files = dir(toolboxContent);
wb = waitbar(0,'Copying ScorBot Toolbox toolbox contents...');
n = numel(files);
fprintf('Copying ScorBot Toolbox contents:\n');
for i = 1:n
    % source file location
    source = fullfile(toolboxContent,files(i).name);
    % destination location
    destination = toolboxRoot;
    if files(i).isdir
        switch files(i).name
            case '.'
                %Ignore
            case '..'
                %Ignore
            otherwise
                fprintf('\t%s...',files(i).name);
                nDestination = fullfile(destination,files(i).name);
                [isDir,msg,msgID] = mkdir(nDestination);
                if isDir
                    [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                    if isCopy
                        fprintf('[Complete]\n');
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
                else
                    bin = msg == char(10);
                    msg(bin) = [];
                    bin = msg == char(13);
                    msg(bin) = [];
                    fprintf('[Failed: "%s"]\n',msg);
                end
        end
    else
        fprintf('\t%s...',files(i).name);
        if fullInstall
            [isCopy,msg,msgID] = copyfile(source,destination,'f');
        else
            isCopy = 0;
            % Ignore general files for simulation-only install
            if strcmp(files(i).name(end-3:end),'.dll')
                isCopy = -1;
            end
            if strcmp(files(i).name(end-1:end),'.h')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorGet')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorSet')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorGo')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorIs')
                isCopy = -1;
            end
            % Ignore specific files for simulation-only install
            ignoreMe = {...
                'ScorCreateVector.m',...
                'ScorDispError.m',...
                'ScorHome.m',...
                'ScorInit.m',...
                'ScorParseErrorCode.m',...
                'ScorSafeShutdown.m',...
                'ScorShutdownCallback.m',...
                'ScorWaitForMove.m'};
            ignoreMat = cell2mat( strfind(ignoreMe,files(i).name) );
            if ~isempty(ignoreMat)
                isCopy = -1;
            end
            if isCopy ~= -1
                [isCopy,msg,msgID] = copyfile(source,destination,'f');
            end
        end
        if isCopy == 1
            fprintf('[Complete]\n');
        elseif isCopy == -1
            fprintf('[Ignored]\n');
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
    end
    waitbar(i/n,wb);
end
set(wb,'Visible','off');

%% Save toolbox path
addpath(genpath(toolboxRoot),'-end');
savepath;
    
%% Migrate binary folder contents
if fullInstall
    win32binContent = 'ScorBotToolboxSupport';
    if ~isdir(win32binContent)
        error(sprintf(...
            ['Change your working directory to the location of "installScorBotToolbox.m".\n',...
            '\n',...
            'If this problem persists:\n',...
            '\t(1) Unzip your original download of "ScorBotToolbox" into a new directory\n',...
            '\t(2) Open a new instance of MATLAB "as administrator"\n',...
            '\t\t(a) Locate MATLAB shortcut\n',...
            '\t\t(b) Right click\n',...
            '\t\t(c) Select "Run as administrator"\n',...
            '\t(3) Change your "working directory" to the location of "installScorBotToolbox.m"\n',...
            '\t(4) Enter "installScorBotToolbox" (without quotes) into the command window\n',...
            '\t(5) Press Enter.']));
    end
    files = dir(win32binContent);
    waitbar(0,wb,'Copying win32bin contents...');
    set(wb,'Visible','on');
    n = numel(files);
    fprintf('Copying win32bin contents:\n');
    for i = 1:n
        % source file location
        source = fullfile(win32binContent,files(i).name);
        % destination location
        destination = win32binRoot;
        if files(i).isdir
            switch files(i).name
                case '.'
                    %Ignore
                case '..'
                    %Ignore
                otherwise
                    fprintf('\t%s...',files(i).name);
                    nDestination = fullfile(destination,files(i).name);
                    [isDir,msg,msgID] = mkdir(nDestination);
                    if isDir
                        [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                        if isCopy
                            fprintf('[Complete]\n');
                        else
                            bin = msg == char(10);
                            msg(bin) = [];
                            bin = msg == char(13);
                            msg(bin) = [];
                            fprintf('[Failed: "%s"]\n',msg);
                        end
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
            end
        else
            fprintf('\t%s...',files(i).name);
            [isCopy,msg,msgID] = copyfile(source,destination,'f');
            if isCopy
                fprintf('[Complete]\n');
            else
                bin = msg == char(10);
                msg(bin) = [];
                bin = msg == char(13);
                msg(bin) = [];
                fprintf('[Failed: "%s"]\n',msg);
            end
        end
        waitbar(i/n,wb);
    end
    close(wb);
    drawnow
end

%% Rehash toolbox cache
fprintf('Rehashing Toolbox Cache...');
rehash TOOLBOXCACHE
fprintf('[Complete]\n');

end

function ToolboxUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sToolboxVer',toolboxName) );
installToolbox = str2func( sprintf('install%sToolbox',toolboxName) );

%% Check current version
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
fprintf('Downloading the %s Toolbox...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    fnames = unzip(url,pname);
    fprintf('SUCCESS\n');
    confirm = true;
catch
    confirm = false;
end

%% Check for successful download
if ~confirm
    error('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%sToolbox.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install ScorBot Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
