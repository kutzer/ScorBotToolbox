function gOffset = ScorSimGetGripperOffset(sim)
% SCORSIMGETGRIPPEROFFSET calculates the distance between the gripper
% fingertip and the end-effector frame along the end-effector z-axis (mm).
%
%   See also ScorSimSetGripper ScorSimGetGripper
%
%   M. Kutzer, 31Jan2016, USNA

%% Get gripper 
grip = ScorSimGetGripper(sim);

%% Calculate closed gripper angle
g0 = 34.00+21.6-0.028; % this value must match in get and set command (sim)
o = (-g0)/2;
h = 47.22; % this value must match in get and set command (sim)

ang0 = -asin(o/h);

%% Calculate current gripper angle
g0 = 34.00+21.6-0.028; % this value must match in get and set command (sim)
%gPad = 5.56; % gripper pad thickness (mm)
o = (grip - g0)/2;% + gPad;
h = 47.22; % this value must match in get and set command (sim)

ang = -asin(o/h);

%% Calculate offset
gOffset = h*(cos(ang) - cos(ang0));