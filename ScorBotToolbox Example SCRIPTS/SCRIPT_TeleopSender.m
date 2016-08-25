%% SCRIPT_TeleopSender

%% Initialize senders
IP = '10.52.21.255';
ports = [31001,31002,31003];
for i = 1:numel(ports)
    udpS{i} = ScorInitSender(ports(i),IP);
end

%% Define desired waypoints as end-point XYZPR positions/orientations
XYZPRs(1,:) = [500.000,-200.000,570.000,0.000,-2*pi/2];
XYZPRs(2,:) = [500.000, 200.000,570.000,0.000,-1*pi/2];
XYZPRs(3,:) = [500.000, 200.000,270.000,0.000, 0*pi/2];
XYZPRs(4,:) = [500.000,-200.000,270.000,0.000, 1*pi/2];
XYZPRs(5,:) = [500.000,-200.000,570.000,0.000, 2*pi/2];

%% Define gripper positions
grips = [0; 70; 35; 70; 0];

%% Convert XYZPR waypoints to BSEPR joint configurations
for wpnt = 1:size(XYZPRs,1)
    BSEPRs(wpnt,:) = ScorXYZPR2BSEPR(XYZPRs(wpnt,:));
end

%% Send waypoints
while true
    for wpnt = 1:size(BSEPRs,1)
        for i = 1:numel(udpS)
            ScorSendBSEPRG(udpS{i},BSEPRs(wpnt,:),grips(wpnt));
        end
    end
end