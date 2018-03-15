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
%
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
A = ScorVer;

%% Setup temporary file directory
fprintf('Downloading the ScorBot Toolbox...');
tmpFolder = 'ScorBotToolbox';
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
toolboxName = 'ScorBot';

url = 'https://github.com/kutzer/ScorBotToolbox/archive/master.zip';
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
        tmpFname = sprintf('%sToolbox-master.zip',toolboxName);
        urlwrite(url,fullfile(pname,tmpFname));
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
    sprintf('Manually download the %s Toolbox using the following link:\n',toolboxName),...
    sprintf('\n'),...
    sprintf('%s\n',url),...
    sprintf('\n'),...
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
install_pos = strfind(fnames,'installScorBotToolbox.m');
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install ScorBot Toolbox
installScorBotToolbox(true);

%% Test functionality
if hardwarechk
    % ScorBot hardware
    if ispc
        switch computer
            case 'PCWIN'
                SCRIPT_BasicHardwareTest;
        end
    end
    % ScorBot simulation
    SCRIPT_BasicSimulationTest;
else
    fprintf('Skipping hardware and simulation check.\n');
end
%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
