function BSEPRs = interpSimXYZPR2BSEPR(XYZPRs)
% INTERPSIMXYZPR2BSEPR
%
%   Inputs:
%       XYZPRs - 5 x N element array
%
%   Outputs:
%       BSEPRs - 5 x N element array
%
%   M. Kutzer, 31Aug2020, USNA

%% Check inputs
% TODO - check inputs

%% Convert
warning off
BSEPRs = zeros( size(XYZPRs) );
for i = 1:size(XYZPRs,2)
    XYZPR = XYZPRs(:,i).';
    BSEPR = ScorXYZPR2BSEPR(XYZPR);
    
    BSEPRs(:,i) = BSEPR.';
end
warning on