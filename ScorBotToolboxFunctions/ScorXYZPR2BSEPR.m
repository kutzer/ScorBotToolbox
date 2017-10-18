function BSEPR = ScorXYZPR2BSEPR(varargin)
% SCORXYZPR2BSEPR converts task variables to joint angles.
%   BSEPR = SCORXYZPR2BSEPR(XYZPR) converts the 5-element task-space vector
%   containing the end-effector x,y,z position, and end-effector pitch and
%   roll to the 5-element joint-space vector containing joint angles
%   ordered from the base up in the "elbow-up" configuration.
%       XYZPR - 5-element vector containing end-effector position and
%       orientation.
%           XYZPR(1) - end-effector x-position in millimeters
%           XYZPR(2) - end-effector y-position in millimeters
%           XYZPR(3) - end-effector z-position in millimeters
%           XYZPR(4) - end-effector wrist pitch in radians
%           XYZPR(5) - end-effector wrist roll in radians
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%
%   NOTE: An empty set is returned if no reachable solution exists.
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR
%   is calculated relative to the base.
%
%   BSEPR = SCORXYZPR2BSEPR(___,'ElbowUpSolution') returns only the
%   "elbow-up" solution. [Default]
%
%   BSEPR = SCORXYZPR2BSEPR(___,'ElbowDownSolution') returns only the
%   "elbow-down" solution.
%
%   BSEPRs = SCORXYZPR2BSEPR(___,'AllSolutions') returns all possible
%   solutions (packaged in a cell array).
%
%   See also ScorGetBSEPR ScorSetXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorX2Deg.m"
%
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated to correct help documentation, "J. Esposito K.
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   23Oct2015 - Updated to provide clearer solutions to elbow-up, and
%               elbow-down problem following inverse kinematic solution.
%   23Dec2015 - Updated to clarify errors.
%   30Dec2015 - Corrected help documentation.
%   17Oct2017 - Updated solution check to account for spacing of floating
%               point numbers (see eps), wrap rotational values for
%               comparison, and return "good" solutions when available.
%   18Oct2017 - Updated solution check to account for values close to 0
%               and/or 2*pi.

% TODO - check special case configurations
% TODO - account for additional "reach-back" solutions and clarify pitch.
% TODO - select either an Nx5 or cell array output to match other ScorX2Y
% functions

%% Check inputs
% This assumes nargin is fixed to 1 or 3 with a set of common errors:
%   e.g. ScorXYZPR2BSEPR(X,Y,Z,Pitch,Roll);

% Check for zero inputs
if nargin < 1
    error('ScorX2Y:NoXYZPR',...
        ['End-effector position and orientation must be specified.',...
        '\n\t-> Use "ScorXYZPR2BSEPR(XYZPR)".']);
end
% Check XYZPR
if nargin >= 1
    XYZPR = varargin{1};
    if ~isnumeric(XYZPR) || numel(XYZPR) ~= 5
        error('ScorX2Y:BadXYZPR',...
            ['End-effector position and orientation must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorXYZPR2BSEPR([X,Y,Z,Pitch,Roll])".']);
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
                '\n\t-> Use "ScorXYZPR2BSEPR(XYZPR,''ElbowUpSolution'')" or',...
                '\n\t-> Use "ScorXYZPR2BSEPR(XYZPR,''ElbowDownSolution'')" or'...
                '\n\t-> Use "ScorXYZPR2BSEPR(XYZPR,''AllSolutions'')".'],varargin{2});
    end
end
% Check for too many inputs
if nargin > 2
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Calculate BSEPR
x = XYZPR(1);
y = XYZPR(2);
z = XYZPR(3);
p = XYZPR(4);
r = XYZPR(5);

DHtable = ScorDHtable;
d = DHtable(:,2);
a = DHtable(:,3);

%% Calculate "standard" theta1 solutions
% Eq. 0
theta(1,1:2) = atan2(y,x);

% Eq. 1
x_t = sqrt(x^2 + y^2) - a(1);
% if abs( cos(theta(1,1)) ) > abs( sin(theta(1,1)) )
%     x_t = ( x/cos(theta(1,1)) ) - a(1);
% else
%     x_t = ( y/sin(theta(1,1)) ) - a(1);
% end
y_t = z - d(1);

% Eq. 2
x_b = x_t - d(5)*cos(p);
y_b = y_t - d(5)*sin(p);

% Eq. 3
m = sqrt(x_b^2 + y_b^2);

% Eq. 4
alpha = atan2(y_b,x_b);

% Eq. 5
%TODO - check for singularity issue(s)
beta = acos( (a(2)^2 + m^2 - a(3)^2)/(2*a(2)*m) );
beta = real(beta);

% Eq. 6 (elbow down)
theta(2,1) = wrapToPi(alpha - beta);

% Eq. 6* (elbow up)
theta(2,2) = wrapToPi(alpha + beta);

% Eq. 7
%TODO - check for singularity issue(s)
gamma = acos( (a(2)^2 + a(3)^2 - m^2)/(2*a(2)*a(3)) );
gamma = real(gamma);

% Eq. 8 (elbow down)
theta(3,1) = pi - gamma;

% Eq. 8 (elbow up)
theta(3,2) = gamma - pi;

% Eq. 9 (elbow down)
theta(4,1) = p - theta(2,1) - theta(3,1);

% Eq. 9 (elbow up)
theta(4,2) = p - theta(2,2) - theta(3,2);

% if x_t < 0
%     theta(4,1) = wrapToPi(pi - theta(4,1));
%     theta(4,2) = wrapToPi(pi - theta(4,2));
% end

%% Calculate "reach-back" theta1 solutions
% % Eq. 0
% theta(1,[1:2]+2) = wrapToPi(atan2(y,x) + pi);
%
% % Eq. 1
% % x_t = sqrt(x^2 + y^2) - a(1);
% if abs( cos(theta(1,1+2)) ) > abs( sin(theta(1,1+2)) )
%     x_t = ( x/cos(theta(1,1+2)) ) - a(1);
% else
%     x_t = ( y/sin(theta(1,1+2)) ) - a(1);
% end
% y_t = z - d(1);
%
% % Eq. 2
% x_b = x_t - d(5)*cos(p);
% y_b = y_t - d(5)*sin(p);
%
% % Eq. 3
% m = sqrt(x_b^2 + y_b^2);
%
% % Eq. 4
% alpha = atan2(y_b,x_b);
%
% % Eq. 5
% %TODO - check for singularity issue(s)
% beta = acos( (a(2)^2 + m^2 - a(3)^2)/(2*a(2)*m) );
% beta = real(beta);
%
% % Eq. 6 (elbow down)
% theta(2,1+2) = wrapToPi(alpha - beta);
%
% % Eq. 6* (elbow up)
% theta(2,2+2) = wrapToPi(alpha + beta);
%
% % Eq. 7
% %TODO - check for singularity issue(s)
% gamma = acos( (a(2)^2 + a(3)^2 - m^2)/(2*a(2)*a(3)) );
% gamma = real(gamma);
%
% % Eq. 8 (elbow down)
% theta(3,1+2) = pi - gamma;
%
% % Eq. 8 (elbow up)
% theta(3,2+2) = gamma - pi;
%
% % Eq. 9 (elbow down)
% theta(4,1+2) = p - theta(2,1+2) - theta(3,1+2);
%
% % Eq. 9 (elbow up)
% theta(4,2+2) = p - theta(2,2+2) - theta(3,2+2);
%
% % if x_t < 0
% %     theta(4,1) = wrapToPi(pi - theta(4,1+2));
% %     theta(4,2) = wrapToPi(pi - theta(4,2+2));
% % end

%% Set theta5
% Eq. 10
theta(5,:) = r;

%% Check solution
solution_str{1} = 'Elbow-Down';
solution_str{2} = 'Elbow-Up';
error_flag = false(1,2);
for i = 1:size(theta,2)
    % Calculate forward kinematics for given inverse kinematic solution
    X = ScorBSEPR2XYZPR( transpose( theta(:,i) ) );
    % Wrap rotational parameters for comparison
    X_in = [XYZPR(1:3),wrapTo2Pi(XYZPR(4:5))];
    X_calc = [X(1:3),wrapTo2Pi(X(4:5))];
    for ii = 4:5
        if abs(X_in(ii) - X_calc(ii)) > 3*pi/4
            X_in(ii) = wrapToPi( X_in(ii) );
            X_calc(ii) = wrapToPi( X_calc(ii) );
        end
    end
    % Calculate error
    ERROR = norm(X_in - X_calc);
    % Estimate conservative value for zero
    ZERO(1) = eps( norm(X_in) );
    ZERO(2) = eps( norm(X_calc) );
    ZERO = 10*max(ZERO);
    
    % Check error
    if ERROR > ZERO
        % Warn user
        warning('ScorX2Y:LargeError',...
            ['In the "%s", there is a larger than expected error between the XYZPR input and the calculated XYZPR from the inverse kinematic solution.',...
            '\n\t-> XYZPR_in   = [%0.4f,%0.4f,%0.4f,%0.4f,%0.4f]',...
            '\n\t-> XYZPR_calc = [%0.4f,%0.4f,%0.4f,%0.4f,%0.4f]',...
            '\n\t-> Error from norm(XYZPR_in - XYZPR_calc): %.20f',...
            '\n\t-> Floating Point Zero Estimate:           %.20f'],solution_str{i},...
            XYZPR(1),XYZPR(2),XYZPR(3),XYZPR(4),XYZPR(5),...
            X(1),X(2),X(3),X(4),X(5),...
            ERROR,ZERO);
        % Toggle error flag
        error_flag(i) = true;
    end
end

%% Package output
if nargin < 2
    % Return elbow-up solution only
    i = 2;
    if error_flag(i)
        BSEPR = [];
    else
        BSEPR = transpose( theta(:,i) );
    end
    return
end

switch lower(varargin{2})
    case 'elbowupsolution'
        % Return elbow-up solution only
        i = 2;
        if error_flag(i)
            BSEPR = [];
        else
            BSEPR = transpose( theta(:,i) );
        end
    case 'elbowdownsolution'
        % Return elbow-down solution only
        i = 1;
        if error_flag(i)
            BSEPR = [];
        else
            BSEPR = transpose( theta(:,i) );
        end
    case 'allsolutions'
        % Return elbow-up solution
        i = 2;
        if error_flag(i)
            BSEPR{1} = [];
        else
            BSEPR{1} = transpose( theta(:,i) );
        end
        % Return elbow-down solution
        i = 1;
        if error_flag(i)
            BSEPR{2} = [];
        else
            BSEPR{2} = transpose( theta(:,i) );
        end
    otherwise
        error('Unexpected property value.');
end

return
%% Old methods
%--------------------------------------------------------------------------
% Pose method.
%--------------------------------------------------------------------------
% H = ScorXYZPR2Pose(XYZPR);
% % Return if no solution exists
% if isempty(H)
%     BSEPR = [];
%     return;
% end
% BSEPR = ScorPose2BSEPR(H);
%
% % BSEPR = [];
% % H = ScorXYZPR2Pose(XYZPR,'AllSolutions');
% %
% % for i = 1:numel(H)
% %     BSEPRi = ScorPose2BSEPR(H{i});
% %     BSEPR = [BSEPR; BSEPRi];
% % end
%
% %% Remove roll parameters that do not match
% ZERO = 1e-6;
% idx = find( abs(bsxfun(@minus,BSEPR(:,5),XYZPR(5))) > ZERO );
% BSEPR(idx,:) = [];

%--------------------------------------------------------------------------
% Original method.
%--------------------------------------------------------------------------
% %% Get rigid geometry terms from DHtable
% DHtable = ScorDHtable;
% d = DHtable(:,2);
% a = DHtable(:,3);
%
% %% Calculate task vector
% BSEPR = zeros(1,5);
% % base joint angle in radians
% BSEPR(1) = atan2(XYZPR(2), XYZPR(1));
% % wrist roll angle in radians
% BSEPR(5) = XYZPR(5);
% % radius in xy-plane
% r = sqrt( (XYZPR(1)^2)+(XYZPR(2)^2) )-a(1)-d(5)*cos(XYZPR(4));
% %
% h = XYZPR(3)-d(1)-d(5)*sin(XYZPR(4));
% %
% gamma = atan2(h,r);
% %
% b = sqrt(h^2+r^2);
% %
% alpha = atan2(sqrt( 4*(a(2)^2)-(b^2) ),b);
% % shoulder joint angle in radians
% BSEPR(2) = alpha+gamma;
% % elbow joint angle in radians
% BSEPR(3) = -2*alpha;
% % wrist pitch in radians
% BSEPR(4) = XYZPR(4)-BSEPR(2)-BSEPR(3);
