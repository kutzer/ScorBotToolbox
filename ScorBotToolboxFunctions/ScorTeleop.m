function ScorTeleop(port)
% SCORTELEOP defines a UDP client for receiving ScorBot information
% from to a remote server and executes the commands as they are received.
%   SCORTELEOP(port) initializes a UDP Receiver tied to the 
%   designated port (suggested ports 31000 - 32000) using a default IP of
%   '0.0.0.0' allowing data to be accepted from any remote IP address. As
%   commands are received, they are executed on the connected ScorBot
%   hardware.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also ScorInitSender ScorInitReceiver ScorSendBSEPRG
%   ScorReceiveBSEPRG
%
%   M. Kutzer, 25Aug2016, USNA

%% Check inputs
% TODO - improve error handling
narginchk(1,1);
% TODO - check port range

%% Create receiver
udpR = ScorInitReceiver(port);

%% Setup past/present command structure
grips = nan(2,1);  % Initialize grips for t-1 and t
BSEPRs = nan(2,5); % Initialize BSEPRs for t-1 and t

%% Loop to respond to commands
% Show waiting for move message
ITER = 0;
fprintf('\nWaiting for command...');
while true
    [BSEPR,grip] = ScorReceiveBSEPRG(udpR);
    if ~isempty(BSEPR) && ~isempty(grip)
        % Reset "waiting" statement
        fprintf( char(repmat(8,1,mod(ITER-1,4))) );
        fprintf('...');
        fprintf('RECEIVED\n');
        ITER = 0;
        % Update past/present BSEPR and gripper states
        BSEPRs(1,:) = BSEPRs(2,:);
        BSEPRs(2,:) = BSEPR;
        grips(1) = grips(2);
        grips(2) = grip;
        % Move to joint position if new joint position was received
        if ~isequal(BSEPRs(1,:),BSEPRs(2,:))
            % Execute joint move
            % TODO - send joint vs task movement information
            ScorSetBSEPR(BSEPRs(2,:));
            % Display progress
            iter = 0;
            fprintf('Executing joint movement...');
            while ScorIsMoving
                if mod(iter,4) == 0
                    fprintf(char([8,8,8]));
                else
                    fprintf('.');
                end
                iter = iter+1;
            end
            fprintf( char(repmat(8,1,mod(iter-1,4))) );
            fprintf('...');
            fprintf('SUCCESS\n');
        end
        % Move to gripper position if new gripper position was received
        if ~isequal(grips(1,:),grips(2,:))
            % Execute gripper move
            ScorSetGripper(grips(2,:));
            % Display progress
            iter = 0;
            fprintf('Executing gripper movement...');
            while ScorIsMoving
                if mod(iter,4) == 0
                    fprintf(char([8,8,8]));
                else
                    fprintf('.');
                end
                iter = iter+1;
            end
            fprintf( char(repmat(8,1,mod(iter-1,4))) );
            fprintf('...');
            fprintf('SUCCESS\n');
        end
        % Show waiting for move message
        fprintf('Waiting for command...');
    else
        % Show progress
        if mod(ITER,4) == 0
            fprintf(char([8,8,8]));
        else
            fprintf('.');
        end
        ITER = ITER+1;
    end
end
        
                
