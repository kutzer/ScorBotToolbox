function ScorSendBSEPRG(udpS,BSEPR,grip)
% SCORSENDBSEPRG sends the current or a specified BSEPR value and gripper
% state.
%   SCORSENDBSEPRG(udpS) sends the current BSEPR value and gripper state 
%   from ScorBot to the UDP sender specified in udpS.
%
%   SCORSENDBSEPRG(udpS,BSEPR) sends the specified BSEPR value and current 
%   gripper state to the UDP sender specified in udpS.
%
%   SCORSENDBSEPRG(udpS,BSEPR,grip) sends the specified BSEPR value and
%   specified gripper state to the UDP sender specified in udpS.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also ScorInitSender ScorInitReceiver ScorReceiveBSEPRG ScorTeleop
%
%   M. Kutzer, 12Apr2016, USNA

% Updates
%   23Aug2016 - Clarified variable names and error messages and added
%               gripper state.
%   25Aug2016 - Updated to check for inputs.
%   01Sep2016 - Error correction in error checking

%% Check inputs
% TODO - improve error handling
narginchk(1,3);

%% Check UDP Sender
switch class(udpS)
    case 'dsp.UDPSender'
        % Valid UDPSender
    otherwise
        error('ScorSend:BadSender',...
            ['Specified UDP Sender must be valid.',...
             '\n\t-> Use "udpS = ScorInitSender(port);" with a valid port ',...
             '\n\t   number to create a valid UDP Sender.']);
end

%% Get BSEPR and grip
if nargin < 3
    grip = ScorGetGripper;
end
if nargin < 2
    BSEPR = ScorGetBSEPR;
end

%% Convert non-numeric grip to numeric value
if ischar(grip) % Binary Open/Close
    switch lower(grip)
        case 'open'
            grip = 70;
        case 'close'
            grip = 0;
        otherwise
            error('Binary gripper commands must be either "Open" or "Closed"');
    end
end

%% Check BSEPR 
% TODO - check grip value
if ~isnumeric(BSEPR) || numel(BSEPR) ~= 5
    if isempty(inputname(1))
        txt = 'udpS';
    else
        txt = inputname(1);
    end
    error('ScorSend:BadBSEPR',...
        ['Joint configuration must be specified as a 5-element numeric array.',...
        '\n\t-> Use "%s(%s,[Joint1,Joint2,...,Joint5]);".'],mfilename,txt);
end

%% Send message
% TODO - improve message handling
% Create message
msg_Send = sprintf('[%f,%f,%f,%f,%f,%f]',[BSEPR,grip]);
% Convert message
dataSend = uint8(msg_Send);
% Send message
step(udpS, dataSend);