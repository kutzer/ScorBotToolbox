function H = ScorXYZPR2Pose(varargin)
% SCORXYZPR2POSE calculate the end-effector pose of the ScorBot given the 
% XYZPR parameters of the end-effector.
%   H = SCORXYZPR2POSE(XYZPR) calculates a 4x4 homogeneous transformation
%   representing the end-effector pose of ScorBot given the 5-element XYZPR
%   task space vector. The single solution returned is generated from an  
%   assumed base angle, b = atan2(XYZPR(2),XYZPR(1)).
%       H - 4x4 homogeneous transformation with distance parameters
%           specified in millimeters
%       XYZPR - 5-element vector containing end-effector position and
%       orientation.
%           XYZPR(1) - end-effector x-position in millimeters
%           XYZPR(2) - end-effector y-position in millimeters
%           XYZPR(3) - end-effector z-position in millimeters
%           XYZPR(4) - end-effector wrist pitch in radians
%           XYZPR(5) - end-effector wrist roll in radians
%
%   NOTE: An empty set is returned if no reachable solution exists.
%
%   H = SCORXYZPR2POSE(XYZPR,'AllSolutions') calculates two 4x4 
%   homogeneous transformations (packaged in a cell array) representing the
%   two possible end-effector poses of ScorBot given the 5-element XYZPR 
%   task space vector. The two solutions result from two possible base
%   joint angles offset by pi. If solutions are redundant, the second 
%   solution is removed. 
%       b(1) = atan2(XYZPR(2),XYZPR(1))
%       b(2) = atan2(XYZPR(2),XYZPR(1)) + pi
%
%   See also ScorPose2XYZPR ScorFkin ScorPose2BSEPR
%
%   M. Kutzer, 12Aug2015, USNA

% Updates
%   23Dec2015 - Updated to clarify errors.

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors:
%   e.g. ScorXYZPR2Pose(X,Y,Z,Pitch,Roll);

% Check for zero inputs
if nargin < 1
    error('ScorX2Y:NoXYZPR',...
        ['End-effector position and orientation must be specified.',...
        '\n\t-> Use "ScorXYZPR2Pose(XYZPR)".']);
end
% Check XYZPR
if nargin >= 1
    XYZPR = varargin{1};
    if ~isnumeric(XYZPR) || numel(XYZPR) ~= 5
        error('ScorX2Y:BadXYZPR',...
            ['End-effector position and orientation must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorXYZPR2Pose([X,Y,Z,Pitch,Roll])".']);
    end
end
% Check property value
if nargin >= 2
    switch lower(varargin{2})
        case 'allsolutions'
            % Return all solutions
        otherwise
            error('ScorX2Y:BadPropVal',...
                ['Unexpected property value: "%s".',...
                '\n\t-> Use "ScorXYZPR2Pose(XYZPR,''AllSolutions'')".'],varargin{2});
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Calculate end-effector pose (Solution 1)
% Note: Fixed rotations Rx(pi) and Ry(pi/2) are required to align 
% end-effector frame with the frame specified by the DHtable.

% base joint angle in radians
b(1) = atan2(XYZPR(2), XYZPR(1));
% forward kinematic solution 1
H{1} = Tx(XYZPR(1))*Ty(XYZPR(2))*Tz(XYZPR(3))*Rz(b(1))*Rx(pi)*Ry(pi/2)*Ry(XYZPR(4))*Rz(XYZPR(5));

%% Check if pose is within the workspace
BSEPR = ScorPose2BSEPR(H{1});
if isempty(BSEPR)
    H{1} = [];
end

%% Return single solution if alternates are not asked for
if nargin == 1
    H = H{1};
    return
end

%% Calculate end-effector pose (Solution 2)
% NOTE: This assumes the base rotation angle is bounded between [-pi,pi].
% This solution is associated with the end-effector reaching back beyond 
% the base axis of ScorBot.

% alternate base joint angle in radians
if b(1) > 0
    b(2) = b(1) - pi;
else
    b(2) = b(1) + pi;
end
% forward kinematic solution 2
H{2} = Tx(XYZPR(1))*Ty(XYZPR(2))*Tz(XYZPR(3))*Rz(b(2))*Rx(pi)*Ry(pi/2)*Ry(XYZPR(4))*Rz(XYZPR(5));

%% Check if pose is within the workspace
BSEPR = ScorPose2BSEPR(H{2});
if isempty(BSEPR)
    H{2} = [];
end

%% Remove empty solutions
if isempty(H{1}) || isempty(H{2})
    tmp = H;
    H = [];
    for i = 1:2
        if ~isempty(tmp(i))
            H{end+1} = tmp(i);
        end
    end
end

%% Return if no solution exists
if isempty(H)
    return;
end

%% Check for identical solutions
if numel(H) == 2
    if isZero( norm(H{1} - H{2}) )
        tmp = H;
        H = [];
        % Remove redundant solution
        H{1} = tmp{1};
    end
end

%% Package output
switch lower(varargin{2})
    case 'allsolutions'
        % Output H both solutions
    case 'firstsolution'
        H = H{1};
    case 1
        H = H{1};
    case 2
        % Output H both solutions
    otherwise
        error('Unexpected property value.');
end