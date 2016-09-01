%% Initialize and home ScorBot
% Note: You only need to run this once! If you already ran ScorInit and
% ScorHome, you do not need to run them again.
ScorInit;
ScorHome;

%% CCC
clear all
close all
clc

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
[~,h,sData] = ScorWaitForMove('RobotAnimation','On','CollectData','On');
ScorSimPatch(h.RobotAnimation.Sim);

%% Cleanup plot
set(h.RobotAnimation.Plot,'XData',[],'YData',[],'ZData',[]);

%% Move through end-point XYZPR positions/orientations
title(h.RobotAnimation.Sim.Axes,'Movements using ScorSetXYZPR');
fprintf('Demonstrating XYZPR move with Animation Plots.\n');
for wpnt = 1:size(XYZPRs,1)
    ScorSetXYZPR(XYZPRs(wpnt,:));
    [~,h,sData(end+1)] = ScorWaitForMove('RobotAnimation','On','PlotHandle',h,'CollectData','On');
end
plot3(h.RobotAnimation.Sim.Axes,XYZPRs(1:4,1),XYZPRs(1:4,2),XYZPRs(1:4,3),'*k');

%% Go Home
XYZPRhome = [169.300,0.000,504.328,-1.10912,0.00000];
ScorSetXYZPR(XYZPRhome);
[~,h,sData(end+1)] = ScorWaitForMove('RobotAnimation','On','PlotHandle',h,'CollectData','On');

%% Append Data
% Estimate dt
t_current = 0;
dt = 0.15;
tBSEPR = [];
for i = 1:numel(sData)
    delta = zeros(size(sData(i).tBSEPR));
    if i > 1
        delta(:,1) = t_current + dt;
    else
        delta(:,1) = t_current;
    end
    tBSEPR = [tBSEPR; sData(i).tBSEPR + delta];
    t_current = tBSEPR(end,1);
end

%% Plot data
fig = figure;
axs = axes;
hold on
xlabel('Time (s)');
ylabel('Joint Angles');
for i = 1:5
    plot(tBSEPR(:,1),tBSEPR(:,i+1),'Color',rand(1,3));
end
legend('\theta_1','\theta_2','\theta_3','\theta_4','\theta_5');

%% Animate
sim = ScorSimInit;
ScorSimPatch(sim);
dt = diff(tBSEPR(:,1));
for i = 1:size(tBSEPR,1)
    ScorSimSetBSEPR(sim,tBSEPR(i,2:6));
    pause(dt);
end

%% Interpolate
close all
clearvars -except tBSEPR
t = tBSEPR(:,1);
BSEPRs = tBSEPR(:,2:end);

%% Spline fit
for i = 1:5
    pp(i) = spline(t,BSEPRs(:,i));
end

%% Create 10 Hz, 20 Hz, and 30 Hz data set
t_10Hz = 0:(1/10):t(end);
t_20Hz = 0:(1/20):t(end);
t_30Hz = 0:(1/30):t(end);

for i = 1:5
    BSEPR_10Hz(:,i) = ppval(pp(i),t_10Hz);
    BSEPR_20Hz(:,i) = ppval(pp(i),t_20Hz);
    BSEPR_30Hz(:,i) = ppval(pp(i),t_30Hz);
end

%% Check data
x = {t, t_10Hz, t_20Hz, t_30Hz};
y = {BSEPRs,BSEPR_10Hz,BSEPR_20Hz,BSEPR_30Hz};
for ii = 1:numel(x)
    fig = figure;
    axs = axes;
    hold on
    xlabel('Time (s)');
    ylabel('Joint Angles');
    for i = 1:5
        plot(x{ii},y{ii}(:,i),'Color',rand(1,3));
    end
    legend('\theta_1','\theta_2','\theta_3','\theta_4','\theta_5');
end

%% Cleanup workspace and save
close all
clearvars -except tBSEPR t BSEPRs t_10Hz t_20Hz t_30Hz BSEPR_10Hz BSEPR_20Hz BSEPR_30Hz
save('ScorBotBoxData.mat');

%% Create real-time video
vidTitle = sprintf('ScorBotBoxData.mp4');
vidObj = VideoWriter(vidTitle,'MPEG-4');
open(vidObj);

% Create simulation
sim = ScorSimInit;
ScorSimPatch(sim);
% Hide reference frames
hideTriad(sim.Frames);
% Hide axes and set figure background to white
set(sim.Axes,'Visible','off');
set(sim.Figure,'Color',[1,1,1]);

for i = 1:size(BSEPR_30Hz,1)
    ScorSimSetBSEPR(sim,BSEPR_30Hz(i,:));
    % Update frame
    drawnow
    frame = getframe(sim.Figure);
    writeVideo(vidObj,frame);
end

% Close video obj
close(vidObj);

%% Safe shutdown
% Note: You only need to run this when you are finished using MATLAB or
% finished using ScorBot! If you run ScorSafeShutdown and still need to use
% ScorBot, you will need to reinitialize using ScorInit, and rehome using
% ScorHome.
ScorSafeShutdown;
