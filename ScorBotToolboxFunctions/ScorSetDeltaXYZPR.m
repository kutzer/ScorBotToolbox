function confirm = ScorSetDeltaXYZPR(varargin)
% SCORSETDELTAXYZPR moves the ScorBot end-effector to a specified x,y,z 
% position, and pitch and roll orientation relative to the current
% end-effector position and orientation.
%   SCORSETDELTAXYZPR(DeltaXYZPR) changes ScorBot's end-effector position
%   and orientation by the changes specified 5-element task-space vector.
%       DeltaXYZPR - 5-element vector containing changes in end-effector 
%       position and orientation.
%           DeltaXYZPR(1) - change in end-effector x-position in millimeters
%           DeltaXYZPR(2) - change in end-effector y-position in millimeters
%           DeltaXYZPR(3) - change in end-effector z-position in millimeters
%           DeltaXYZPR(4) - change in end-effector pitch in radians
%           DeltaXYZPR(5) - change in end-effector roll in radians
%
%   SCORSETDELTAXYZPR(...,'MoveType',mode) specifies whether the movement 
%   is linear in task space or linear in joint space.
%       Mode: {['LinearTask'] 'LinearJoint'}
%
%   confirm = SCORSETDELTAXYZPR(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorSetDeltaBSEPR ScorSetXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, &  K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorDeltaCartMove.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated error handling
%   23Dec2015 - Updated to clarify errors.

%% Set global for ScorSetUndo
global ScorSetUndoBSEPR

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors:
%   e.g. ScorSetDeltaXYZPR(DeltaX,DeltaY,...,DeltaRoll);

% Check for zero inputs
if nargin < 1
    error('ScorSet:NoDeltaXYZPR',...
        ['Change in end-effector position and orientation must be specified.',...
        '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR)".']);
end
% Check DeltaBSEPR
if nargin >= 1
    DeltaXYZPR = varargin{1};
    if ~isnumeric(DeltaXYZPR) || numel(DeltaXYZPR) ~= 5
        error('ScorSet:BadDeltaXYZPR',...
            ['Change in end-effector position and orientation must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorSetDeltaXYZPR([DeltaX,DeltaY,DeltaZ,DeltaPitch,DeltaRoll])".']);
    end
end
% Check property designator
if nargin >= 2
    pType = varargin{2};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR,''MoveType'',''LinearTask'')".'],pType);
    end
    if nargin < 3
        error('ScorSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR,''MoveType'',''LinearTask'')".'],pType);
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
                '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR,''MoveType'',''LinearJoint'')" or',...
                '\n\t-> Use "ScorSetDeltaXYZPR(DeltaXYZPR,''MoveType'',''LinearTask'')".'],mType);
    end
end
% Check for too many inputs
if nargin > 3
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Set point
isSet = ScorSetPoint(DeltaXYZPR,'Mode','Relative');
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