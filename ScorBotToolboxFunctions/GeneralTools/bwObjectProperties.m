function [A,centroid,phi,H1,H2] = bwObjectProperties(varargin)
% BWOBJECTPROPERTIES calculates the centroid, principal angle, and Hu's 1st
% and 2nd moment invariants for an object in a binary image.
%   [A,centroid,phi,H1,H2] = bwObjectProperties(M00,M10,M01,M11,M20,M02) 
%   calculates the centroid, principal angle, and Hu's 1st and 2nd moment 
%   invariants given a set of image moments for an object in a binary
%   image.
%
%   [A,centroid,phi,H1,H2] = bwObjectProperties(BW) calculates the 
%   centroid, principal angle, and Hu's 1st and 2nd moment invariants given
%   an object in a binary image.
% 
%   Function Outputs
%       A - object area (pixels)
%       centroid - object centroid [row_c; col_c] (pixels)
%       phi - object principal angle [-pi/2,pi/2] referenced relative to 
%             the vertical "downward" direction (radians)
%       H1 - Hu's 1st Moment Invariant
%       H2 - Hu's 2nd Moment Invariant
%
%   M. Kutzer, 28Nov2016, USNA

%% Check inputs
switch nargin
    case 1
        % Assume the input is a single binary image
        BW = varargin{1};
        % Check for valid binary image
        if ~isBinaryImage(BW)
            error('Specificed input must be an MxN binary image');
        end
        % Calculate image moments
        [M00,M10,M01,M11,M20,M02] = bwObjectMoments(BW);
    case 6
        % Assume the input are the 0th, 1st, and 2nd order Image Moments
        M00 = varargin{1};
        M10 = varargin{2};
        M01 = varargin{3};
        M11 = varargin{4};
        M20 = varargin{5};
        M02 = varargin{6};
        % TODO - check that Mij is scalar.
    otherwise
        error('Specified input(s) must either be a single binary image or image moments.');
end

%% Calculate area 
A = M00;

%% Calculate Centroid
row_c = M10/M00;
col_c = M01/M00;
centroid = [row_c; col_c];

%% Calculate Principal Angle
mu00 = M00;
mu11 = M11 - (M01*M10)/M00;
mu20 = M20 - (M10*M10)/M00;
mu02 = M02 - (M01*M01)/M00;

phi = (1/2)*atan2(2*mu11,mu20-mu02);

%% Calculate Hu's moments
v11 = mu11/(mu00^((1+1+2)/2));
v20 = mu20/(mu00^((2+0+2)/2));
v02 = mu02/(mu00^((0+2+2)/2));

H1 = v20 + v02 + 1/(6*M00);
H2 = (v20-v02)^2 + 4*v11^2;