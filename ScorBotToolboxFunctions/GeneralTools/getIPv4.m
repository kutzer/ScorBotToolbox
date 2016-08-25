function [localIP,broadcastIP] = getIPv4(varargin)
% GETIPV4 uses Java functionality to find the local IP and broadcast IP for
% wired connections.
%
%   Note: This function is still a work in progress.
%
%   M. Kutzer, 25Apr2016, USNA

%% Get local host, networkInterface, and interface addresses using java
% TODO - account for multiple network connections
localHost = java.net.Inet4Address.getLocalHost();
networkInterface = java.net.NetworkInterface.getByInetAddress(localHost);
if ~isempty(networkInterface)
    interfaceAddresses = networkInterface.getInterfaceAddresses();
else
    % No network connection found
    localIP = [];
    broadcastIP = [];
    return
end

%% Select interface address
idx = 1;
interfaceAddress = interfaceAddresses(idx);
% Convert to string
interfaceAddress = char(interfaceAddress);

%% Parse interfaceAddress
out = sscanf(interfaceAddress,'[/%d.%d.%d.%d/%d [/%d.%d.%d.%d]',[1,9]);

localIP = sprintf('%d.%d.%d.%d',out(1:4));
broadcastIP = sprintf('%d.%d.%d.%d',out(6:9));