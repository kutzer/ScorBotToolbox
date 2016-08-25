function confirm = ScorSetXYZPR(varargin)
% SCORSETXYZPR moves the ScorBot end-effector to a specified x,y,z 
% position, and pitch and roll orientation.
%   SCORSETXYZPR(XYZPR) moves the ScorBot to the 5-element task-space 
%   vector containing the end-effector x,y,z position, and end-effector 
%   pitch and roll orientation.
%       XYZPR - 5-element vector containing end-effector position and
%       orientation.
%           XYZPR(1) - end-effector x-position in millimeters
%           XYZPR(2) - end-effector y-position in millimeters
%           XYZPR(3) - end-effector z-position in millimeters
%           XYZPR(4) - end-effector pitch in radians
%           XYZPR(5) - end-effector roll in radians
%
%   SCORSETXYZPR(...,'MoveType',mode) specifies whether the movement is
%   linear in task space or linear in joint space.
%       Mode: {['LinearTask'] 'LinearJoint'}
%
%   confirm = SCORSETXYZPR(___) returns 1 if successful and 0 otherwise.
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also ScorGetXYZPR ScorSetBSEPR ScorGetBSEPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorCartMove.m"
%       
%   M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated error handling
%   23Dec2015 - Updated to clarify errors.
%   25Aug2016 - Updated to correct default movement type.

%% Set global for ScorSetUndo
global ScorSetUndoBSEPR

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors:
%   e.g. ScorSetXYZPR(X,Y,Z,Pitch,Roll);

% Check for zero inputs
if nargin < 1
    error('ScorSet:NoXYZPR',...
        ['End-effector position and orientation must be specified.',...
        '\n\t-> Use "ScorSetXYZPR(XYZPR)".']);
end
% Check XYZPR
if nargin >= 1
    XYZPR = varargin{1};
    if ~isnumeric(XYZPR) || numel(XYZPR) ~= 5
        error('ScorSet:BadXYZPR',...
            ['End-effector position and orientation must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorSetXYZPR([X,Y,Z,Pitch,Roll])".']);
    end
end
% Check property designator
if nargin >= 2
    pType = varargin{2};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "ScorSetXYZPR(XYZPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetXYZPR(XYZPR,''MoveType'',''LinearTask'')".'],pType);
    end
    if nargin < 3
        error('ScorSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "ScorSetXYZPR(XYZPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetXYZPR(XYZPR,''MoveType'',''LinearTask'')".'],pType);
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
                '\n\t-> Use "ScorSetXYZPR(XYZPR,''MoveType'',''LinearJoint'')" or',...
                '\n\t-> Use "ScorSetXYZPR(XYZPR,''MoveType'',''LinearTask'')".'],mType);
    end
end
% Check for too many inputs
if nargin > 3
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Set point
isSet = ScorSetPoint(XYZPR,'Mode','Absolute');
if ~isSet
    confirm = false;
    return
end

%% Set the ScorSetUndo waypoint
% TODO - add error checking
ScorSetUndoBSEPR = ScorGetBSEPR;

%% Goto point
isMove = ScorGotoPoint('MoveType',mType);
if isMove
    confirm = true;
    return
else
    confirm = false;
    return
end
