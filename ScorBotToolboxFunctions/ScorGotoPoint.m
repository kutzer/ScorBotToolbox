function confirm = ScorGotoPoint(varargin)
% SCORGOTOPOINT moves ScorBot to an individual "point" within a specified 
% "vector" on the ScorBot controller.
%   SCORGOTOPOINT moves to the point with index value 1000 of the default 
%   "USNA" vector.
%
%   SCORGOTOPOINT(idx) moves to the point with the specified index value 
%   of the default "USNA" vector.
%
%   SCORGOTOPOINT(name,idx) moves to the point with the specified index 
%   value of the default specified vector "name".
%
%   SCORGOTOPOINT(...,'MoveType',mode) specifies whether the movement is
%   a linear or joint movement.
%       Mode: {'LinearTask' ['LinearJoint']}
%
%   confirm = SCORGOTOPOINT(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorSetPoint ScorCreateVector ScorSetXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorMoveToPt.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Redundand "ScorIsReady" added at the end of the function
%               for additional error checking
%   28Aug2015 - Updated error handling

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check if ScorBot teach pendant is set to Auto
isAuto = ScorSetPendantMode('Auto');
if ~isAuto
    confirm = false;
    return
end

%% Check inputs
narginchk(0,4);

mType = 'LinearJoint'; 
nInputs = nargin;
if nInputs >= 2
    if strcmpi('movetype',varargin{end-1})
        mType = varargin{end};
        nInputs = nInputs - 2;
    end
end
if nInputs == 2
    vName = varargin{1};
    idx   = varargin{2};
end
if nInputs == 1
    vName = 'USNA';
    idx   = varargin{1};
end
if nInputs == 0
    vName = 'USNA';
    idx   = 1000;
end

% confirm valid vector name
if ~ischar(vName)
    error('The specified vector name must be a valid character string.');
end
if numel(vName) > 16
    error('The specified vector name must be 16 characters or less.');
end
% check index value against maximum bound
if idx < 0 || idx ~= round(idx)
    error('The specified vector index value must be a positive integer.');
end
if idx > 1e4
    error('The specified vector index value must be less than 10,000.');
end

%% Goto point
switch lower(mType)
    case 'lineartask'
        isMove = calllib(libname,'RMoveLinear',vName,idx);
        if isMove
            confirm = true;
        else
            confirm = false;
%             if nargin == 0
%                 warning('Failed to move to index value %d of vector %s',pMode,idx,vName);
%             end
        end
    case 'linearjoint'
        isMove = calllib(libname,'RMoveJoint',vName,idx);
        if isMove
            confirm = true;
        else
            confirm = false;
%             if nargin == 0
%                 warning('Failed to move to index value %d of vector %s',pMode,idx,vName);
%             end
        end
    otherwise
        error('The specified movement must be designated as an "Linear" or "Joint".');
end

%% Check for errors
ScorIsReady;
