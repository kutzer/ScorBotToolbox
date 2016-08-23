function XYZPR = ScorGetXYZPR()
% SCORGETXYZPR gets the current end-effector x,y,z position and pitch,roll 
% orientation.
%   XYZPR = ScorGetXYZPR gets the 5-element task-space vector containing 
%   the current end-effector x,y,z position, and end-effector pitch and roll
%   orientation. An empty set is returned if there is an error during 
%   function call. 
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
%   See also ScorSetXYZPR ScorSetBSEPR ScorGetBSEPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorGetCart.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated error handling
%   25Sep2015 - Ignore isReady flag

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
% if ~isReady
%     XYZPR = [];
%     return
% end

%% Define variables for library function call
confirm = 0;
x = 0.0; % x-position in micrometers
y = 0.0; % y-position in micrometers
z = 0.0; % z-position in micrometers
p = 0.0; % end-effector wrist pitch in 1/1000's of a degree
r = 0.0; % end-effector wrist roll in 1/1000's of a degree

%% Get XYZPR
try
    [confirm,x,y,z,p,r]=calllib(libname,'RGetXYZPR',x,y,z,p,r);
    if confirm
        XYZPR(1) = x*1e-3; % end-effector x-position in millimeters
        XYZPR(2) = y*1e-3; % end-effector y-position in millimeters
        XYZPR(3) = z*1e-3; % end-effector z-position in millimeters
        XYZPR(4) = deg2rad(p*1e-3); % end-effector pitch in radians
        XYZPR(5) = deg2rad(r*1e-3); % end-effector roll in radians
    else
        XYZPR = [];
        warning('"calllib(''%s'',''RGetXYZPR'',...", failed to return a positive confirmation.',libname);
    end
catch
    XYZPR = [];
    warning('Error with "calllib(''%s'',''RGetXYZPR'',...", no values returned.',libname);
end