function confirm = ScorSimDraw(varargin)
% SCORSIMDRAW enable the ScorBot simulator drawing interface.
%   SCORSIMDRAW(scorSim) creates a lab bench, 8.5" x 11" sheet of paper,
%   and adds an end-effector "pen" offset to the ScorBot gripper.
%
%   M. Kutzer, 18Aug2020, USNA

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,BSEPR);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,BSEPR);" to execute this function.'],txt,mfilename);
    end
end

% TODO - add extra drawing inputs

%% Show lab bench and paper 
set(scorSim.DrawTool,'Visible','on');
set(scorSim.LabBench,'Visible','on');
set(scorSim.Paper,   'Visible','on');

%% Activate drawing
set(scorSim.DrawFlag,'Visible','on');
set(scorSim.DrawText,'String','Activating...','Visible','on');

isScorSimPenOnPaper(scorSim);
