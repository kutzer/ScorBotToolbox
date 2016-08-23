function confirm = ScorSetControl(cMode)
% SCORSETCONTROL sets the control mode to "On" (enable) or "Off" (disable)
%   SCORSETCONTROL(cMode) sets the control mode to "On" (enable) or "Off" 
%   (disable). Equivalent to using CONTROL ON/OFF on the ScorBot Teach
%   Pendant.
%
%   confirm = SCORSETCONTROL(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorInit ScorHome
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorControlEnable.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated to include control enable/disable tracking

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Set control mode
switch lower(cMode)
    case 'on'
        isOn = calllib(libname,'RControl',int8('A'),1);
        if isOn
            confirm = true;
            ScorGetControl('SetControl','On');
        else
            confirm = false;
            if nargout == 0
                warning('Unable to set Control mode to "On"');
            end
            return
        end
    case 'off'
        isOff = calllib(libname,'RControl',int8('A'),0);
        if isOff
            confirm = true;
            ScorGetControl('SetControl','Off');
        else
            confirm = false;
            if nargout == 0
                warning('Unable to set Control mode to "Off"');
            end
            return
        end
    otherwise
        error('Unexpected value for ScorBot Control mode.');
end