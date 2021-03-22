function scorSim = ScorSimInit(varargin)
% SCORSIMINIT initializes a visualization of the ScorBot
%   scorSim = SCORSIMINIT initializes a visualization of the ScorBot in a
%   new figure window, and returns the scorSim structured array.
%
%   Structured Array Fields for scorSim:
%       scorSim.Figure - figure handle of ScorBot visualization
%       scorSim.Axes   - axes handle of ScorBot visualization
%       scorSim.Joints - 1x5 array containing joint handles for ScorBot
%           visulization (hgtransform objects, use 
%           set(scorSim.Joints(i),'Matrix',Rz(angle)) to change a specific
%           joint angle)
%       scorSim.Frames - 1x5 array containing reference frame handles for
%           ScorBot (hgtransform objects with triad.m decendants)
%       scorSim.Finger - 1x4 array containing reference frame handles for
%           the ScorBot end-effector fingers (hgtransform objects)
%       scorSim.FingerTip - 1x2 array containing reference frame handles 
%           for the ScorBot end-effector fingertips (hgtransform objects)
%       scorSim.TeachFlag - status update object, not for general use
%       scorSim.TeachText - status update object, not for general use
%       scorSim.DrawFlag
%       scorSim.DrawText
%       scorSim.DrawTool
%       scorSim.DrawLine
%       scorSim.LabBench
%       scorSim.Paper
%       scorSim.Speed
%       scorSim.IsMoving
%       scorSim.CheckerBoard
%       scorSim.Ball
%
%   Example:
%       %% Initialize ScorBot simulation
%       scorSim = ScorSimInit;
%
%       %% Add patch elements to visualize ScorBot
%       ScorSimPatch(scorSim);
%
%       %% Put the ScorBot simulation in XYZPR teach mode
%       ScorSimTeachXYZPR(scorSim);
%
%   See also ScorSimPatch ScorSimGoHome ScorSimSetBSEPR ScorSimGetBSEPR 
%            ScorSimSetXYZPR ScorSimGetXYZPR etc
%
%   M. Kutzer, 13Aug2015, USNA

% Updates
%   25Sep2015 - Updated to adjust default view angle to match student view
%   03Oct2015 - Updated to include gripper functionality
%   15Oct2015 - Updated to include global for keypress movements
%   20Oct2015 - Updated to include teach indicator
%   23Oct2015 - Updated field of view (xlim)
%   01Nov2015 - Updated indicator axes to hide handle visibility
%   29Dec2015 - Updated comments
%   30Dec2015 - Updated see also
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated to add example
%   17Oct2017 - Updated documentation and nargout check
%   18Aug2020 - Added drawing fields
%   21Aug2020 - Added speed field
%   21Aug2020 - Added moving field
%   20Mar2021 - Added checkerboard and ball objects

%% Check inputs
% Check for too many inputs
if nargin > 0
    warning('ScorSim:TooManyInputs',...
        'Too many inputs specified. Ignoring additional parameters.');
end

%% Check outputs
if nargout < 1
    warning('ScorSim:NoSimOut',...
        'An output (e.g. "sim = ScorSimInit") must be specified to interact with the ScorBot simulation.');
end
%% Initialize output
scorSim.Figure = [];
scorSim.Axes   = [];
scorSim.Joints = [];
scorSim.Frames = [];

%% Setup figure
% Create new figure
scorSim.Figure = figure;
% Create axes in scorSim.Figure
scorSim.Axes   = axes('Parent',scorSim.Figure);
% Update figure properties
set(scorSim.Figure,'Name','ScorBot Visualization','MenuBar','none',...
    'NumberTitle','off','ToolBar','Figure');
set(scorSim.Figure,'Units','Normalized','Position',[0.30,0.25,0.40,0.60]);
% Set tag to help confirm validity of global variable
set(scorSim.Figure,'Tag','ScorBot Visualization Figure, Do Not Change');
% Set axes limits
set(scorSim.Axes,'XLim',[-700,700],'YLim',[-700,700],'ZLim',[-50,1000]);
daspect([1 1 1]);
hold on
% Define axes labels
xlabel(scorSim.Axes,'x (mm)');
ylabel(scorSim.Axes,'y (mm)');
zlabel(scorSim.Axes,'z (mm)');

%% Create visualization
DHtable = ScorDHtable;
scorSim.Frames = plotDHtable(scorSim.Axes,DHtable,'LinkLabels','Off');
view(scorSim.Axes,[-127,30]);

%% Hide unwanted triad labels
hideTriadLabels(scorSim.Frames);

%% Make intermittent frames
for i = 2:numel(scorSim.Frames)
    scorSim.Joints(i-1) = hgtransform('Parent',scorSim.Frames(i-1));
    set(scorSim.Frames(i),'Parent',scorSim.Joints(i-1));
end

%% Setup gripper
% Finger Base coordinates
n = 4;
v(1,:) = zeros(1,n);
v(2,:) = [44.83, 31.85,-31.85,-44.83];
v(3,:) = repmat(-66.19,1,n);
for i = 1:n
    h(i) = hgtransform('Parent',scorSim.Frames(6),...
        'Matrix',Tx(v(1,i))*Ty(v(2,i))*Tz(v(3,i)),...
        'Tag',sprintf('FingerLinkBaseFrame%d',i));
    g(i) = hgtransform('Parent',h(i),...
        'Tag',sprintf('FingerLinkFrame%d',i));
    f(i) = hgtransform('Parent',g(i),...
        'Matrix',Tz(47.22),...
        'Tag',sprintf('FingerTipBaseFrame%d',i));
    d(i) = hgtransform('Parent',f(i),...
        'Tag',sprintf('FingerTipFrame%d',i));
end
% Assign finger frames
for i = 1:n
    scorSim.Finger(i) = g(i);
end
% Assign fingertip frames
idx = [1,4];
for i = 1:2
    scorSim.FingerTip(i) = d(idx(i));
end

%% Set callback function
set(scorSim.Figure,'WindowKeyPressFcn',@ScorSimTeachCallback);

%% Setup Teach Indicator Axes
% Create indicator axes
axs = axes('Parent',scorSim.Figure,'Position',[0.84,0.0,0.16,0.08],...
           'xlim',[0,2],'ylim',[0,1],'Visible','Off',...
           'HandleVisibility','off');
% Create status flag
scorSim.TeachFlag = patch([0,2,2,0,0],[0,0,1,1,0],'w');
set(scorSim.TeachFlag,'FaceColor','w','EdgeColor','k','FaceAlpha',0.5,...
    'Parent',axs);
% Create status text
scorSim.TeachText = text(1,0.5,sprintf('Inactive.'),...
    'VerticalAlignment','Middle',...
    'HorizontalAlignment','Center');
set(scorSim.TeachText,'Parent',axs);
% Set visibility
set([scorSim.TeachFlag,scorSim.TeachText],'Visible','off');

%% Setup Drawing Indicator Axes
% Create indicator axes
axs = axes('Parent',scorSim.Figure,'Position',[0.0,0.0,0.16,0.08],...
           'xlim',[0,2],'ylim',[0,1],'Visible','Off',...
           'HandleVisibility','off');
% Create status flag
scorSim.DrawFlag = patch([0,2,2,0,0],[0,0,1,1,0],'w');
set(scorSim.DrawFlag,'FaceColor','w','EdgeColor','k','FaceAlpha',0.5,...
    'Parent',axs);
% Create status text
scorSim.DrawText = text(1,0.5,sprintf('Inactive.'),...
    'VerticalAlignment','Middle',...
    'HorizontalAlignment','Center');
set(scorSim.DrawText,'Parent',axs);
% Set visibility
set([scorSim.DrawFlag,scorSim.DrawText],'Visible','off');

%% Create lab bench and paper
scorSim.LabBench = hgtransform('Parent',scorSim.Frames(1),...
    'Matrix',Tx(150.00)*Tz(19.95));
patch('Vertices',...
    [  0.00,  0.00, 60.00, 60.00,  0.00,  0.00, 60.00, 60.00;...
      12.00,-12.00,-12.00, 12.00, 12.00,-12.00,-12.00, 12.00;...
      -0.75, -0.75, -0.75, -0.75,  0.00,  0.00,  0.00,  0.00].'*25.4,...
    'Faces',[1,2,3,4; 5,6,7,8; 1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8],...
    'Parent',scorSim.LabBench,'EdgeColor','None','FaceColor',[102, 118, 134]./255,...
    'Tag','ScorBot Simulation Lab Bench');
set(scorSim.LabBench,'Visible','off');

scorSim.Paper = hgtransform('Parent',scorSim.Frames(1),...
    'Matrix',Tx(300.00)*Tz(20.00));
patch('Vertices',...
    [-4.25,-4.25, 4.25, 4.25;...
      5.50,-5.50,-5.50, 5.50].'*25.4,...
     'Faces',[1,2,3,4],...
     'Parent',scorSim.Paper,'EdgeColor','None','FaceColor',[248,248,255]./255,...
     'Tag','ScorBot Simulation Paper');
 set(scorSim.Paper,'Visible','off');
 
%% Setup Drawing Tool & Line
scorSim.DrawTool = hgtransform('Parent',scorSim.Frames(6),...
    'Matrix',Tz(3.5*25.4),'Tag','ScorBot Simulation Drawing Tool');
plot3([0,0],[0,0],[0,-3.75*25.4],'Parent',scorSim.DrawTool,...
    'Linewidth',2,'Tag','ScorBot Simulation Drawning Tool Pen','Color','k');
set(scorSim.DrawTool,'Visible','off');

scorSim.DrawLine = plot(scorSim.Paper,nan,nan,'k','LineWidth',1.5);
set(scorSim.DrawLine,'XData',nan,'YData',nan,'ZData',nan);

%% Setup Speed Parameter
scorSim.Speed = text(0,0,'50','Parent',scorSim.Axes,...
    'Tag','Simulation Speed','Visible','off');

%% Setup Moving Parameter
scorSim.IsMoving = text(0,0,'0','Parent',scorSim.Axes,...
    'Tag','Simulation is Moving','Visible','off');

%% Setup checkerboard
cb.boardSize = [6,7];
cb.squareSize = 19.05;
[cb.hg, cb.ptc] = plotCheckerboard(...
    scorSim.Frames(6),cb.boardSize,cb.squareSize);
hideTriad(cb.hg);
set(cb.ptc,'EdgeColor','none');

% Define board 
cb.w = 4.75 * 25.4; % Width  (mm)
cb.h = 6.25 * 25.4; % Height (mm)
cb.d = 7;           % Depth  (mm)
% Board vertices (referenced from lower left corner)
cb.v_l = [...
    0.00, 0.00, cb.h, cb.h, 0.00, 0.00, cb.h, cb.h;... % x-coordinates
    0.00, cb.w, cb.w, 0.00, 0.00, cb.w, cb.w, 0.00;... % y-coordinates
    0.10, 0.10, 0.10, 0.10, cb.d, cb.d, cb.d, cb.d];   % z-coordinates
cb.v_l(4,:) = 1;
% Board faces 
cb.f = [...
    1,2,3,4;...
    5,6,7,8;...
    1,2,6,5;...
    2,3,7,6;...
    3,4,8,7;...
    4,1,5,8];
% Transformation relating board lower left to grid frame
cb.H_l2g = Tx( -(cb.squareSize + 0.88*25.4) )*Ty( -(cb.squareSize + 0.21*25.4) );
% Reference board to grid frame
cb.v_g = cb.H_l2g * cb.v_l;
% Patch board
cb.brd = patch('Faces',cb.f,'Vertices',cb.v_g(1:3,:).','FaceColor','w',...
    'EdgeColor','k','FaceAlpha',1,'Parent',cb.hg);

% Place checkerboard in the gripper
ScorSimSetGripper(scorSim,cb.d);
cb.go = ScorSimGetGripperOffset(scorSim);
cb.gw = 15.1;

cb.H_g2e = Ty(cb.d/2)*Tx(cb.gw/2 + 29.2)*Tz(cb.go + 22.4)*Ry(-pi/2)*Rx(pi/2);
set(cb.hg,'Matrix',cb.H_g2e,'Visible','off');

% Update tags
set(cb.hg, 'Tag','ScorBot Simulation Gripper CheckerBoard, Frame');
set(cb.ptc,'Tag','ScorBot Simulation Gripper CheckerBoard, CheckerBoard');
set(cb.brd,'Tag','ScorBot Simulation Gripper CheckerBoard, Board');

% Package output
scorSim.CheckerBoard = cb.hg;

%% Close gripper
ScorSimSetGripper(scorSim,'Close');

%% Home ScorSim
ScorSimGoHome(scorSim,'MoveType','Instant');

%% Set default view (matches USNA MU111 setup)
view([(-37.5+180),30]);