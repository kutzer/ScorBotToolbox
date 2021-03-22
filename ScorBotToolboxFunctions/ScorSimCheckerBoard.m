function H_g2e = ScorSimCheckerBoard(varargin)
% SCORSIMCHECKERBOARD shows or hides a checkerboard placed in the gripper
% of ScorBot. 
%   SCORSIMCHECKERBOARD(scorSim)
%
%   SCORSIMCHECKERBOARD(scorSim,'show')
%
%   SCORSIMCHECKERBOARD(scorSim,'hide')
%
%   H_g2e = SCORSIMCHECKERBOARD(___)
%
%   M. Kutzer, 22Mar2021, USNA

% Updates:
%

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim);" to execute this function.'],txt,mfilename);
    end
end

% Set default(s)
if nargin < 2
    hideShow = 'show';
else
    hideShow = lower(varargin{2});
end

%% Show the lab bench
ScorSimLabBench(scorSim);

%% Get transformation
H_g2e = get(scorSim.CheckerBoard,'Matrix');

%% Show or hide the checkerboard
switch hideShow
    case 'show'
        ScorSimSetGripper(scorSim,7);
        set(scorSim.CheckerBoard,'Visible','on');
        hideTriad(scorSim.CheckerBoard);
    case 'hide'
        set(scorSim.CheckerBoard,'Visible','off');
        ScorSimSetGripper(scorSim,'close');
end