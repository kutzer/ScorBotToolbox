function H = ScorBSEPR2Pose(varargin)
% SCORBSEPR2POSE calculate the forward kinematics of the ScorBot given the 
% BSEPR joint parameters.
%
% NOTE: "ScorFkin.m" is an alternate name for  "ScorBSEPR2Pose.m".
%
%   H = SCORBSEPR2POSE(BSEPR) calculates a 4x4 homogeneous transformation
%   representing the end-effector pose of ScorBot given the 5-element BSEPR
%   joint angle vector (in radians)
%       H - 4x4 homogeneous transformation with distance parameters
%           specified in millimeters
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%
%   NOTE: This function supports symbolic variables.
%
%   See also ScorFkin ScorPose2BSEPR ScorIkin ScorDHtable DH DHtableToFkin
%
%   M. Kutzer, 11Aug2015, USNA

% Updates
%   23Dec2015 - Updated to varargin to clarify errors.
%   23Dec2015 - Updated to clarify errors.
%   31Oct2016 - Added "Todo" for use with symbolic variables

%% Check inputs
% This assumes nargin is fixed to 1 with a set of common errors:
%   e.g. ScorBSEPR2Pose(theta1,theta2,theta3,theta4,theta5);

% Check for zero inputs
if nargin < 1
    error('ScorX2Y:NoBSEPR',...
        ['Joint configuration must be specified.',...
        '\n\t-> Use "ScorBSEPR2Pose(BSEPR)".']);
end
% Check BSEPR
if nargin >= 1
    BSEPR = varargin{1};
    % TODO - make this work with symbolic variables
    %   -> Consider removing isnumeric()...
    if ~isnumeric(BSEPR) || numel(BSEPR) ~= 5
        error('ScorX2Y:BadBSEPR',...
            ['Joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorBSEPR2Pose([Joint1,Joint2,...,Joint5])".']);
    end
end
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Calculate pose
DHtable = ScorDHtable(BSEPR);
H = DHtableToFkin(DHtable);