function [BSEPR,grip] = ScorReceiveBSEPRG(udpR)
% SCORRECEIVEBSEPRG receives a BSEPR value and gripper state from a port 
% designated by a UDP receiver object.
%   [BSEPR,grip] = ScorSendBSEPRG(udpS) receives a BSEPR value and gripper 
%   state from a port designated by a UDP receiver object specified in 
%   udpR.
% 
%   Note: If no value is received or message contains an invalid vector,
%   this function will return an empty set.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also ScorInitSender ScorInitReceiver ScorSendBSEPRG ScorTeleop
%
%   M. Kutzer, 12Apr2016, USNA

% Updates
%   23Aug2016 - Clarified variable names and error messages and added
%               gripper state.
%   25Aug2016 - Updated to check for inputs.

%% Check inputs
% TODO - improve error handling
narginchk(1,1);

%% Check UDP Receiver
switch class(udpR)
    case 'dsp.UDPReceiver'
        % Valid UDPReceiver
    otherwise
        error('ScorReceive:BadReceiver',...
            ['Specified UDP Receiver must be valid.',...
             '\n\t-> Use "udpR = ScorInitReceiver(port);" with a valid port ',...
             '\n\t   number to create a valid UDP Receiver.']);
end

%% Receive message
% TODO - improve message handling
% Receive message
dataReceived = step(udpR);
% Convert message
msg_Rsvd = char(dataReceived');
% Parse message
BSEPRG = str2num(msg_Rsvd);

%% Check message
if ~isnumeric(BSEPRG) || numel(BSEPRG) ~= 6
    BSEPR = []; % return an empty set
    grip = [];  % return an empty set
    return
end

%% Package output
BSEPR = BSEPRG(1:5);
grip = BSEPRG(6);
