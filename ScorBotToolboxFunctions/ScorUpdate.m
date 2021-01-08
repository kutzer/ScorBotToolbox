function ScorUpdate(varargin)
% SCORUPDATE download and update the ScorBot Toolbox. 
%
%   M. Kutzer 26Aug2015, USNA

% Updates
%   27Aug2015 - Updated to include check for multiple the newest update on
%               MATLAB Central (currently looks 25 versions ahead).
%   03Sep2015 - Updated to download from GitHub
%   29Sep2015 - Updated to include simulation test and istall for operating
%               systems outside of Windows 32-bit (for simulation only).
%   04Oct2015 - Updated hardware and simulation test scripts.
%   25Aug2016 - Updated to allow for skipped hardware/simulation tests.
%   07Mar2018 - Updated to include try/catch for required toolbox
%               installations.
%   15Mar2018 - Updated to include msgbox warning when download fails.
%   08Jan2021 - Updated install procedure

% TODO - Find a location for "ScorBotToolbox Example SCRIPTS"
% TODO - update function for general operation

%% Check inputs
% TODO - cleanup and document this capability
narginchk(0,1);
hardwarechk = true;
if nargin >= 1
    uMode = varargin{1};
    switch lower(uMode)
        case 'slow'
            hardwarechk = true;
        case 'fast'
            hardwarechk = false;
        otherwise
            warning('Mode must be specified as either "Slow" or "Fast"');
            hardwarechk = true;
    end
end
            
%% Check current version
try
    A = ScorVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Define Toolbox name
toolboxName = 'ScorBot';

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

%% Install ScorBot Toolbox
installScorBotToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

%% Test functionality
if hardwarechk
    fprintf('\n');
    % ScorBot hardware
    if ispc
        switch computer
            case 'PCWIN'
                % Test hardware 
                fprintf('Testing ScorBot hardware...\n')
                try
                    SCRIPT_BasicHardwareTest;
                    fprintf('SUCCESS\n');
                catch ME
                    fprintf(2,'FAILED\n');
                    fprintf(2,'ERROR MESSAGE:\n\t%s\n',ME.message);
                end
        end
    end
    % ScorBot simulation
    fprintf('Testing ScorBot simulation...\n');
    try
        SCRIPT_BasicSimulationTest;
        fprintf('SUCCESS\n');
    catch ME
        fprintf(2,'FAILED\n');
        fprintf(2,'ERROR MESSAGE:\n\t%s\n',ME.message);
    end
else
    fprintf('Skipping hardware and simulation check.\n');
end

end
