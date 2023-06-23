function confirm = ScorSimSetXYZPR(varargin)
% SCORSIMSETXYZPR set the ScorBot visualization to the specified 5-element
% task configuration.
%   SCORSIMSETXYZPR(scorSim,XYZPR) set the ScorBot visualization specified 
%   by "scorSim" to the specified 5-element task configuration "XYZPR".
%       XYZPR - 5-element vector containing end-effector position and
%       orientation.
%           XYZPR(1) - end-effector x-position in millimeters
%           XYZPR(2) - end-effector y-position in millimeters
%           XYZPR(3) - end-effector z-position in millimeters
%           XYZPR(4) - end-effector pitch in radians
%           XYZPR(5) - end-effector roll in radians
%
%   SCORSIMSETXYZPR(...,'MoveType',mode) specifies whether the movement is
%   linear in task space or linear in joint space.
%       Mode: {['LinearTask'] 'LinearJoint' 'Instant'}

%   confirm = SCORSIMSETXYZPR(___) returns 1 if successful and 0 otherwise.
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also ScorSimInit ScorSimSetDeltaXYZPR ScorSimSetBSEPR
%
%   M. Kutzer, 14Aug2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   23Oct2015 - Account for elbow-up and elbow-down solutions using current
%               simulation configuration.
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated to add "confirm" output
%   01Sep2016 - Updated to include BSEPR/XYZPR pitch distinction
%   20Aug2020 - Added 'MoveType' for interpolation and better aligned 
%               documentation with ScorSet* equivalent function
%   23Jun2023 - Added reshape(XYZPR,1,5)

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,XYZPR);" to execute this function.'],mfilename)
end
% Check scorSim
if nargin >= 1
    scorSim = varargin{1};
    if ~isScorSim(scorSim)
        if isempty(inputname(1))
            txt = 'The specified input';
        else
            txt = sprintf('"%s"',inputname(1));
        end
        error('ScorSet:BadSimObj',...
            ['%s is not a valid ScorSim object.',...
            '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
            '\n\t-> and "%s(scorSim,XYZPR);" to execute this function.'],txt,mfilename);
    end
end
% No XYZPR
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoXYZPR',...
        ['End-effector position and orientation must be specified.',...
        '\n\t-> Use "%s(%s,XYZPR)".'],mfilename,txt);
end
% Check XYZPR
if nargin >= 2
    XYZPR = varargin{2};
    if ~isnumeric(XYZPR) || numel(XYZPR) ~= 5
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadXYZPR',...
            ['End-effector position and orientation must be specified as a 5-element numeric array.',...
            '\n\t-> Use "%s(%s,[X,Y,Z,Pitch,Roll])".'],mfilename,txt);
    end

    % Ensure XYZPR is a row-vector
    XYZPR = reshape(XYZPR,1,5);
end
% Set default move type
mType = 'LinearTask';
mName = mfilename;
if numel(mName) >= 11, vName = mName(11:end); else, vName = 'q'; end
% Check property designator
if nargin >= 3
    pType = varargin{3};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSimSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearJoint'')"',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearTask'')", or',....
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''Instant'')".'],...
            pType,mName,vName,mName,vName,mName,vName);
    end
    if nargin < 4
        error('ScorSimSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearJoint'')"',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearTask'')", or',....
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''Instant'')".'],...
            pType,mName,vName,mName,vName,mName,vName);
    end
end
% Check property value
if nargin >= 4
    mType = varargin{4};
    switch lower(mType)
        case 'linearjoint'
            % Linear move in joint space
        case 'lineartask'
            % Linear move in task space
	case 'instant'
            % Instant move 
        otherwise
            error('ScorSimSet:BadPropVal',...
                ['Unexpected property value: "%s".',...
                '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearJoint'')"',...
                '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearTask'')", or',....
                '\n\t-> Use "%s(scorSim,%s,''MoveType'',''Instant'')".'],...
                mType,mName,vName,mName,vName,mName,vName);
    end
end
% Check for too many inputs
if nargin > 4
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Check for elbow-up or elbow-down using current simulation configuration
BSEPR = ScorSimGetBSEPR(scorSim);
E = BSEPR(3);
if E > 0
    % Elbow-down
    ElbowStr = 'ElbowDownSolution';
else
    % Elbow-up
    ElbowStr = 'ElbowUpSolution';
end

%% Move simulation
BSEPR = ScorXYZPR2BSEPR(XYZPR,ElbowStr);
if ~isempty(BSEPR)
    confirm = ScorSimSetBSEPR(scorSim,BSEPR,'MoveType',mType);
else
    warning('Specified pose may be unreachable.');
    confirm = false;
end