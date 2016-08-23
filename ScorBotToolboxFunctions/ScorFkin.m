function H = ScorFkin(BSEPR)
% SCORFKIN calculate the forward kinematics of the ScorBot given the BSEPR
% joint parameters. 
%
% NOTE: "ScorFkin.m" is an alternate name for  "ScorBSEPR2Pose.m".
%
%   H = ScorFkin(BSEPR) calculates a 4x4 homogeneous transformation
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
%   See also ScorIkin ScorBSEPR2Pose ScorPose2BSEPR ScorDHtable DH DHtableToFkin
%
%   M. Kutzer, 11Aug2015, USNA

H = ScorBSEPR2Pose(BSEPR);