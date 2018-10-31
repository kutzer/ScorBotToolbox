function ScorLabTest
% SCORLABTEST runs through common movements used by students during lab
% periods. The goal is to exercise the robot and confirm the hardware is
% working properly.
%
%   J. Bradshaw & M. Kutzer, USNA, 31Oct2018

%% Initialize and home the platform
[isReady,~,~] = ScorIsReady;
if ~isReady
    ScorInit;
    ScorHome(true);
end

%% Move ScorBot to various points in workspace
% Move to home position
ScorGoHome;
ScorWaitForMove;

% Update Speed
ScorSetSpeed(100);
pause(0.5);

% Move to starting configuration
BSEPR_start = [0,pi/2,-pi/2,-pi/2,0];
ScorSetBSEPR(BSEPR_start,'MoveType','LinearTask');
ScorWaitForMove;

% Move to "table height" (conservative value)
ScorSetDeltaXYZPR([0,0,-300,0,0]);
ScorWaitForMove;

% Get table height and xy "zero" positions
XYZPR = ScorGetXYZPR;
x0 = XYZPR(1);
y0 = XYZPR(2);
z0 = XYZPR(3);

%% Move to various positions
% NOTE: We are intentionally using the fastest wait possible (not
%       ScorWaitForMove to address Joel's "pause(2)" fix.

% Define "hover" height
z_hover = z0 + 50;
% Test fixed Base joint value (matching Lab 10)
%   Alternative option - B = linspace(-pi/3,pi/2,6)
B = pi/2;
% Define loop parameters
N_x = 4;
N_y = 3;
iter = 0;
for dx = linspace(-100,200,N_x)
    for dy = linspace(-100,100,N_y)
        % Set speed to 100 each time (redundant, but mimics student code)
        ScorSetSpeed(100);
        % Define BSEPR start point
        BSEPR = BSEPR_start;
        BSEPR(1) = B;
        BSEPR(5) = (rand(1) - 0.5)*pi;
        
        % Update user on progress
        fprintf('Movement %d of %d\n', iter+1, N_x*N_y);
        x = x0 + dx;
        y = y0 + dy;
        if dx >= 0 && dy >= 0
            fprintf('--> Linear Task move to XY = [%.1f, %.1f]\n',x,y);
            MoveType = 'LinearTask';
        else
            fprintf('--> Linear Joint move to XY = [%.1f, %.1f]\n',x,y);
            MoveType = 'LinearJoint';
        end
        
        % Move to start position
        fprintf('\t Move Status - Start, ');
        ScorSetBSEPR(BSEPR);
        while ScorIsMoving; end; % ScorWaitForMove
        
        % Move to "hover" point
        fprintf('Hover, ');
        XYZPR_hover = [x, y, z_hover, -pi/2, 0];
        ScorSetXYZPR(XYZPR_hover,'MoveType',MoveType);
        while ScorIsMoving; end; % ScorWaitForMove
        
        % Move to "mark" point
        fprintf('Mark, ');
        XYZPR_mark = [x, y, z0, -pi/2, 0];
        ScorSetXYZPR(XYZPR_mark);
        while ScorIsMoving; end; % ScorWaitForMove
        
        % Open Gripper
        fprintf('Open, ');
        ScorSetGripper('Open');
        while ScorIsMoving; end; % ScorWaitForMove
        
        % Close Gripper
        fprintf('Close, ');
        ScorSetGripper('Close');
        while ScorIsMoving; end; % ScorWaitForMove
        
        % Update status
        fprintf('COMPLETE\n');
        
        % Update iteration
        iter = iter + 1;
    end
end

ScorGoHome;
ScorWaitForMove;

%% Shutdown Robot
ScorSafeShutdown;

