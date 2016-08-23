function confirm = ScorGoHome()
% SCORGOHOME moves ScorBot to the home position
%   SCORGOHOME moves ScorBot to the home position. This function does not
%   run the homing sequence. 
%
%   confirm = SCORGOHOME(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorHome
%
%   M. Kutzer, 10Aug2015, USNA

%% ScorBot XYZPR home position [mm, mm, mm, rad, rad]
XYZPRhome = [169.300,0.000,504.328,-1.10912,0.00000];

%% Go home
fprintf('Moving ScorBot to home position...');
isMovedHome = ScorSetXYZPR(XYZPRhome,'MoveType','LinearJoint');
if isMovedHome
    isComplete = ScorWaitForMove;
else
    isComplete = false;
end

%% Check possible errors
if ~isMovedHome || ~isComplete
    fprintf('FAILED\n');
    confirm = false;
    if nargout == 0
        warning('ScorBot failed to move to the home position.');
    end
    return
else
    fprintf('SUCCESS\n');
    confirm = true;
end