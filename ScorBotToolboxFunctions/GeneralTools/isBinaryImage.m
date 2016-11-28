function tf = isBinaryImage(BW)
% ISBINARYIMAGE returns a 1 if the input array is a valid binary image and
% a 0 otherwise.
%   tf = ISBINARYIMAGE(BW) returns a 1 if the input array is a valid binary
%   image and a 0 otherwise.
%
%   M. Kutzer, 28Nov2016, USNA

% Set default output value
tf = true; 

% Check for single input
if nargin ~= 1
    tf = false;
    return
end

% Check for MxN matrix
if ~ismatrix(BW)
    tf = false;
    return
end
% Check for round values
if ~isequal(BW,round(BW))
    tf = false;
    return
end

% Check for maximum value <= 1
if max( reshape(BW,1,[]) ) > 1
    tf = false;
    return
end

% Check for minimum value >= 0
if min( reshape(BW,1,[]) ) < 0
    tf = false;
    return
end