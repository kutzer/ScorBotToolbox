function grip = ScorSimGetGripper(varargin)
% SCORSIMGETGRIPPER get the gripper state of the ScorBot visualization as 
% measured in millimeters above fully closed.
%   grip = SCORSIMGETGRIPPER(scorSim) get the gripper state of the ScorBot
%   visualization in millimeters. State is measured as the distance between
%   the gripper fingers. A fully closed gripper has a "grip" of 0 mm. A 
%   fully open gripper has a "grip" of approximately 70 mm.
%
%   See also ScorSimInit ScorSimSetGripper
%
%   M. Kutzer, 30Sep2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   03Oct2015 - Updated to include gripper functionality
%   30Dec2015 - Updated error checking

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "grip = %s(scorSim);" to execute this function.'],mfilename)
end
% Check scorSim
if nargin >= 1
    scorSim = varargin{1};
    if ~isScorSim(scorSim)
        if isempty(inputname(1))
            txt = 'The specified input';
        else
            txt = sprintf('"%s"',inputname(1));
        end
        error('ScorSet:BadSimObj',...
            ['%s is not a valid ScorSim object.',...
            '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
            '\n\t-> and "grip = %s(scorSim);" to execute this function.'],txt,mfilename);
    end
end
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Get grip
g0 = 34.00+21.6-0.028; % this value must match in get and set command
h = 47.22; % this value must match in get and set command

H = get(scorSim.Finger(1),'Matrix');
ang = atan2(H(3,2),H(2,2));

o = -h*sin(ang);

grip = 2*o+g0;
