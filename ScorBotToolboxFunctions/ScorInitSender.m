function udpS = ScorInitSender(port,IP)
% SCORINITSENDER initializes a UDP server for transmitting ScorBot 
% information to a remote client.
%   udpS = ScorInitSender(port) creates a UDP Sender tied to the designated
%   port (suggested ports 31000 - 32000) using a default IP.
%
%   udpS = ScorInitSender(port,IP) creates a UDP Sender tied to the 
%   designated port (suggested ports 31000 - 32000) using a specified IP.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also ScorInitReceiver ScorSendBSEPR ScorReceiveBSEPR
%
%   M. Kutzer, 12Apr2016, USNA

% Updates
%   23Aug2016 - Updated help documentation.

% TODO - add notes about broadcast IP
% TODO - add example IPs
% TODO - add examples

%% Set default IP
if nargin < 2
    % Set to broadcast
    % NOTE: This IP should be tied to your network IP
    IP = '10.52.21.255';
end

%% Check inputs
% TODO - check port range
% TODO - check for valid IP

%% Create UDP Sender
udpS = dsp.UDPSender(...
    'RemoteIPAddress',IP,...
    'RemoteIPPort',port);