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

%% Setup Indicator Axes
% Create indicator axes
axs = axes('Parent',scorSim.Figure,'Position',[0.84,0.0,0.16,0.08],...
           'xlim',[0,2],'ylim',[0,1],'Visible','Off','HandleVisibility','off');
% Create status flag
scorSim.TeachFlag = patch([0,2,2,0,0],[0,0,1,1,0],'w');
set(scorSim.TeachFlag,'FaceColor','w','EdgeColor','k','FaceAlpha',0.5,'Parent',axs);
% Create status text
scorSim.TeachText = text(1,0.5,sprintf('Inactive.'),...
    'VerticalAlignment','Middle',...
    'HorizontalAlignment','Center');
set(scorSim.TeachText,'Parent',axs);
% Set visibility
set([scorSim.TeachFlag,scorSim.TeachText],'Visible','off');

%% Close gripper
ScorSimSetGripper(scorSim,'Close');

%% Home ScorSim
ScorSimGoHome(scorSim);

%% Set default view (matches USNA MU111 setup)
view([(-37.5+180),30]);