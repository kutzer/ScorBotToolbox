function H = ScorGetPose()
% SCORGETPOSE gets the current end-effector pose of ScorBot.
%   H = ScorGetPose gets the 4x4 homogeneous transformation representing 
%   the end-effector pose of ScorBot.
%
%   See also ScorGetBSEPR ScorGetXYZPR
%
%   M. Kutzer, 13Aug2015, USNA

BSEPR = ScorGetBSEPR;
H = ScorBSEPR2Pose(BSEPR);
