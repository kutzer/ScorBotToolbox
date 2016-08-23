function confirm = ScorSetDeltaBSEPR(varargin)
% SCORSETDELTABSEPR moves the ScorBot to a specified joint configuration 
% relative to the current joint configuration.
%   SCORSETDELTABSEPR(DeltaBSEPR) moves each of ScorBot's joints by 
%   increments define in the 5-element joint-space vector angles ordered 
%   from the base up. 
%       DeltaBSEPR - 5-element joint vector in radians
%           DeltaBSEPR(1) - relative base joint movement angle in radians
%           DeltaBSEPR(2) - relative shoulder joint movement angle in radians
%           DeltaBSEPR(3) - relative elbow joint movement angle in radians
%           DeltaBSEPR(4) - relative wrist pitch movement angle in radians
%           DeltaBSEPR(5) - relative wrist roll movement angle in radians
%
%   SCORSETDELTABSEPR(...,'MoveType',mode) specifies whether the movement 
%   is linear in task space or linear in joint space.
%       Mode: {'LinearTask' ['LinearJoint']}
%
%   confirm = SCORSETDELTABSEPR(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also: ScorSetDeltaXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorDeltaJtMove.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   01Sep2015 - Added ScorIsReady to account for potential empty set error
%               later in code (with ScorGetBSEPR)
%   23Dec2015 - Updated to clarify errors.

% TODO - account for excessive movements 
%        (e.g. ScorSetDeltaBSEPR([0,-pi,0,0,0]);

%% Set global for ScorSetUndo
global ScorSetUndoBSEPR

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors:
%   e.g. ScorSetDeltaBSEPR(DeltaTheta1,DeltaTheta2,...,DeltaTheta5);

% Check for zero inputs
if nargin < 1
    error('ScorSet:NoDeltaBSEPR',...
        ['Change in joint configuration must be specified.',...
        '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR)".']);
end
% Check DeltaBSEPR
if nargin >= 1
    DeltaBSEPR = varargin{1};
    if ~isnumeric(DeltaBSEPR) || numel(DeltaBSEPR) ~= 5
        error('ScorSet:BadDeltaBSEPR',...
            ['Change in joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorSetDeltaBSEPR([DeltaJoint1,DeltaJoint2,...,DeltaJoint5])".']);
    end
end
% Check property designator
if nargin >= 2
    pType = varargin{2};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR,''MoveType'',''LinearTask'')".'],pType);
    end
    if nargin < 3
        error('ScorSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR,''MoveType'',''LinearTask'')".'],pType);
    end
end
% Check property value
mType = 'LinearJoint';
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
                '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR,''MoveType'',''LinearJoint'')" or',...
                '\n\t-> Use "ScorSetDeltaBSEPR(DeltaBSEPR,''MoveType'',''LinearTask'')".'],mType);
    end
end
% Check for too many inputs
if nargin > 3
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Check ScorBot
isReady = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Move delta
BSEPR_Old = ScorGetBSEPR;
XYZPR_Old = ScorGetXYZPR;

BSEPR_New = BSEPR_Old + DeltaBSEPR;
% Check for elbow-down condition
if BSEPR_New(3) > 0
    warning('This ScorBot library does not support movements resulting in an "elbow down" configuration.');
    confirm = false;
    return
end
XYZPR_New = ScorBSEPR2XYZPR(BSEPR_New);

%% Set the ScorSetUndo waypoint
% TODO - add error checking
ScorSetUndoBSEPR = ScorGetBSEPR;

%% Move arm
DeltaXYZPR = XYZPR_New - XYZPR_Old;
confirm = ScorSetDeltaXYZPR(DeltaXYZPR,'MoveType',mType);