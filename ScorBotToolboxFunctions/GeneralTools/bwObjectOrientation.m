function phi = bwObjectOrientation(BW,orientMethod)
% BWOBJECTORIENTATION calculates the orientation of an object in a binary
% image relative to the vertical "downward" direction (+ row direction of
% the Matrix Frame). Angles returned are constrained to [-pi/2,pi/2].
%   phi = BWOBJECTORIENTATION(BW) calculates the orientation of the
%   object using the Hough transform.
%
%   phi = BWOBJECTORIENTATION(BW,orientMethod) calculates the orientation
%   of the object using a specified method.
%
%   Acceptable orientation methods:
%                'Hough' - uses the Hough transform [Default]
%       'PrincipalAngle' - uses the principal angle defined using central
%                          moments.
%
%   J. Conroy & M. Kutzer 28Nov2016, USNA

% Updates:
%   28Nov2016 - Updated to make uniform angle output in radians (M. Kutzer)

%% Check inputs
% Check number of input arguments
narginchk(1,2)
% Set default method (if unspecified)
if nargin < 2
    orientMethod = 'hough';
end
% Check for valid binary image
if ~isBinaryImage(BW)
    error('Specificed input must be an MxN binary image');
end

%% Apply specified method
switch lower(orientMethod)
    case 'hough'
        % Buffer image with zeros
        [M,N] = size(BW);
        BW_buffered = zeros(M+2, N+2);
        BW_buffered(2:(M+1),2:(N+1)) = BW;
        % Calculate orientation using Hough Transform
        BW_edge = edge(BW_buffered,'canny');
        [H,theta,rho] = hough(BW_edge);
        P = houghpeaks(H,4);
        lines = houghlines(BW_edge,theta,rho,P);
        
        try
            phi = deg2rad( lines(1).theta );
        catch
            warning('Hough Transform did not yield a solution. Using Principal Angle instead.');
            [~,~,phi,~,~] = bwObjectProperties(BW);
        end
        
    case 'principalangle'
        [~,~,phi,~,~] = bwObjectProperties(BW);
    otherwise
        % TODO - improve error handling
        error('bwObjectOrientation:BadType','"%s" is not an acceptable method.',orientMethod);
end

