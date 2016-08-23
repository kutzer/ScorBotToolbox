function confirm = ScorSetDigitalOutput(varargin)
% SCORSETDIGITALOUTPUT sets ScorBot digital outputs to on or off.
%   SCORSETDIGITALOUTPUT(i,state) sets the ith digital output of ScorBot to
%   the designated state. Valid values of i are between 1 and 8.
%       State: Description
%        'On': sets the ith digital output to "On" (high)
%       'Off': sets the ith digital output to "Off" (low)
%           1: sets the ith digital output to "On" (high)
%           0: sets the ith digital output to "Off" (low)
%
%   SCORSETDIGITALOUTPUT(v) sets each digital output to the state contained
%   in the 8-element vector "v".
%       v(i) = 1 sets the ith digital output to "On" (high)
%       v(i) = 0 sets the ith digital output to "Off" (low)
%
%   confirm = SCORSETDIGITALOUTPUT(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also N/A
%
%   References:
%       [1] C. Wick, J. Esposito, &  K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorSetDigitalOutput.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated error handling

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check inputs
narginchk(1,2);

v = [];
i = [];
state = [];
if nargin == 1
    v = varargin{1};
    % check size of v
    if numel(v) ~= 8
        error('Vector describing digital output states must contain 8-elements.');
    end
end
if nargin == 2
    i = varargin{1};
    state = varargin{2};
    % check value of i
    if i < 1 || i > 8
        error('Digital output channel must be between 1 and 8.');
    end
end

%% Set digital outputs
if isempty(v)
    switch lower(state)
        case 'on'
            isSet = calllib(libname,'RDigOn', i);
        case 'off'
            isSet = calllib(libname,'RDigOff',i);
        case 1
            isSet = calllib(libname,'RDigOn', i);
            state = 'On';
        case 0
            isSet = calllib(libname,'RDigOff',i);
            state = 'Off';
        otherwise
            error('Digital output state not recognized.');
    end
    if isSet
        confirm = true;
    else
        confirm = false;
        if nargout == 0
            warning('Failed to set Digital Output Channel %d to "%s"',i,state);
        end
    end
    return
else
    for i = 1:numel(v)
        switch v(i)
            case 1
            isSet(i) = calllib(libname,'RDigOn', i);
            state = 'On';
        case 0
            isSet(i) = calllib(libname,'RDigOff',i);
            state = 'Off';
        otherwise
            error('Unrecognized digital output state');
        end
        if ~isSet(i)
            warning('Failed to set Digital Output Channel %d to "%s"',i,state);
        end
    end
    if min(isSet)
        confirm = true;
    else
        confirm = false;
    end
end