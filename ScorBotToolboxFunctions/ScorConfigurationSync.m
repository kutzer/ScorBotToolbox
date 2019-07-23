function ScorConfigurationSync
% SCORCONFIGURATIONSYNC syncronizes the ScorBot configuration and library
% files created by the native Intelitek ScorBot interface, SCORBASE.
%
%   M. Kutzer, 23Jul2019, USNA

%% Define source and destination
% TODO - This code does not account for hard drive names other than "C:"
source = 'C:\Intelitek\SCORBASE\BIN';
if ispc
    switch computer
        case 'PCWIN'
            % 32-bit
            destination = fullfile(matlabroot,'bin','win32');
        case 'PCWIN64'
            % 64-bit
            % TODO - This code does not account for hard drive names other than "C:"
            destination = 'C:\Program Files (x86)\USNA\ScorbotServer';
        otherwise
            fprintf(2,'Windows 32-bit and 64-bit OS only.');
            return
    end
else
    fprintf(2,'Windows 32-bit and 64-bit OS only.');
    return
end

%% Check if source and destination exist
if ~isdir(source)
    % TODO - allow the user to find the SCORBASE BIN folder
    fprintf(2,'SCORBASE is not in the expected location.');
    return
end

if ~isdir(destination)
    % TODO - allow the user to find the ScorbotServer folder location
    frintf(2,'ScorbotServer is not in the expected location.');
    return
end

%% Get a list of all files in the destination directory
% NOTE: We are only copying files from the source that currently exist in
%       the destination directory.
files = dir(destination);

wb = waitbar(0,'Copying library and configuration file contents...');
set(wb,'Visible','on');

n = numel(files);
fprintf('Copying library and configuration file contents:\n');
for i = 1:n
    % source file/folder
    cloneFolderContents(files(i),source,destination,0);
    waitbar(i/n,wb);
end
close(wb);
drawnow

confirm = true;

end

function cloneFolderContents(file,source,destination,nTabs)

% DEBUG
%fprintf(2,'       FILE: %s\n',file.name);
%fprintf(2,'     SOURCE: %s\n',source);
%fprintf(2,'DESTINATION: %s\n',destination);

% Create taps
tabsFile = repmat( sprintf('\t'),1,nTabs );
%tabsFolder = repmat( sprintf('\t'),1,nTabs+1 );

% Define source/destination including new file/folder name
nSource = fullfile(source,file.name);
nDestination = fullfile(destination,file.name);

% Check file/folder
if file.isdir
    switch file.name
        case '.'
            %Ignore
        case '..'
            %Ignore
        otherwise
            fprintf('%s%s...\n',tabsFile,file.name);
            
            files = dir(nDestination);
            n = numel(files);
            for i = 1:n
                % source file/folder
                cloneFolderContents(files(i),nSource,nDestination,nTabs+1);
            end
    end
else
    if exist( nSource,'file' ) == 2
        
        switch file.name
            case 'USBC.dll'
                srcFILE = dir( nSource );
                dstFILE = dir( nDestination );
                
                % Check if destination version is newer
                if dstFILE.datenum > srcFILE.datenum
                    % Old DLL, Warn User
                    fprintf(2,...
                        [' -> Existing version of USBC.dll is newer than the version used by SCORBASE.\n',...
                        '\t\tSCORBASE DLL Date: %s\n',...
                        '\t\t Toolbox DLL Date: %s\n',...
                        '\tConsider downloading and installing the latest version of SCORBASE:\n',...
                        '\t\thttp://www.intelitekdownloads.com/Software/Robotics/ER-4u/\n'],...
                        srcFILE.date,dstFILE.date);
                    replaceFile = false;
                    replaceINI = false;
                elseif dstFILE.datenum == srcFILE.datenum
                    % Same DLL (this is good)
                    fprintf(2,' -> Yay! The current version of USBC.dll appears up-to-date.\n');
                    replaceFile = false;
                    replaceINI = true;
                else
                    fprintf(2,' -> The current version of USBC.dll appears to be out-of-date.\n');
                    % TODO - consider prompting the user
                    replaceFile = true;
                    replaceINI = true;
                end
                
                if replaceINI
                    % REPLACE INI FILE
                    fprintf('%s%s...',tabsFile,'USBC.INI');
                    iniSource = fullfile(source,'USBC.INI');
                    [isCopy,msg,msgID] = copyfile(iniSource,destination,'f');
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
                
            case 'USBC.INI'
                % SKIP (including message)
                replaceFile = false;
                return
            otherwise
                replaceFile = true;
        end
        
        fprintf('%s%s...',tabsFile,file.name);
        if replaceFile
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
        else
            fprintf('[Skipped]\n');
        end
    else
        fprintf('%s%s...',tabsFile,file.name);
        fprintf('[Skipped, "Source file does not exist"]\n');
        %fprintf('%s\t     Source: %s\n',tabsFile,nSource);
        %fprintf('%s\tDestination: %s\n',tabsFile,destination);
    end
end

end