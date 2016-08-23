function BSEPR = ScorIkin(H)
% SCORIKIN calculate the the BSEPR joint parameters given the forward
% kinematics of the ScorBot.
%
% NOTE: "ScorIkin.m" is an alternate name for "ScorPose2BSEPR.m".
%
%   BSEPR = SCORIKIN(H) calculates 5-element BSEPR joint angle vector
%   (in radians) given a 4x4 homogeneous transformation representing the 
%   end-effector pose of ScorBot.
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%       H - 4x4 homogeneous transformation with distance parameters
%           specified in millimeters
%
%   See also ScorIkin ScorBSEPR2Pose ScorFkin ScorDHtable DH DHtableToFkin
%
%   M. Kutzer, 11Aug2015, USNA

BSEPR = ScorPose2BSEPR(H);