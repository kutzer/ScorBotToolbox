function ScorErrorLogWrite(varargin)
% SCORERRORLOGWRITE writes a line to the error log providing information
% related to current errors and/or movement commands.
%   SCORERRORLOGWRITE(sError) writes a line containing the date/time, error
%   code, movement flag, and the current BSEPR and grip value of the 
%   ScorBot. The movement flag for a controller thrown error is as follows:
%       mFlag = 0 for an error state
%
%       Error Log Text:
%           '$datetime!sError,mFlag,B,S,E,P,R,grip\r\n'
%
%   SCORERRORLOGWRITE(isDelta,MoveType,BSEPR) writes a line containing the 
%   date/time, zero error code, a movement flag followed by the commanded 
%   BSEPR value and current grip value. Movement flags are defined as 
%   follows:
%       mFlag = 1 for linear joint absolute moves,
%       mFlag = 2 for linear task moves,
%       mFlag = 3 for relative linear joint moves,
%       mFlag = 4 for relative task moves,
%
%       Error Log Text:
%           '$datetime!0,mFlag,B,S,E,P,R,grip\r\n'
%
%   SCORERRORLOGWRITE('GripCommand',grip) writes a line containing the 
%   date/time, zero error code, movement flag, the current BSEPR, and the 
%   desired grip value. The movement flag for a controller thrown error is 
%   as follows:
%       mFlag = 5 for an error state
%
%       Error Log Text:
%           '$datetime!0,mFlag,B,S,E,P,R,grip\r\n'
%
%   M. Kutzer, USNA, 28Sep2018

% Updates:
%   05Oct2018 - Updated to remove recurring lines.

%% Define persistent last line variable
% TODO - populate lastLine and compare (post date stamp) to the new line
% being written. If they are the same, do not write the line. 
persistent oldLine

%% Define library alias
% TODO - Create ScorLibraryAlias or similar function to be used here and
% with ScorIsReady. Two instances of a fixed value may become a problem.
libname = 'RobotDll';

%% Get error log file ID
fileID = ScorErrorLogGetFileID;

%% Check for valid file ID
if isempty( fopen(fileID) )
    % Consider warning the user if no error log is available.
    return
end

%% Get useful information
% Initialize write file flag
writeFile = false;

% Get date/time
date_str = datestr(now);

% Define gripper state
grip = GetGripper_NoCheck(libname);

% Parse information if error code is given
if nargin == 1
    % Set error code
    sError = varargin{1};
    % Define movement flag
    mFlag = 0;
    % Define BSEPR
    BSEPR = GetBSEPR_NoCheck(libname);
    % Set write file flag
    writeFile = true;
end

% Parse grip command
if nargin == 2
    % Set error code
    sError = 0;
    % Parse inputs
    MoveType = varargin{1};
    grip = varargin{2};
    % Define BSEPR
    BSEPR = GetBSEPR_NoCheck(libname);
    % Define movement flag
    switch lower(MoveType)
        case lower( 'GripCommand' )
            mFlag = 5;
        otherwise
            error('ScorErrorLog:BadMoveType',...
                '"%s" is not a known movement type',MoveType);
    end
    % Set write file flag
    writeFile = true;
end

% Parse information if a movement command is given
if nargin == 3
    % Set error code
    sError = 0;
    % Parse inputs
    isDelta  = varargin{1};
    MoveType = varargin{2};
    BSEPR    = varargin{3};
    % Define movement flag
    switch lower(MoveType)
        case lower( 'LinearJoint' )
            mFlag = 1;
        case lower( 'LinearTask' )
            mFlag = 2;
        otherwise
            error('ScorErrorLog:BadMoveType',...
                '"%s" is not a known movement type',MoveType);
    end
    % Update movement flag
    if isDelta
        mFlag = mFlag + 2;
    end
    % Set write file flag
    writeFile = true;
end

%% Define error states to ignore
sIgnore = [...
    905;... % Given point is not in the workspace of the robot
    946;... % Position is not in the Cartesian workspace!
    962;... % Resultant point is not in the workspace
    970;... % Teach Pendant switched to Teach mode
    971];   % Teach Pendant switched to Auto mode

if sum( sError == sIgnore )
    % Do not write error
    return
end

%% Write file 
if writeFile
    % '$datetime!sError,mFlag,B,S,E,P,R,grip\r\n'
    newLine = sprintf('$%s!%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.1f\r\n',date_str,sError,mFlag,BSEPR,grip);
    % Check if line is a repeat error
    writeLine = true;
    if sError ~= 0
        oldIDX = strfind(oldLine,'!');
        newIDX = strfind(newLine,'!');
        if ~isempty(oldIDX) && ~isempty(newIDX)
            if isequal( oldLine(oldIDX:end),newLine(newIDX:end) )
                writeLine = false;
            end
        end
    end
    % Write line
    if writeLine
        fprintf(fileID,'%s',newLine);
        oldLine = newLine;
    end
else
    warning('Unknown input combination.');
end

end % END Function

% -------------------------------------------------------------------------
% --- Internal Function(s) ------------------------------------------------
% -------------------------------------------------------------------------

function BSEPR = GetBSEPR_NoCheck(libname)
% NOTE - this is taken directly from ScorGetBSEPR. This avoids possible
% conflicts with ScorIsReady writing to the error log.

% Initialize BSEPR
BSEPR = NaN(1,5);

% Define variables for library function call
B = 0.0; % end-effector base angle in 1/1000's of a degree
S = 0.0; % end-effector shoulder angle in 1/1000's of a degree
E = 0.0; % end-effector elbow angle in 1/1000's of a degree
P = 0.0; % end-effector wrist pitch in 1/1000's of a degree
R = 0.0; % end-effector wrist roll in 1/1000's of a degree

% Get BSEPR values 
try
    [confirm,B,S,E,P,R]=calllib(libname,'RGetBSEPR',B,S,E,P,R);
    if confirm
        BSEPR(1) =  deg2rad(B*1e-3); % end-effector base angle in radians
        BSEPR(2) = -deg2rad(S*1e-3); % end-effector shoulder angle in radians (sign change to match teach pendant)
        BSEPR(3) = -deg2rad(E*1e-3); % end-effector elbow angle in radians (sign change to match teach pendant)
        BSEPR(4) = -deg2rad(P*1e-3); % end-effector wrist pitch in radians (sign change to match teach pendant)
        BSEPR(5) =  deg2rad(R*1e-3); % end-effector wrist roll in radians
    else
        % Do nothing
    end
catch
    % Do nothing
end
end

function grip = GetGripper_NoCheck(libname)
% NOTE - this is taken directly from ScorGetGripper. This avoids possible
% conflicts with ScorIsReady writing to the error log.

% Get gripper state
grip = calllib(libname,'RGetJaw');

end
