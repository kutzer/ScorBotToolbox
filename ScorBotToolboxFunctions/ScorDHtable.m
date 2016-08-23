function DHtable = ScorDHtable(BSEPR)
% SCORDHTABLE creates a DH table for the ScorBot following the 
% Denavit–Hartenberg convention.
%   DHtable = SCORDHTABLE() creates a DH table associated with joint angles
%   of zero. Lengths are given in millimeters, angles are given in radians.
%
%   DHtable = SCORDHTABLE(BSEPR) creates a DH table associated with joint
%   angles contained in the 5-element vector BSEPR. Lengths are given in 
%   millimeters, angles are given in radians.
%
%       DHtable = [theta_0,d_0,a_0,alpha_0; 
%                  theta_1,d_1,a_1,alpha_1;
%                  ...
%                  theta_N,d_N,a_N,alpha_N];
%
%   Recall:
%       H01 = Rz(theta_0)*Tz(d_0)*Tx(a_0)*Rx(alpha_0)
%       H12 = Rz(theta_1)*Tz(d_1)*Tx(a_1)*Rx(alpha_1)
%       ...
%       HNe = Rz(theta_N)*Tz(d_N)*Tx(a_N)*Rx(alpha_N)
%
%   See also ScorBSEPR2Pose
%       
%   M. Kutzer, 10Aug2015, USNA

%% Check inputs
narginchk(0,1);

if nargin < 1
    BSEPR = zeros(1,5);
end
if numel(BSEPR) ~= 5;
    error('Joint angle vector must be a 5-element array.');
end

%% Create DH table
theta(1,1) = BSEPR(1);      % theta0* in radians
theta(2,1) = BSEPR(2);      % theta1* in radians
theta(3,1) = BSEPR(3);      % theta2* in radians
theta(4,1) = BSEPR(4)+pi/2; % theta3* in radians (additional pi/2 to correctly align zero-configuration)
theta(5,1) = BSEPR(5);      % theta4* in radians

d(1,1) = 349.000; % d0 in millimeters
d(2,1) =   0.000; % d1 in millimeters
d(3,1) =   0.000; % d2 in millimeters
d(4,1) =   0.000; % d3 in millimeters
d(5,1) = 145.125; % d4 in millimeters

a(1,1) =  16.000; % a0 in millimeters
a(2,1) = 221.000; % a1 in millimeters
a(3,1) = 221.000; % a2 in millimeters
a(4,1) =   0.000; % a3 in millimeters
a(5,1) =   0.000; % a4 in millimeters

alpha(1,1) =  pi/2; % alpha0 in radians
alpha(2,1) =     0; % alpha1 in radians
alpha(3,1) =     0; % alpha2 in radians
alpha(4,1) =  pi/2; % alpha3 in radians
alpha(5,1) =     0; % alpha4 in radians

DHtable = [theta, d, a, alpha];
