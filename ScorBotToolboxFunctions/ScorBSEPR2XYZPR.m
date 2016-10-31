function XYZPR = ScorBSEPR2XYZPR(varargin)
% SCORBSEPR2XYZPR converts joint angles to task variables.
%   XYZPR = SCORBSEPR2XYZPR(BSEPR) converts the 5-element joint-space 
%   vector containing joint angles ordered from the base up to the 
%   5-element task-space vector containing the end-effector x,y,z 
%   position, and end-effector pitch and roll.
%   orientation.
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%       XYZPR - 5-element vector containing end-effector position and
%       orientation.
%           XYZPR(1) - end-effector x-position in millimeters
%           XYZPR(2) - end-effector y-position in millimeters
%           XYZPR(3) - end-effector z-position in millimeters
%           XYZPR(4) - end-effector wrist pitch in radians
%           XYZPR(5) - end-effector wrist roll in radians
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also ScorGetBSEPR ScorSetXYZPR ScorDHtable
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorDeg2X.m"
%       
%   M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   01Sep2015 - Removed commented old method
%   23Dec2015 - Updated to varargin to clarify errors.
%   23Dec2015 - Updated to clarify errors.
%   31Oct2016 - Added "Todo" for use with symbolic variables

%% Check inputs
% This assumes nargin is fixed to 1 with a set of common errors:
%   e.g. ScorSetBSEPR2XYZPR(theta1,theta2,theta3,theta4,theta5);

% Check for zero inputs
if nargin < 1
    error('ScorX2Y:NoBSEPR',...
        ['Joint configuration must be specified.',...
        '\n\t-> Use "ScorBSEPR2XYZPR(BSEPR)".']);
end
% Check BSEPR
if nargin >= 1
    BSEPR = varargin{1};
    % TODO - make this work with symbolic variables
    %   -> Consider removing isnumeric()...
    if ~isnumeric(BSEPR) || numel(BSEPR) ~= 5
        error('ScorX2Y:BadBSEPR',...
            ['Joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "ScorBSEPR2XYZPR([Joint1,Joint2,...,Joint5])".']);
    end
end
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Calculate XYZPR
H = ScorBSEPR2Pose(BSEPR);
XYZPR(1) = H(1,4);
XYZPR(2) = H(2,4);
XYZPR(3) = H(3,4);
XYZPR(4) = wrapToPi( sum(BSEPR(2:4)) );
XYZPR(5) = BSEPR(5);
