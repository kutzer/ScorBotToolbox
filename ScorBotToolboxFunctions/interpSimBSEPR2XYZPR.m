function XYZPRs = interpSimBSEPR2XYZPR(BSEPRs)
% INTERPSIMBSEPR2XYZPR
%
%   Inputs:
%       BSEPRs - 5 x N element array
%
%   Outputs:
%       XYZPRs - 5 x N element array
%
%   M. Kutzer, 31Aug2020, USNA

%% Check inputs
% TODO - check inputs

%% Convert
warning off
XYZPRs = zeros( size(BSEPRs) );
for i = 1:size(XYZPRs,2)
    BSEPR = BSEPRs(:,i).';
    XYZPR = ScorBSEPR2XYZPR(BSEPR);
    
    XYZPRs(:,i) = XYZPR.';
end
warning on