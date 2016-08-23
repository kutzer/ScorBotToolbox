function BSEPR = ScorGetBSEPR()
% SCORGETBSEPR gets the current joint angles in radians.
%   BSEPR = SCORGETBSEPR gets the 5-element joint-space vector containing
%   joint angles ordered from the base up. An empty set is returned if 
%   there is an error in the function call. 
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also: ScorSetBSEPR ScorSetXYZPR ScorGetXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorGetBSEPR.m"
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
%     BSEPR = [];
%     return
% end

%% Define variables for library function call
confirm = 0;
B = 0.0; % end-effector base angle in 1/1000's of a degree
S = 0.0; % end-effector shoulder angle in 1/1000's of a degree
E = 0.0; % end-effector elbow angle in 1/1000's of a degree
P = 0.0; % end-effector wrist pitch in 1/1000's of a degree
R = 0.0; % end-effector wrist roll in 1/1000's of a degree

%%
try
    [confirm,B,S,E,P,R]=calllib(libname,'RGetBSEPR',B,S,E,P,R);
    if confirm
        BSEPR(1) =  deg2rad(B*1e-3); % end-effector base angle in radians
        BSEPR(2) = -deg2rad(S*1e-3); % end-effector shoulder angle in radians (sign change to match teach pendant)
        BSEPR(3) = -deg2rad(E*1e-3); % end-effector elbow angle in radians (sign change to match teach pendant)
        BSEPR(4) = -deg2rad(P*1e-3); % end-effector wrist pitch in radians (sign change to match teach pendant)
        BSEPR(5) =  deg2rad(R*1e-3); % end-effector wrist roll in radians
    else
        BSEPR = [];
        warning('"calllib(''%s'',''RGetBSEPR'',...", failed to return a positive confirmation.',libname);
    end
catch
    BSEPR = [];
    warning('Error with "calllib(''%s'',''RGetBSEPR'',...", no values returned.',libname); 
end