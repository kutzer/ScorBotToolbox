function confirm = ScorSetBSEPR(varargin)
% SCORSETBSEPR moves the ScorBot to a specified joint configuration.
%   SCORSETBSEPR(BSEPR) moves the ScorBot to the 5-element joint-space 
%   vector containing joint angles ordered from the base up. 
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%
%   SCORSETBSEPR(...,'MoveType',mode) specifies whether the movement is
%   linear in task space or linear in joint space.
%       Mode: {'LinearTask' ['LinearJoint']}
%
%   confirm = SCORSETBSEPR(___) returns 1 if successful and 0 otherwise.
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also ScorGetBSEPR ScorSetXYZPR ScorGetXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorJtMove.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   25Sep2015 - Updated to account for BSEPR(1) = +/-pi issue of returning
%               successful move when no move occurs.
%   23Dec2015 - Updated to clarify errors.

%% Set global for ScorSetUndo
global ScorSetUndoBSEPR

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors:
%   e.g. ScorSetBSEPR(theta1,theta2,theta3,theta4,theta5);

% Check for zero inputs
if nargin < 1
    error('ScorSet:NoBSEPR',...
        ['Joint configuration must be specified.',...
        '\n\t-> Use "ScorSetBSEPR(BSEPR)".']);
end
% Check BSEPR
if nargin >= 1
    BSEPR = varargin{1};
    if ~isnumeric(BSEPR) || numel(BSEPR) ~= 5
        error('ScorSet:BadBSEPR',...
            ['Joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorSetBSEPR([Joint1,Joint2,...,Joint5])".']);
    end
end
% Check property designator
if nargin >= 2
    pType = varargin{2};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "ScorSetBSEPR(BSEPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetBSEPR(BSEPR,''MoveType'',''LinearTask'')".'],pType);
    end
    if nargin < 3
        error('ScorSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "ScorSetBSEPR(BSEPR,''MoveType'',''LinearJoint'')" or',...
            '\n\t-> Use "ScorSetBSEPR(BSEPR,''MoveType'',''LinearTask'')".'],pType);
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
                '\n\t-> Use "ScorSetBSEPR(BSEPR,''MoveType'',''LinearJoint'')" or',...
                '\n\t-> Use "ScorSetBSEPR(BSEPR,''MoveType'',''LinearTask'')".'],mType);
    end
end
% Check for too many inputs
if nargin > 3
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Check for known joint 1 issue
if abs(BSEPR(1)) >= pi
    % Force code 908
    errStruct = ScorParseErrorCode(908);
    ScorDispError(errStruct);
    confirm = false;
    return
end

%% Check for elbow-down condition
if BSEPR(3) > 0
    warning('This ScorBot library does not support movements resulting in an "elbow down" configuration.');
    confirm = false;
    return
end

%% Set the ScorSetUndo waypoint
% TODO - add error checking
ScorSetUndoBSEPR = ScorGetBSEPR;

%% Convert BSEPR to XYZPR
% NOTE: This library is currently unable to access direct control over
% joint angles due to a possible discrepancy in the available ScorBot 
% documentation. As a result, BSEPR angles must be converted to task
% variables, and a task-variable move is executed.
XYZPR = ScorBSEPR2XYZPR(BSEPR);
confirm = ScorSetXYZPR(XYZPR,'MoveType',mType);