function confirm = ScorSetPose(varargin)
% SCORSETPOSE moves the ScorBot to a designated end-effector pose.
%   SCORSETPOSE(H) moves the ScorBot end-effector to a specified 4x4 
%   homogeneous transformation representing the end-effector pose of 
%   ScorBot relative to the base frame.
%
%   SCORSETPOSE(...,'MoveType',mode) specifies whether the movement is
%   linear in task space or linear in joint space.
%       Mode: {['LinearTask'] 'LinearJoint'}
%
%   confirm = SCORSETPOSE(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorPose2XYZPR ScorSetXYZPR
%
%   M. Kutzer, 14Aug2015, USNA

% Updates
%   23Dec2015 - Updated to clarify errors.
%   30Dec2015 - Updated help documentation.
%   15Sep2016 - Updated to correct default move type.

%% Set global for ScorSetUndo
global ScorSetUndoBSEPR

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors.

% Check for zero inputs
if nargin < 1
    error('ScorSet:NoPose',...
        ['End-effector pose must be specified.',...
        '\n\t-> Use "ScorSetPose(H)".']);
end
% Check Pose
if nargin >= 1
    H = varargin{1};
    if size(H,1) ~= 4 || size(H,2) ~= 4 || ~isSE(H)
        error('ScorSet:BadPose',...
            ['End-effector pose must be specified as a valid 4x4 element of SE(3).',...
            '\n\t-> Use "ScorSetPose(H)".']);
    end
end
% Check property designator
if nargin >= 2
    pType = varargin{2};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "ScorSetPose(H,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetPose(H,''MoveType'',''LinearTask'')".'],pType);
    end
    if nargin < 3
        error('ScorSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "ScorSetPose(H,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetPose(H,''MoveType'',''LinearTask'')".'],pType);
    end
end
% Check property value
mType = 'LinearTask';
if nargin >= 3
    mType = varargin{3};
    switch lower(mType)
        case 'linearjoint'
            % Linear move in joint space
        case 'lineartask'
            % Linear move in task space
        otherwise
            error('ScorSet:BadPropVal',...
                ['Unexpected property value: "%s".',...
                '\n\t-> Use "ScorSetPose(H,''MoveType'',''LinearJoint'')" or',...
                '\n\t-> Use "ScorSetPose(H,''MoveType'',''LinearTask'')".'],mType);
    end
end
% Check for too many inputs
if nargin > 3
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Get XYZPR
XYZPR = ScorPose2XYZPR(H);
if isempty(XYZPR)
    confirm = false;
    warning('Specified pose may be unreachable.');
    return
end

%% Set the ScorSetUndo waypoint
% TODO - add error checking
ScorSetUndoBSEPR = ScorGetBSEPR;

%% Move Arm
confirm = ScorSetXYZPR(XYZPR,'MoveType',mType);