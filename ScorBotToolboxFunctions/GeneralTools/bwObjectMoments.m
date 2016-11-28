function [M00,M10,M01,M11,M20,M02] = bwObjectMoments(BW)
% BWOBJECTMOMENTS calculates the 0th, 1st, and 2nd order image moments an 
% object in a binary image.
%   [M00,M10,M01,M11,M20,M02] = BWOBJECTMOMENTS(ImBinary) calculates the 
%   0th, 1st, and 2nd order image moments an object in a binary image.
%       0th order Image Moment  - M00
%       1st order Image Moments - M10, M01
%       2nd order Image Moments - M11, M20, M02
%
%   M. Kutzer 28Nov2016, USNA

%% Check inputs
% Check for single input
narginchk(1,1);
% Check for valid binary image
if ~isBinaryImage(BW)
    error('Specificed input must be an MxN binary image');
end

%% Calculate Image Moments
[r,c] = find(BW);
% 0th Order Image Moment (i.e. Area)
M00 = sum( (r.^0).*(c.^0) );
% 1st Order Image Moments
M10 = sum( (r.^1).*(c.^0) );
M01 = sum( (r.^0).*(c.^1) );
% 2nd Order Image Moments
M11 = sum( (r.^1).*(c.^1) );
M20 = sum( (r.^2).*(c.^0) );
M02 = sum( (r.^0).*(c.^2) );