function epsilon = bwObjectElongation(BW)
% BWOBJECTELONGATION calculates the elongation of an object in a binary 
% image following the method described in ES450, Introduction to Robotic 
% Systems.
%   rho = BWOBJECTELONGATION(BW) calculates the elongation of an object in
%   a binary image.
%
%   M. Kutzer, 22Nov2016, USNA

%% Check inputs
% Check for single input
narginchk(1,1);
% Check for valid binary image
if ~isBinaryImage(BW)
    error('Specificed input must be an MxN binary image');
end

%% Calculate area
A = sum( reshape(BW,1,[]) );

%% Calculate perimeter
rho = calculatePerimeter(BW);

%% Calculate elongation
epsilon = A /(rho^2);