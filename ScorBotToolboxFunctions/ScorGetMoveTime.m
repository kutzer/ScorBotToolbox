function mTime = ScorGetMoveTime(varargin)
% SCORGETMOVETIME gets the current move time of ScorBot in seconds
%   mTime = SCORGETMOVETIME gets the current move time of ScorBot in 
%       seconds. If ScorBot has a speed set instead of a move time, 
%       ScorGetMoveTime will return an empty set.
%
%   NOTE: This library is currently unable to access the move time of 
%         ScorBot directly from the control box. To compensate, a temporary
%         value is saved to the tempdir of the user. This value is used to 
%         track the move time set by the user when using the ScorBot 
%         Toolbox. Saving the value also protects it from "clear all" 
%         calls. This function will not change values if the move time of 
%         ScorBot is changed using the Teach Pendant.
%
%   See also: ScorSetMoveTime ScorGetSpeed
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
    % User is getting the move time of ScorBot
    if exist(fname,'file') == 2
        % Load saved move time
        load(fname);
        switch lower(sMode)
            case 'speed'
                % Speed Mode
                mTime = [];
            case 'movetime'
                % MoveTime Mode
                % move time matches existing value
        end
    else
        % Create file if it does not already exist
        save(fname,'spd','mTime','sMode');
    end
else
    % (1) ScorSetMoveTime is updating the move time of the ScorBot or
    % (2) ScorSafeShutdown is deleting the ScorSpeedMoveTimeTMP file
    switch lower(varargin{1})
        case 'setmovetime'
            spd = [];            % Remove speed value
            mTime = varargin{2}; % Update move time value
            sMode = 'MoveTime';  % Update mode
            save(fname,'spd','mTime','sMode');
            return
        case 'deletemovetime'
            if exist(fname,'file') == 2
                delete(fname);
            end
        otherwise
            error('ScorGetSpeed:badProperty',...
                'The name "%s" is not an accessible property ScorGetSpeed.',...
                varargin{1});
    end
end