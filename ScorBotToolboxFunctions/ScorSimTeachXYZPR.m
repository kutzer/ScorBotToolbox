function ScorSimTeachXYZPR(varargin)
% SCORSIMTEACHXYZPR teach a specified XYZPR configuration and/or gripper 
% state using specified keys.
%   SCORSIMTEACHXYZPR(scorSim) allows the user to move the ScorBot
%   simulation to a desired XYZPR configuration and/or gripper state using
%   the following keys. Note, this function is intended to be used with the
%   numpad on the keyboard with "NumLock" on, but functionality with 
%   numeric keys is also available. Closing the teach figure will exit
%   teach mode.
%       "7"                  | -X movement
%       "9"                  | +X movement
%       "4"                  | -Y movement
%       "6"                  | +Y movement
%       "1"                  | -Z movement
%       "3"                  | +Z movement
%       "LeftArrow"          | -Pitch
%       "RightArrow"         | +Pitch
%       "DownArrow"          | -Roll
%       "UpArrow"            | +Roll
%       "SpaceBar"           | Open Gripper 
%       "Shift" + "SpaceBar" | Close Gripper
%
%   See also ScorSimInit ScorSimTeachBSEPR
%
%   M. Kutzer, 16Oct2015, USNA

% Updates
%   23Oct2015 - Updates to status indicator and function description.
%   30Dec2015 - Updated error checking
%   17Oct2017 - Added error instructions for bad ScorSim

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
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end
    
%% Declare globals
global scorSimGlobalVariable scorSimTeachBSEPR scorSimTeachXYZPR

%% Delete existing teach figures
BSEPR_fig = findobj('Tag','ScorSim BSEPR Teach, Do Not Change');
XYZPR_fig = findobj('Tag','ScorSim XYZPR Teach, Do Not Change');
if ~isempty(BSEPR_fig)
    close(BSEPR_fig);
    drawnow
end
if ~isempty(XYZPR_fig)
    close(XYZPR_fig);
    drawnow
end

%% Setup global variables
scorSimGlobalVariable = scorSim;
scorSimTeachBSEPR = false;
scorSimTeachXYZPR = true;

%% Set instruction figure
% Setup figure
fig = figure('Name','ScorSim XYZPR Teach Mode (Close to Exit)');
set(fig,'Toolbar','none','MenuBar','none','NumberTitle','off');
set(fig,'Units','normalized','Position',[0.76,0.56,0.23,0.40]);
set(fig,'Tag','ScorSim XYZPR Teach, Do Not Change');
set(fig,'DeleteFcn',@ScorSimQuitTeachCallback);
set(fig,'WindowKeyPressFcn',@ScorSimTeachCallback);
% Setup axes
axs = axes('Parent',fig,'Visible','off');
set(axs,'Units','normalized','Position',[0,0,1,1]);
xlim([0,8]);
ylim([0,8]);
daspect([1 1 1]);

%% Create guide figure
% TODO - add button functionality
x = 0.5*([0,1,1,0,0] - repmat(0.5,1,5));
y = 0.5*([0,0,1,1,0] - repmat(0.5,1,5));
key = patch(x,y,'b');
shift = patch(3*x,y,'g');
space = patch(6*x,y,'r');

% Draw number keys
x_pos = repmat([1,4],1,3);
y_pos = [7,7,6,6,5,5];
txt = {'7','9','4','6','1','3'};
des = {'- X movement','+ X movement',...
       '- Y movement','+ Y movement',...
       '- Z movement','+ Z movement'};
for i = 1:numel(txt)
    h(i) = hgtransform('Parent',axs,'Matrix',Tx(x_pos(i))*Ty(y_pos(i)));
    p(i) = copyobj(key,h(i));
    set(p(i),'FaceColor',[1,1,1]);
    t(i) = text(0,0,txt{i},'Parent',h(i),'FontWeight','Bold');
    set(t(i),'HorizontalAlignment','center','VerticalAlignment','middle');
    d(i) = text(0.4,0,des{i},'Parent',h(i),'FontWeight','Bold');
    set(d(i),'HorizontalAlignment','left','VerticalAlignment','middle');
end

% Draw arrow keys
x_ar = (1/3)*(1/5)*([ 0, 3, 3,5,3,3,0, 0] - repmat(2.5,1,8));
y_ar = (1/3)*(1/5)*([-1,-1,-2,0,2,1,1,-1]);
rarrow = patch(x_ar,y_ar,'k');

x_pos = repmat([1,4],1,2);
y_pos = [4,4,3,3];
z_rot = [pi,0,-pi/2,pi/2];
des = {'- Pitch','+ Pitch',...
       '- Roll','+ Roll'};
for i = 1:numel(x_pos)
    h(end+1) = hgtransform('Parent',axs,'Matrix',Tx(x_pos(i))*Ty(y_pos(i)));
    p(end+1) = copyobj(key,h(end));
    set(p(end),'FaceColor',[1,1,1]);
    g(i) = hgtransform('Parent',h(end),'Matrix',Rz(z_rot(i)));
    t(end+1) = copyobj(rarrow,g(i));
    d(end+1) = text(0.4,0,des{i},'Parent',h(end),'FontWeight','Bold');
    set(d(end),'HorizontalAlignment','left','VerticalAlignment','middle');
end

% Draw spacebar
x_pos = 2.25;
y_pos = 2;
txt = 'Space';
des = 'Open Gripper';
h(end+1) = hgtransform('Parent',axs,'Matrix',Tx(x_pos)*Ty(y_pos));
p(end+1) = copyobj(space,h(end));
set(p(end),'FaceColor',[1,1,1]);
t(end+1) = text(0,0,txt,'Parent',h(end),'FontWeight','Bold');
set(t(end),'HorizontalAlignment','center','VerticalAlignment','middle');
d(end+1) = text(1.7,0,des,'Parent',h(end),'FontWeight','Bold');
set(d(end),'HorizontalAlignment','left','VerticalAlignment','middle');

% Draw shift spacebar
x_pos = [1.5,3.9];
y_pos = [1,1];
txt = {'Shift','Space'};
des = 'Close Gripper';
% Shift
h(end+1) = hgtransform('Parent',axs,'Matrix',Tx(x_pos(1))*Ty(y_pos(1)));
p(end+1) = copyobj(shift,h(end));
set(p(end),'FaceColor',[1,1,1]);
t(end+1) = text(0,0,txt{1},'Parent',h(end),'FontWeight','Bold');
set(t(end),'HorizontalAlignment','center','VerticalAlignment','middle');
% Space
h(end+1) = hgtransform('Parent',axs,'Matrix',Tx(x_pos(2))*Ty(y_pos(2)));
p(end+1) = copyobj(space,h(end));
set(p(end),'FaceColor',[1,1,1]);
t(end+1) = text(0,0,txt{2},'Parent',h(end),'FontWeight','Bold');
set(t(end),'HorizontalAlignment','center','VerticalAlignment','middle');
% Text
d(end+1) = text(1.7,0,des,'Parent',h(end),'FontWeight','Bold');
set(d(end),'HorizontalAlignment','left','VerticalAlignment','middle');

%% Delete primitives
delete([key,shift,space,rarrow]);

%% Bring ScorBot figure to the foreground
if ~ishandle(scorSim.TeachFlag)
    close(fig);
    error('ScorSim:BadSimObj',...
        ['Specified ScorBot Simulation object is not valid.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a valid ScorSim object',...
        '\n\t-> and "%s(scorSim);" to execute this function.'],mfilename)
else
    teachStr = 'XYZPR Teach';
    readyStr = 'Ready.';
    set(scorSim.TeachFlag,'FaceColor','g');
    set(scorSim.TeachText,'String',sprintf('%s\n%s',teachStr,readyStr));
    set([scorSim.TeachFlag,scorSim.TeachText],'Visible','on');
    figure(scorSim.Figure);
    drawnow
end
