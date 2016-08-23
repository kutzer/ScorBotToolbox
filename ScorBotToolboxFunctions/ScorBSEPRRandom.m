function BSEPR = ScorBSEPRRandom(k)
% SCORBSEPRRANDOM creates a random set joint angles in radians within the
% joint limits of ScorBot.
%   BSEPR = SCORBSEPRRANDOM creates a random 5-element joint-space vector 
%   containing joint angles ordered from the base up within the joint 
%   limits of ScorBot.
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%
%   BSEPR = SCORBSEPRRANDOM(k) creates a random 5-element joint-space
%   vector maximum and minimum possible limits scaled about the 
%   joint limit mean by k. 
%
%   NOTE: There is no guarantee that the joint configuration produced by
%   this function will be reachable using "ScorSetBSEPR".
%
%   See also: ScorBSEPRLimits
%
%   M. Kutzer 10Aug2015, USNA

%% Check inputs
if nargin < 1
    k = 1;
end

%% Create random set of joint values
BSEPRLimits = ScorBSEPRLimits;
dBSEPRLimits = diff(BSEPRLimits,1,2); % difference between lower and upper limits
mBSEPRLimits = mean(BSEPRLimits,2); % mean of limits

BSEPR = mBSEPRLimits + k*bsxfun(@minus,rand(5,1),0.5).*dBSEPRLimits;
BSEPR = transpose(BSEPR);
