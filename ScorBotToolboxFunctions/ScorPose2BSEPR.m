function BSEPR = ScorPose2BSEPR(varargin)
% SCORPOSE2BSEPR calculate the the BSEPR joint parameters given the forward
% kinematics of the ScorBot.
%
% NOTE: "ScorIkin.m" is an alternate name for "ScorPose2BSEPR.m".
%
%   BSEPR = SCORPOSE2BSEPR(H) calculates 5-element BSEPR joint angle vector
%   (in radians) given a 4x4 homogeneous transformation representing the 
%   end-effector pose of ScorBot. The "elbow-up" solution with the smallest
%   shoulder angle above 0 is returned. If no solution exists, an empty set
%   is returned.
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%       H - 4x4 homogeneous transformation with distance parameters
%           specified in millimeters
%
%   BSEPR = SCORPOSE2BSEPR(___,'ElbowUpSolution') returns only the 
%   "elbow-up" solution. [Default]
%
%   BSEPR = SCORPOSE2BSEPR(___,'ElbowDownSolution') returns only the 
%   "elbow-down" solution. 
%
%   BSEPRs = SCORPOSE2BSEPR(___,'AllSolutions') returns all possible 
%   solutions (packaged in a cell array).
%
%   See also ScorIkin ScorBSEPR2Pose ScorFkin ScorDHtable DH DHtableToFkin
%
%   M. Kutzer, 13Aug2015, USNA

% Updates
%   23Dec2015 - Updated to clarify errors.
%   30Dec2015 - Updated to match ScorXYZPR2BSEPR functionality

% TODO - select either an Nx5 or cell array output to match other ScorX2Y 
% functions

%% Check inputs
% This assumes nargin is fixed to 1 or 2 with a set of common errors.

% Check for zero inputs
if nargin < 1
    error('ScorX2Y:NoPose',...
        ['End-effector pose must be specified.',...
        '\n\t-> Use "ScorPose2BSEPR(H)".']);
end
% Check Pose
if nargin >= 1
    H = varargin{1};
    if size(H,1) ~= 4 || size(H,2) ~= 4 || ~isSE(H)
        error('ScorX2Y:BadPose',...
            ['End-effector pose must be specified as a valid 4x4 element of SE(3).',...
            '\n\t-> Use "ScorPose2BSEPR(H)".']);
    end
end
% Check property value
if nargin >= 2
    switch lower(varargin{2})
        case 'elbowupsolution'
            % Return elbow-up solution only
        case 'elbowdownsolution'
            % Return elbow-down solution only
        case 'allsolutions'
            % Return elbow-up solution
        otherwise
            error('ScorX2Y:BadPropVal',...
                ['Unexpected property value: "%s".',...
                '\n\t-> Use "ScorPose2BSEPR(H,''AllSolutions'')".'],varargin{2});
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Get DH parameters
DHtable = ScorDHtable;
%theta = DHtable(:,1);
d = DHtable(:,2);
a = DHtable(:,3);
alpha = DHtable(:,4);

%% Calculate base angle candidates
b(1,1) = atan2(H(2,4), H(1,4));
% alternate base joint angle in radians
if b(1) > 0
    b(2,1) = b(1) - pi;
else
    b(2,1) = b(1) + pi;
end

%% Get forward kinematics in the manipulator plane and calculate candidate 
% solutions for each base angle
for i = 1:numel(b)
    H_inPlane = Rx(-alpha(1))*Tx(-a(1))*Tz(-d(1))*Rz(-b(i))*H*...
                Rx(-alpha(end))*Tx(-a(end))*Tz(-d(end));
    % Calculate wrist roll angle
    r(i,1) = atan2(H_inPlane(3,1),H_inPlane(3,2));
    % Calculate distance between shoulder and wrist
    d = norm(H_inPlane(1:2,4));
    if d > ( abs(a(2)) + abs(a(3)) )
        % No valid solution exists for this base joint angle
        s(i,1) = NaN;
        s(i,2) = NaN;
        e(i,1) = NaN;
        e(i,2) = NaN;
        p(i,1) = NaN;
        p(i,2) = NaN;
    else
        % Calculate rise angle of wrist relative to shoulder
        rise = atan2(H_inPlane(2,4),H_inPlane(1,4));
        % Calculate interior angles of Link(a2), Link(a3), d triangle
        %alpha2 = acos( (a(3)^2 + d^2 - a(1)^2)/(2*a(3)*d) );
        alpha3 = acos( (a(2)^2 + d^2 - a(3)^2)/(2*a(2)*d) );
        delta  = acos( (a(2)^2 + a(3)^2 - d^2)/(2*a(2)*a(3)) );
        % Calculate shoulder angles
        s(i,1) = rise + alpha3; % "Elbow up"
        s(i,2) = rise - alpha3; % "Elbow down"
        % Calculate elbow angles
        e(i,1) = delta - pi; % "Elbow up"
        e(i,2) = pi - delta; % "Elbow down"
        % Calculate XYZPR pitch angle
        pitch = atan2(H_inPlane(2,3),H_inPlane(1,3));
        % Calculate wrist pitch angle
        p(i,1) = pitch - e(i,1) - s(i,1);
        p(i,2) = pitch - e(i,2) - s(i,2);
    end
end

%% Account for repeated base angle and wrist roll solutions
b = repmat(b,1,2);
r = repmat(r,1,2);

%% Reshape and output
b = reshape(b,[],1);
s = reshape(s,[],1);
e = reshape(e,[],1);
p = reshape(p,[],1);
r = reshape(r,[],1);

BSEPR = [b,s,e,p,r];

% wrap joint angles to [-pi,pi]
BSEPR = wrapToPi(BSEPR);

% remove NaN solutions
[i,~] = find(isnan(BSEPR));
BSEPR(unique(i),:) = [];

% remove incorrect solutions
idx = [];
ZERO = 1e-3;
for i = 1:size(BSEPR,1)
    H_star = ScorBSEPR2Pose(BSEPR(i,:));
    if ~isZero(H-H_star,ZERO)
        idx(end+1) = i;
    end
end
BSEPR(idx,:) = [];

%% Package output
if ~isempty(BSEPR)
    if nargin == 1
        % TODO - select the solution described in help documentation
        % Output first BSEPR solution
        BSEPR = BSEPR(1,:);
    else
        switch lower(varargin{2})
            case 'elbowupsolution'
                % Return elbow-up solution
                BSEPR = BSEPR(1,:);
            case 'elbowdownsolution'
                % Return elbow-down solution
                if size(BSEPR,1) > 1
                    BSEPR = BSEPR(2,:);
                else
                    BSEPR = [];
                end
            case 'allsolutions'
                % Output all BSEPR solutions
                thetas = BSEPR;
                clear BSEPR
                for i = 1:size(thetas,1)
                   BSEPR{i} = thetas(i,:);
                end
            otherwise
                error('Unexpected property value.');
        end
    end
end

