function spd = ScorGetSpeed(varargin)
% SCORGETSPEED gets the current speed of ScorBot as a percent of the
% maximum possible speed.
%   spd = SCORGETSPEED gets the current speed of ScorBot as a percent of the
%       maximum possible speed. If ScorBot has a Move Time set instead of a
%       speed, ScorGetSpeed will return an empty set.
%
%   NOTE: This library is currently unable to access the speed of ScorBot 
%         directly from the control box. To compensate, a temporary value 
%         is saved to the tempdir of the user. This value is used to track 
%         the speed set by the user when using the ScorBot Toolbox. Saving 
%         the value also protects it from "clear all" calls. This function 
%         will not change values if the speed of ScorBot is changed using 
%         the Teach Pendant.
%
%   See also: ScorSetSpeed ScorGetMoveTime
%
%   M. Kutzer, 28Aug2015, USNA

%% Check inputs 
narginchk(0,2);

%% Check for and/or setup temporary file
fname = fullfile(tempdir,'ScorSpeedMoveTimeTMP.mat');
spd = 50;        % ScorBot default speed
mTime = [];      % ScorBot default move time
sMode = 'Speed'; % ScorBot default movement mode
if nargin == 0
    % User is getting the speed of ScorBot
    if exist(fname,'file') == 2
        % Load saved speed
        load(fname);
        switch lower(sMode)
            case 'speed'
                % Speed Mode
                % speed matches existing value
            case 'movetime'
                % MoveTime Mode
                spd = [];
        end
    else
        % Create file if it does not already exist
        save(fname,'spd','mTime','sMode');
    end
else
    % (1) ScorSetSpeed is updating the speed of the ScorBot or
    % (2) ScorSafeShutdown is deleting the ScorSpeedMoveTimeTMP file
    switch lower(varargin{1})
        case 'setspeed'
            spd = varargin{2}; % Update speed value
            mTime = [];        % Remove move time value
            sMode = 'Speed';   % Update mode
            save(fname,'spd','mTime','sMode');
            return
        case 'deletespeed'
            if exist(fname,'file') == 2
                delete(fname);
            end
        otherwise
            error('ScorGetSpeed:badProperty',...
                'The name "%s" is not an accessible property ScorGetSpeed.',...
                varargin{1});
    end
end