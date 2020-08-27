%%SCRIPT Basic Simulation Test
%
%   M. Kutzer, 29Dec2015, USNA

% Updates
%   21Aug2020 - Updated to utilize automatic interpolation tools

fprintf('Testing ScorBot Toolbox simulation tools...\n');

%% Create simulation
simObj = ScorSimInit; % Create wire structure
ScorSimPatch(simObj); % Create 3D model

%% Define two joint configurations (excluding home positions)
BSEPRs(1,:) = ScorSimGetBSEPR(simObj);
BSEPRs(2,:) = [-pi/8, pi/2,-pi/2,-pi/2, pi/2];
BSEPRs(3,:) = [ pi/8, pi/2,-0.10,-pi/2,-pi/2];
BSEPRs(4,:) = ScorSimGetBSEPR(simObj);

%% Move Robot
ScorSimSetSpeed(simObj,100);
for ipnt = 1:size(BSEPRs,1)
    ScorSimSetBSEPR(simObj,BSEPRs(ipnt,:));
    ScorSimWaitForMove(simObj);
end

%% OLD METHOD
%{
%% Interpolate between waypoints for animation
n = 50;
BSEPR_all = [];
for jnt = 1:size(BSEPRs,2)
    for wpnt = 1:size(BSEPRs,1)-1
        BSEPR_all(n*(wpnt-1)+1:n*(wpnt-1)+n,jnt) = ...
            linspace(BSEPRs(wpnt,jnt),BSEPRs(wpnt+1,jnt),n);
    end
end

%% Move the simulation between waypoints and return home
for ipnt = 1:size(BSEPR_all,1)
    ScorSimSetBSEPR(simObj,BSEPR_all(ipnt,:));
end
%}
%% Open Gripper
for grip = 0:1.0:70
    ScorSimSetGripper(simObj,grip);
end

%% Close Gripper
for grip = 70:-1.0:0
    ScorSimSetGripper(simObj,grip);
end

%% Close figure
close(simObj.Figure);

%% End test
fprintf('[Complete]\n');