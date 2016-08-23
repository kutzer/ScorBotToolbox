function BSEPRLimits = ScorBSEPRLimits()
% SCORBSEPRLIMITS provides an estimate of the lower and upper limits of 
% the ScorBot joint angles in radians.
%   BSEPRLimits = SCORBSEPRLIMITS provides a 5x2 array containing the lower
%   and upper limits of the ScorBot joint angles in radians.  
%       BSEPRLimits - 5x2 array of joint limits in radians
%           BSEPR(1,:) - base joint limits in radians     [LowerLimit,UpperLimit]
%           BSEPR(2,:) - shoulder joint limits in radians [LowerLimit,UpperLimit] 
%           BSEPR(3,:) - elbow joint limits in radians    [LowerLimit,UpperLimit] 
%           BSEPR(4,:) - wrist pitch limits in radians    [LowerLimit,UpperLimit] 
%           BSEPR(5,:) - wrist roll limits in radians     [LowerLimit,UpperLimit] 
%
%   NOTE: Joint configurations including shoulder, elbow, and wrist pitch
%   joint values close to their positive joint limits may result in a
%   configuration that yields unexpected results from ScorXYZPR2BSEPR.
%
%   See also ScorBSEPRRandom
% 
%   M. Kutzer 10Aug2015, USNA

%% Experimental limits
% Limits taken from "r" configuration starting point using 1-degree
% movement increments. 

% Lower limits
BSEPRLimits(:,1) = ...
   [-2.33466;...
    -0.493562;... % 0.01213;... <--- Updated limit using [0,*,-0.073182,0.458515,0]
    -2.45751;...
    -1.91367;...
    -6.28319];

% Upper limits
BSEPRLimits(:,2) = ...
   [ 3.068393;...
     2.204281;...
    -0.090000;...
     2.340940;...
     6.283185];

% %% Create a safe offset of limits
% offset = deg2rad(...
%     [1.0,-1.0;...
%      1.0,-1.0;...
%      1.0,-1.0;...
%      1.0,-1.0;...
%      0.0, 0.0]);
%  
% %% Apply offset
% BSEPRLimits = BSEPRLimits + offset;