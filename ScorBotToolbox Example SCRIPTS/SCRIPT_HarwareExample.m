%% Initialize and home ScorBot
% Note: You only need to run this once! If you already ran ScorInit and
% ScorHome, you do not need to run them again.
ScorInit;
ScorHome;

%% Define desired waypoints as end-point XYZPR positions/orientations
XYZPRs(1,:) = [500.000,-200.000,570.000,0.000,-2*pi/2];
XYZPRs(2,:) = [500.000, 200.000,570.000,0.000,-1*pi/2];
XYZPRs(3,:) = [500.000, 200.000,270.000,0.000, 0*pi/2];
XYZPRs(4,:) = [500.000,-200.000,270.000,0.000, 1*pi/2];
XYZPRs(5,:) = [500.000,-200.000,570.000,0.000, 2*pi/2];

%% Convert XYZPR waypoints to BSEPR joint configurations
for wpnt = 1:size(XYZPRs,1)
    BSEPRs(wpnt,:) = ScorXYZPR2BSEPR(XYZPRs(wpnt,:));
end

%% Set speed and initialize arm configuration
ScorSetSpeed(100);
ScorSetXYZPR(XYZPRs(1,:));
ScorWaitForMove;

%% Move through end-point XYZPR positions/orientations
h = []; % initialize variable for plot handle
fprintf('Demonstrating XYZPR move with Animation Plots.\n');
for wpnt = 1:size(XYZPRs,1)
    ScorSetXYZPR(XYZPRs(wpnt,:));
    [~,h,sData(wpnt)] = ScorWaitForMove('RobotAnimation','On','PlotHandle',h,'CollectData','On');
    if wpnt == 1
        title(h.RobotAnimation.Sim.Axes,'Movements using ScorSetXYZPR');
        ScorSimPatch(h.RobotAnimation.Sim);
    end
end
plot3(h.RobotAnimation.Sim.Axes,XYZPRs(1:4,1),XYZPRs(1:4,2),XYZPRs(1:4,3),'*k');

%% Open Gripper
ScorSetGripper('Open');
ScorWaitForMove;

%% Move through BSEPR joint configurations
fprintf('Demonstrating BSEPR move with Animation Plots.\n');
title(h.RobotAnimation.Sim.Axes,'Movements using ScorSetBSEPR');
for wpnt = 1:size(BSEPRs,1)
    ScorSetBSEPR(BSEPRs(wpnt,:));
    [~,h,sData(wpnt)] = ScorWaitForMove('RobotAnimation','On','PlotHandle',h,'CollectData','On');
end
plot3(h.RobotAnimation.Sim.Axes,XYZPRs(1:4,1),XYZPRs(1:4,2),XYZPRs(1:4,3),'*k');

%% Open Gripper
ScorSetGripper('Close');
ScorWaitForMove;

%% Safe shutdown
% Note: You only need to run this when you are finished using MATLAB or
% finished using ScorBot! If you run ScorSafeShutdown and still need to use
% ScorBot, you will need to reinitialize using ScorInit, and rehome using
% ScorHome.
ScorSafeShutdown;
