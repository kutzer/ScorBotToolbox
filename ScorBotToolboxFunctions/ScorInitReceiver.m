function udpR = ScorInitReceiver(port)
% SCORINITRECEIVER defines a UDP client for receiving ScorBot information
% from to a remote server.
%   udpR = SCORINITRECEIVER(port) initializes a UDP Receiver tied to the 
%   designated port (suggested ports 31000 - 32000) using a default IP of
%   '0.0.0.0' allowing data to be accepted from any remote IP address.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also ScorInitSender ScorSendBSEPR ScorReceiveBSEPR
%
%   M. Kutzer, 12Apr2016, USNA

% Updates
%   23Aug2016 - Updated help documentation.

%% Check inputs
% TODO - check port range

%% Create UDP receiver
udpR = dsp.UDPReceiver('LocalIPPort',port);