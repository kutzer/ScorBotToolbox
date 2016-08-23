function confirm = ScorSetUndo
% SCORSETUNDO returns ScorBot to the previously set waypoint
%   SCORSETUNDO returns ScorBot to the previously set joint configuration. 
%
%   confirm = SCORSETUNDO(___) returns 1 if successful and 0 otherwise.
%
%   See also: ScorSetBSEPR ScorSetXYZPR ScorSetPose ScorSetDeltaBSEPR
%   ScorSetDeltaXYZPR ScorSetDeltaPose
%
%   M. Kutzer, 20Apr2016, USNA

% Updates
%   23Aug2016 - Updated help documentation.

global ScorSetUndoBSEPR

if isempty(ScorSetUndoBSEPR)
    warning('No previous waypoints detected.');
    return
end

confirm = ScorSetBSEPR(ScorSetUndoBSEPR);