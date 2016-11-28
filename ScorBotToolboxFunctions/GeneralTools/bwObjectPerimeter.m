function rho = bwObjectPerimeter(BW)
% BWOBJECTPERIMETER calculates the perimeter of an object in a binary 
% image following the method described in ES450, Introduction to Robotic 
% Systems.
%   rho = BWOBJECTPERIMETER(BW) calculates the perimeter of an object in a
%   binary image.
%
%   M. Kutzer, 22Nov2016, USNA

%% Check inputs
% Check for single input
narginchk(1,1);
% Check for valid binary image
if ~isBinaryImage(BW)
    error('Specificed input must be an MxN binary image');
end

%% Calculate perimeter
% Buffer image with zeros
[M,N] = size(BW);
BW_buffered = zeros(M+2, N+2);
BW_buffered(2:(M+1),2:(N+1)) = BW;

% Calculate perimeter
rho = sum( reshape(abs(diff(BW_buffered )),1,[]) ) + ... % Absolute sum of row differences 
      sum( reshape(abs(diff(BW_buffered')),1,[]) );      % Absolute sum of column differences