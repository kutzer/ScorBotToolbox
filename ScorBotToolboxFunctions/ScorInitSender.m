function udpS = ScorInitSender(port,IP)
% SCORINITSENDER initializes a UDP server for transmitting ScorBot 
% information to a remote client.
%   udpS = ScorInitSender(port) creates a UDP Sender tied to the designated
%   port (suggested ports 31000 - 32000) using a default broadcast IP.
%
%   udpS = ScorInitSender(port,IP) creates a UDP Sender tied to the 
%   designated port (suggested ports 31000 - 32000) using a specified IP.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also ScorInitReceiver ScorSendBSEPRG ScorReceiveBSEPRG ScorTeleop
%
%   M. Kutzer, 12Apr2016, USNA

% Updates
%   23Aug2016 - Updated help documentation.
%   25Aug2016 - Updated to check for inputs.
%   25Aug2016 - Use getIPv4 to find the broadcast IP.


%% Check inputs
% TODO - improve error handling
narginchk(1,2);

%% Set default IP
if nargin < 2
    % Set to broadcast
    % NOTE: This IP should be tied to your network IP
    [~,IP] = getIPv4;
end

%% Check inputs
% TODO - check port range
% TODO - check for valid IP

%% Create UDP Sender
udpS = dsp.UDPSender(...
    'RemoteIPAddress',IP,...
    'RemoteIPPort',port);