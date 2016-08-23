function cState = ScorGetControl(varargin)
% SCORGETCONTROL gets the control state of ScorBot
%   cState = SCORGETCONTROL gets the control state of ScorBot
%       cState - 'On' indicates that control of ScorBot is enabled
%       cState - 'Off' indicates that control of ScorBot is disabled
%
%   NOTE: This library is currently unable to access the control state of 
%         ScorBot directly from the control box, but the control box does 
%         send error codes if/when control is disabled. To compensate, a 
%         temporary value is saved to the tempdir of the user. This value 
%         is used to track the control state set by the user and/or updated
%         in error codes from the ScorBot. Saving the value also protects 
%         it from "clear all" calls. This function *may* not change values 
%         if the speed of ScorBot is changed using the Teach Pendant.
%
%   See also ScorSetControl ScorIsReady
%
%   M. Kutzer, 28Aug2015, USNA

%% Check inputs 
narginchk(0,2);

%% Check for and/or setup temporary file
fname = fullfile(tempdir,'ScorControlStateTMP.mat');
cState = 'Off';
if nargin == 0
    % User is getting the speed of ScorBot
    if exist(fname,'file') == 2
        % Load saved control state
        load(fname);
    else
        % Create file if it does not already exist
        save(fname,'cState');
    end
else
    % (1) ScorSetControl is updating the control state of the ScorBot or
    % (2) ScorIsReady has identified an error code indicating a change in
    %     the control state of the ScorBot or 
    % (3) ScorSafeShutdown is deleting the ScorControlStateTMP file
    switch lower(varargin{1})
        case 'setcontrol'
            cState = varargin{2}; % Update speed value
            save(fname,'cState');
            return
        case 'deletecontrol'
            if exist(fname,'file') == 2
                delete(fname);
            end
        otherwise
            error('ScorGetControl:badProperty',...
                'The name "%s" is not an accessible property ScorGetControl.',...
                varargin{1});
    end
end