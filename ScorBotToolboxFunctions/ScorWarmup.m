function ScorWarmup(runtime)
% SCORWARMUP runs ScorBot through a series of movements to
% exercise the arm.
%   SCORWARMUP runs the specified warmup procedure for a default 1 minute.
%
%   SCORWARMUP(runtime) specifies the runtime in minutes, logging the user  
%   out when the warmup is complete.
%
%   M. Kutzer, 06Sep2018, USNA

% Updates:
%   03Oct2018 - Updated to incorporate new error logging functions.

%% Check inputs
if nargin < 1
    shutdownFlag = false;   % Do not shutdown robot when finished
    logoutFlag = false;     % Do not log user out when finished
    runtime = 1;            % Default run 
else
    shutdownFlag = true;    % Shutdown when finished
    logoutFlag = true;      % Log user out when finished
end
runtime = runtime * 60; % Convert to seconds

%% Check if robot is homed, home if not
[isReady,~,~] = ScorIsReady;
if ~isReady
    ScorInit;
    ScorHome(true);
end

%% Define set of joint limits
% NOTE: These joint limits are conservative for the USNA Introduction to
%       Robotics setup. For a more complete estimate of the ScorBot Joint
%       Limits when leveraging the ScorBot Toolbox, please see
%       ScorBSEPRLimits.
BSEPR(:,1) = deg2rad([ -30; 150]);  % Base Joint
BSEPR(:,2) = deg2rad([   0; 110]);  % Shoulder Joint
BSEPR(:,3) = deg2rad([-110; -10]);  % Elbow Joint
BSEPR(:,4) = deg2rad([-100;  80]);  % Wrist Pitch
BSEPR(:,5) = deg2rad([-180, 180]);  % Wrist Roll

%% Setup cancel window
try
    [icondata,iconcmap] = imread('Icon_ScorBot.png');
    h = msgbox('Select "OK" to cancel the warmup procedure.','Cancel Warmup','custom',icondata,iconcmap);
catch
    h = msgbox('Select "OK" to cancel the ScorBot Warmup procedure.','Cancel Warmup','warn');
end

%% Run warmup
t_check = 0;    % Initialize loop time
t_start = tic;  % Get reference time
ScorSetSpeed(100);
while ishandle(h) && (t_check <= runtime)
    % Initialize skip move flag
    skipMove = false;
    
    % ---------------------------------------------------------------------
    % Create "safe" random joint configuration
    % ---------------------------------------------------------------------
    % Create random joint configuration
    BSEPR_go = BSEPR(1,:) + (BSEPR(2,:)-BSEPR(1,:)) .* rand(1,5);
    % Convert to XYZPR for collision check
    XYZPR_go = ScorBSEPR2XYZPR(BSEPR_go);
    % Check for collision potential
    % -> Conservative table height
    if XYZPR_go(3) < 280
        skipMove = true;
    end
    % -> Check elbow/wrist issues
    if rad2deg(BSEPR_go(3)) < -90 && abs( rad2deg(BSEPR_go(4)) ) > 10
        skipMove = true;
    end
    % -> Check shoulder/elbow
    if rad2deg(BSEPR_go(2)) < 45 && rad2deg(BSEPR_go(3)) < -10
        skipMove = true;
    end
    % ---------------------------------------------------------------------
    
    % Move Robot
    if ~skipMove
        % Check robot and get current joint position and time
        [~,~,errStruct] = ScorIsReady;
        
        % Send waypoint to arm
        ScorSetBSEPR(BSEPR_go,'MoveType','LinearJoint');
        [isReady,~,errStruct] = ScorIsReady;
        
        % Wait for move
        isMoving = true;
        while (isMoving || ~isReady) && ishandle(h)
            % Allow pop-up to disapear if clicked
            drawnow
            
            % Check for moving and errors
            [isMoving,errStruct] = ScorIsMoving;
            
            % Respond to error codes
            if errStruct.Code ~= 0
                switch errStruct.QuickFix
                    case 'ScorHome;'
                        rehome = true;
                    case 'ScorSetControl(''On'');'
                        rehome = true;
                    otherwise
                        eval(errStruct.QuickFix);
                end
                
                if rehome
                    % Rehome ScorBot
                    ScorHome(true);
                end
                
            end
        end
    end
    
    drawnow;
    t_check = toc(t_start);
end


%% Shutdown robot and logout (if applicable)
if t_check > runtime
    % Safely shutdown the robot
    if shutdownFlag
        ScorSafeShutdown;
    end
    % Logout of the PC
    if logoutFlag
        ScorLogout;
    end
end
