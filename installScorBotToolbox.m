function installScorBotToolbox(replaceExisting,skipAdmin)
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
%   M. Kutzer, 10Aug2015, USNA

% Updates
%   26Aug2015 - Updated to include replaceExisting to support
%               "ScorUpdate.m"
%   26Aug2015 - Updated to include rehash of toolbox cache
%   26Aug2015 - Updated to include drawnow before rehash of toolbox cache
%   08Sep2016 - Updated to correct questdlg default and title
%   07Mar2018 - Updated to include try/catch for required toolbox
%               installations.
%   15Mar2018 - Updated to include msgbox warning when download fails.
%   16Jul2019 - Updated for 32-bit and 64-bit support
%   22Jul2019 - Updated to copy new library and configuration files to the 
%               ScorbotServer folder.
%   24Jul2019 - Updated to account extended list of files to ignore for 
%               simulation-only install
%   25Aug2020 - Updated to default replace prompt selection to "Yes"
%   25Aug2020 - Updated message associated with moved install file
%   08Jan2021 - Updated ToolboxUpdate
%   08Jan2021 - Corrected questdlg
%   08Jan2021 - Corrected WRC_MATLABCameraSupport install
%   08Mar2021 - Updated to include patch toolbox install

% TODO - Allow users to create a local version if admin rights are not
% possible.

global wb

%% Install/Update required toolboxes
ToolboxUpdate('Transformation');
ToolboxUpdate('Geometry');
ToolboxUpdate('Plotting');
ToolboxUpdate('Patch');
SupportUpdate('WRC_MATLABCameraSupport');

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
            % Check is a MEX C compiler is installed
            cc = mex.getCompilerConfigurations('C');
            if isempty(cc)
                error('No C compiler found. Please use supportPackageInstaller to install a C compiler for this version of MATLAB.');
            end
            switch cc.Name
                case 'lcc-win32'
                    fprintf('Mex compiler: "%s"\n',cc.Name);
                otherwise
                    fprintf('Unexpected Mex compiler: "%s"\n',cc.Name);
            end
            osbits = 32;
            fullInstall = true;
        case 'PCWIN64'
            fprintf('64-bit Windows Operating System detected.\n');
            osbits = 64;
            fullInstall = true;
        otherwise
            warning('Interaction with the ScorBot hardware requires a 32-bit Windows OS.');
            choice = questdlg(...
                sprintf(...
                    ['Full installation of the ScorBot Toolbox requires\n',...
                    'a 32-bit or 64-bit Windows OS.\n',...
                    '\n',...
                    '  - Installing on this OS will only enable\n',...
                    '    simulation capabilities.\n',...
                    '\n',...
                    'Would you like to install the simulation tools?']...
                 ),...
                 'Install Simulation Tools',...
                 'Yes','No','Cancel','Yes');
            
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
        'Install Simulation Tools','Yes','No','Cancel','Yes');    
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

%% Check for 32-bit or 64-bit bin directory (if applicable)
if fullInstall
    switch osbits
        case 32
            % 32-bit Windows install
            win32binRoot = fullfile(matlabroot,'bin','win32');
            
            isWin32bin = exist(win32binRoot,'file');
            if isWin32bin == 7
                %bin\win32 exists as expected
            else
                error('MATLAB root does not contain the directory:\n\t"%s"\n',isWin32bin);
            end
        case 64
            % 64-bit Windows install
            % No action required
        otherwise
            error('OSBITS variable not set to known value.');
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
            'Replace Existing ScorBot Toolbox','Yes','No','Cancel','Yes');
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
            % Remove folders from MATLAB path
            rmpath(toolboxRoot);
            files = dir(toolboxRoot);
            for i = 1:numel(files)
                if files(i).isdir
                    switch files(i).name
                        case '.'
                            % Skip
                        case '..'
                            % Skip
                        otherwise
                            rmpath( fullfile(toolboxRoot,files(i).name) );
                    end
                end
            end
            % Remove folder
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
        ['!!! Somebody moved "installScorBotToolbox.m" from its original location? !!!\n',...
         '\n',...
        'Change your working directory to the *original unzipped/extracted* location of "installScorBotToolbox.m".\n',...
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
            isCopy = 0;
            switch osbits
                case 32
                    % 32-bit Windows install
                    % -> Ignore specific files for 64-bit install
                    ignoreMe = {...
                        'ScorServerCmd.m'};
                    ignoreMat = cell2mat( strfind(ignoreMe,files(i).name) );
                    if ~isempty(ignoreMat)
                        isCopy = -1;
                    end
                case 64
                    % 64-bit Windows install
                    % -> Ignore dll files for 32-bit install
                    if strcmp(files(i).name(end-3:end),'.dll')
                        isCopy = -1;
                    end
                    % -> Ignore header files for 32-bit install
                    if strcmp(files(i).name(end-1:end),'.h')
                        isCopy = -1;
                    end
                otherwise
                    error('OSBITS variable not set to known value.');
            end
            if isCopy ~= -1
                [isCopy,msg,msgID] = copyfile(source,destination,'f');
            end
        else
            isCopy = 0;
            % Ignore general files for simulation-only install
            % -> Ignore dll files
            if strcmp(files(i).name(end-3:end),'.dll')
                isCopy = -1;
            end
            % -> Ignore header files
            if strcmp(files(i).name(end-1:end),'.h')
                isCopy = -1;
            end
            % -> Ignore ScorGet* commands 
            if strfind(files(i).name,'ScorGet')
                isCopy = -1;
            end
            % -> Ignore ScorSet* commands
            if strfind(files(i).name,'ScorSet')
                isCopy = -1;
            end
            % -> Ignore ScorGo* commands (ScorGoHome, ScorGotoPoint)
            if strfind(files(i).name,'ScorGo')
                isCopy = -1;
            end
            % -> Ignore ScorIs* commands
            if strfind(files(i).name,'ScorIs')
                isCopy = -1;
            end
            % -> Ignore ScorError* commands
            if strfind(files(i).name,'ScorError')
                isCopy = -1;
            end
            % -> Ignore ScorInit* commands
            if strfind(files(i).name,'ScorInit')
                isCopy = -1;
            end
            % Ignore specific files for simulation-only install
            ignoreMe = {...
                'ScorCreateVector.m',...
                'ScorDispError.m',...
                'ScorParseErrorCode.m',...
                'ScorHome.m',...
                'ScorParseErrorCode.m',...
                'ScorSafeShutdown.m',...
                'ScorShutdownCallback.m',...
                'ScorWaitForMove.m',...
                'ScorCallLib.m',...
                'ScorServerCmd.m',...
                'ScorConfigurationSync.m',...
                'ScorLogout.m',...
                'ScorWarmup.m'};
            ignoreMat = cell2mat( strfind(ignoreMe,files(i).name) );
            if ~isempty(ignoreMat)
                isCopy = -1;
            end
            % Copy file
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
    
%% Migrate binary folder contents or install server components
if fullInstall
    switch osbits
        case 32
            % 32-bit Windows install
            migrateBinaryContent(win32binRoot);
            % Update binary content
            ScorConfigurationSync;
        case 64
            % 64-bit Windows install
            % 64-bit requires:
            %   Install_ScorbotServer.msi
            %   Authorize_ScorbotServer.bat
            
            % Define server destination
            destination = 'C:\Program Files (x86)\USNA\ScorbotServer';
            
            % Remove existing verion of server
            exe_name = 'ScorbotServer.exe';
            if exist(fullfile(destination,exe_name),'file') == 2
                fprintf('Uninstalling prior version of ScorbotServer...');
                % msiexec /x filename.msi /passive
                [status,cmdout] = system('msiexec /x Install_ScorbotServer.msi /passive');
                fprintf('[Complete]\n');
            end
            
            % Install server
            fprintf('Installing ScorbotServer.msi...');
            %[status,cmdout] = system('Install_ScorbotServer.msi');
            [status,cmdout] = system('msiexec /i Install_ScorbotServer.msi ALLUSERS=1 /passive');
            % TODO - use status info etc. to check if this is actually
            % complete
            fprintf('[Complete]\n');
            
            % Update binary content
            migrateBinaryContent(destination);
            % Update binary content
            ScorConfigurationSync;
            
            % Authorize server
            fprintf('Authorizing server...');
            [status,cmdout] = system('Authorize_ScorbotServer.bat');
            % TODO - use status info etc. to check if this is actually 
            % complete
            fprintf('[Complete]\n');
        otherwise
            error('OSBITS variable not set to known value.');
    end

end

%% Rehash toolbox cache
fprintf('Rehashing Toolbox Cache...');
rehash TOOLBOXCACHE
fprintf('[Complete]\n');

end

function migrateBinaryContent(destination)

global wb

source = 'ScorBotToolboxSupport';
if ~isdir(source)
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
files = dir(source);
waitbar(0,wb,'Copying library and configuration file contents...');
set(wb,'Visible','on');
n = numel(files);
fprintf('Copying library and configuration file contents:\n');
for i = 1:n
    % source file location
    nSource = fullfile(source,files(i).name);
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
                    [isCopy,msg,msgID] = copyfile(nSource,nDestination,'f');
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
        [isCopy,msg,msgID] = copyfile(nSource,destination,'f');
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
if isfolder(pname)
    % Remove existing directory
    [ok,msg] = rmdir(pname,'s');
end
% Create new directory
[ok,msg] = mkdir(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    %fnames = unzip(url,pname);
    %urlwrite(url,fullfile(pname,tmpFname));
    tmpFname = sprintf('%sToolbox-master.zip',toolboxName);
    websave(fullfile(pname,tmpFname),url);
    fnames = unzip(fullfile(pname,tmpFname),pname);
    delete(fullfile(pname,tmpFname));
    
    fprintf('SUCCESS\n');
    confirm = true;
catch ME
    fprintf('FAILED\n');
    confirm = false;
    fprintf(2,'ERROR MESSAGE:\n\t%s\n',ME.message);
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s Toolbox using the following link:\n',toolboxName),...
    newline,...
    sprintf('%s\n',url),...
    newline,...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%sToolbox"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%sToolbox.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%sToolbox" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];
        
if ~confirm
    warning('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
	
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s Toolbox',toolboxName),'warn');
    return
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%sToolbox.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install Toolbox
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

function SupportUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sVer',toolboxName) );
installToolbox = str2func( sprintf('install%s',toolboxName) );

%% Check current version
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
fprintf('Downloading the %s ...',toolboxName);
tmpFolder = sprintf('%s',toolboxName);
pname = fullfile(tempdir,tmpFolder);
if isfolder(pname)
    % Remove existing directory
    [ok,msg] = rmdir(pname,'s');
end
% Create new directory
[ok,msg] = mkdir(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%s/archive/master.zip',toolboxName);
try
    % Original download/unzip method using "unzip"
    fnames = unzip(url,pname);
    
    fprintf('SUCCESS\n');
    confirm = true;
catch
    try
        % Alternative download method using "urlwrite"
        % - This method is flagged as not recommended in the MATLAB
        % documentation.
        % TODO - Consider an alternative to urlwrite.
        tmpFname = sprintf('%s-master.zip',toolboxName);
        %urlwrite(url,fullfile(pname,tmpFname));
        websave(fullfile(pname,tmpFname),url);
        fnames = unzip(fullfile(pname,tmpFname),pname);
        delete(fullfile(pname,tmpFname));
        
        fprintf('SUCCESS\n');
        confirm = true;
    catch
        fprintf('FAILED\n');
        confirm = false;
    end
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s  using the following link:\n',toolboxName),...
    sprintf('\n'),...
    sprintf('%s\n',url),...
    sprintf('\n'),...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%s"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%s.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%s" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];
        
if ~confirm
    warning('Install:FailedDownload','Failed to download updated version of %s .',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
    
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s ',toolboxName),'warn');
    return
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%s.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install ScorBot 
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
