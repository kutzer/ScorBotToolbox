%% SCRIPT_TestErrorLogs
% This script exercises the various methods for moving ScorBot to test
% the ScorErrorLog* functions.
%
%   M. Kutzer, USNA, 03Oct2018

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
    h = msgbox('Select "OK" to cancel the test procedure.','Cancel Warmup','custom',icondata,iconcmap);
catch
    h = msgbox('Select "OK" to cancel the test Warmup procedure.','Cancel Warmup','warn');
end

%% Loop through move types
% ScorSet*      - {BSEPR, XYZPR, Pose}, {'LinearTask','LinearJoint'}
% ScorSetDelta* - {BSEPR, XYZPR, Pose}, {'LinearTask','LinearJoint'}
funcBase = {'ScorSet','ScorSetDelta'};
funcModf = {'BSEPR', 'XYZPR', 'Pose','Gripper'};
moveType = {'LinearTask','LinearJoint'};

% Set speed to 100%
ScorSetSpeed(100);
while ishandle(h)
    % Consider each type of move function
    for i = 1:numel(funcBase)
        % Consider each type modifier
        for j = 1:numel(funcModf)
            func = eval( sprintf('@%s%s',funcBase{i},funcModf{j}) );
            % Consider each move type
            for k = 1:numel(moveType)
                % ---------------------------------------------------------
                % Create "safe" random joint configuration
                % ---------------------------------------------------------
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
                % ---------------------------------------------------------
                
                % Define appropriate command (absolute or delta)
                switch funcBase{i}
                    case 'ScorSet'
                        isDelta = false;
                    case 'ScorSetDelta'
                        isDelta = true;
                        % Get current BSEPR
                        BSEPR_now = ScorGetBSEPR;
                    otherwise
                        error('Unknown function base type.');
                end
                
                % Define appropriate function input
                isGripper = false;
                switch funcModf{j}
                    case 'BSEPR'
                        if ~isDelta
                            funcInput = BSEPR_go;
                        else
                            funcInput = BSEPR_go - BSEPR_now;
                        end
                    case 'XYZPR'
                        if ~isDelta
                            funcInput = ScorBSEPR2XYZPR(BSEPR_go);
                        else
                            funcInput = ScorBSEPR2XYZPR(BSEPR_go) - ScorBSEPR2XYZPR(BSEPR_now);
                        end
                    case 'Pose'
                        if ~isDelta
                            funcInput = ScorBSEPR2Pose(BSEPR_go);
                        else
                            funcInput = (ScorBSEPR2Pose(BSEPR_now)^-1)*ScorBSEPR2Pose(BSEPR_go);
                        end
                    case 'Gripper'
                        if isequal(moveType{k},'LinearJoint')
                            % Ignore linear joint for gripper
                            continue
                        end
                        if ~isDelta
                            isGripper = true;
                            funcInput = round( 70*rand(1,1) );
                        else
                            % Ignore delta movement for gripper
                            continue
                        end
                    otherwise
                        error('Unknown function input type.');
                end
                
                % Execute Command
                if ~isGripper
                    fprintf(' -> Executing %s%s(...,''MoveType'',''%s'')\n',funcBase{i},funcModf{j},moveType{k});
                    func(funcInput,'MoveType',moveType{k});
                else
                    fprintf(' -> Executing %s%s(...)\n',funcBase{i},funcModf{j});
                    func(funcInput);
                end
                ScorWaitForMove;
                
                % Check for error(s) and try to recover
                [isReady,~,errStruct] = ScorIsReady;
                % Respond to error codes
                rehome = false;
                if errStruct.Code ~= 0
                    switch errStruct.QuickFix
                        case 'ScorHome;'
                            rehome = true;
                        case 'ScorSetControl(''On'');'
                            rehome = true;
                        otherwise
                            eval(errStruct.QuickFix);
                    end
                    % Home if necessary
                    if rehome
                        % Rehome ScorBot
                        ScorHome(true);
                    end
                    
                end
                % Allow pop-up to update/disapear
                drawnow
            end % moveType
        end % funcModf 
    end % funcBase
end % while



