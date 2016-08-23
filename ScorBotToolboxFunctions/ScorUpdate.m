function ScorUpdate
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

% TODO - Find a location for "ScorBotToolbox Example SCRIPTS"
% TODO - update function for general operation

%% Check current version
A = ScorVer;

%% Setup temporary file directory
fprintf('Downloading the ScorBot Toolbox...');
tmpFolder = 'ScorBotToolbox';
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = 'https://github.com/kutzer/ScorBotToolbox/archive/master.zip';
try
    fnames = unzip(url,pname);
    fprintf('SUCCESS\n');
    confirm = true;
catch
    confirm = false;
    return
end

%% Check for successful download
if ~confirm
    error('Failed to download updated version of ScorBot Toolbox.');
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

%% Test ScorBot hardware functionality
if ispc
    switch computer
        case 'PCWIN'
            SCRIPT_BasicHardwareTest;
    end
end

%% Test simulation functionality
SCRIPT_BasicSimulationTest;

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
