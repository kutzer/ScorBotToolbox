function confirm = ScorSimSetDeltaPose(varargin)
% SCORSIMSETDELTAPOSE set the current end-effector pose of the ScorBot
% visualization relative to the current end-effector pose.
%   SCORSIMSETDELTAPOSE(scorSim,dH) moves the end-effector of the ScorBot 
%   visualization to a specified 4x4 homogeneous transformation 
%   representing the end-effector pose of ScorBot relative to the current 
%   end-effector pose.
%
%   SCORSIMSETDELTAPOSE(...,'MoveType',mode) specifies whether the movement
%   is linear in task space or linear in joint space.
%       Mode: {['LinearTask'] 'LinearJoint' 'Instant'}
%
%   confirm = SCORSIMSETDELTAPOSE(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also ScorSimInit ScorSimSetDeltaBSEPR ScorSimSetDeltaXYZPR 
%
%   M. Kutzer, 30Dec2015, USNA

% Updates
%   30Dec2015 - Updated to add "confirm" output
%   20Aug2020 - Added 'MoveType' for interpolation and better aligned 
%               documentation with ScorSet* equivalent function

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,DeltaH);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,DeltaH);" to execute this function.'],txt,mfilename);
    end
end
% No Delta Pose
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoPose',...
        ['Change in end-effector pose must be specified.',...
        '\n\t-> Use "%s(%s,DeltaH)".'],mfilename,txt);
end
% Check Delta Pose
if nargin >= 2
    dH = varargin{2};
    if size(dH,1) ~= 4 || size(dH,2) ~= 4 || ~isSE(dH)
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadPose',...
            ['Change in end-effector pose must be specified as a valid 4x4 element of SE(3).',...
            '\n\t-> Use "%s(%s,DeltaH)".'],mfilename,txt);
    end
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

%% Move simulation
H = ScorSimGetPose(scorSim);
H = H*dH;
confirm = ScorSimSetPose(scorSim,H,pType,mType);