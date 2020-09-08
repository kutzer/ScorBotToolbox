function ScorDrawMaker
% SCORDRAWMAKER initializes a visualization of the ScorBot and renders an
% image of Professor Emeritus Carl Wick. 
%
% Carl continues to be instrumental in the development of all versions of 
% the ScorBot Toolbox. He released the original RobotDll back in 2010 for 
% the "Matlab Toolbox for the Intelitek Scorbot" (MTIS). This library was 
% the jumping point for all MATLAB interaction with the Intelitek 
% SCORBOT-ER 4u at the United States Naval Academy. Since that time, Carl 
% has answered countless questions and even identified the critical USBC 
% version fix during the summer of 2019. This fix led to the addition and 
% use of ScorConfigurationSync.m, solving issues associated with the 
% recurring 201 impact errors that plagued the toolbox during its rocky, 
% yearlong transition to 64-bit OS. In the time since, he has developed a 
% 64bit update to the toolbox that will supersede the existing toolbox 
% framework and enable full use of the new, documented functionality of 
% the Intelitek USBC library. 
%
%   Thank you for everything Carl!
%
%   M. Kutzer, 21Nov2019, USNA

% Updates:
%   08Sep2020 - Updated for new simulation syntax

%% Read Image
% Load image
imEND = imread('Wick.png');
% Crop image for uniform aspect ratio
imEND = imcrop(imEND,[16,19,2399,2699]);
% Resize image
imEND = imresize(imEND,(1/9));
% Make image "color" for rendering
imEND = repmat(imEND,1,1,3);

% Define "current" image
imNOW = imEND;
imNOW(:,:,:) = 255;

%% Initialize simulation
sim = ScorSimInit;
set(sim.Axes,'Visible','off');
xlim(sim.Axes,[-225,525]);
ylim(sim.Axes,[-225,225]);
set(sim.Figure,'Units','Normalized','Position',[0,0,1,1],'Color',[1,1,1],...
    'Name','Professor Emeritus C. Wick, USNA Department of Weapons, Robotics, & Control Engineering');
ScorSimPatch(sim);

%% Rotate view
% Define initial and final views
[v0(1),v0(2)] = view(sim.Axes);
vf = [180,90];
% Interpolate between views
n = 30;
for i = 1:numel(v0)
    v(i,:) = linspace(v0(i),vf(i),n);
end
% Rotate view
for f = 1:n
    view(sim.Axes,v(:,f).');
    drawnow;
end

%% Position image in ScorBot simulation
% Define image transformation
H_p2o = Ry(pi)*Tx(-(size(imEND,2) + 140) )*Ty(-(size(imEND,1)/2) )*Tz(-105);
h_p2o = triad('Parent',sim.Frames(1),'Matrix',H_p2o,'Scale',50);
% Render image and place in simulation
figTMP = figure;
axsTMP = axes('Parent',figTMP);
img = imshow(imNOW,'Parent',axsTMP);
set(img,'Parent',h_p2o);
delete(figTMP);

%% Initialize ScorBot end-effector pose for drawing
R0 = ...
    [ 1, 0, 0;...
    0,-1, 0;...
    0, 0,-1];
H0 = eye(4);
H0(1:3,1:3) = R0;

%% Define drawing parameters
% Define drawing waypoints
r = 7; % Closed gripper tip is ~7mm wide
y_Pass = (r+1):(2*r):size(imEND,1);
for i = 1:numel(y_Pass)
    switch mod(i,2)
        case 1
            xyzWPT_p{i}(1,:) = [size(imEND,2),1];
        otherwise
            xyzWPT_p{i}(1,:) = [1,size(imEND,2)];
    end
    xyzWPT_p{i}(2,:) = y_Pass(i);
    xyzWPT_p{i}(3,:) = 0;
    xyzWPT_p{i}(4,:) = 1;
    
    % Check movement
    %{
    xyzWPT_o = H_p2o*xyzWPT_p{i};
    for j = 1:size(xyzWPT_o,2)
        
        H0(1:3,4) = xyzWPT_o(1:3,j);
        
        ScorSimSetPose(sim,H0,'MoveType','Instant');
        drawnow;
    end
    %}
end

%% Define path information
s0 = 0;         % Initial cumulative 1/(avg. brightness + 1) value
d = -r:(r-1);   % Sketch "diameter"
xALL = [];      % All x-positions for path
yALL = [];      % All y-positions for path
zALL = [];      % All z-positions for path
dsALL = [];     % All average brightness values for path
sALL = [];      % All cumulative 1/(avg. brightness + 1) values for path

for i = 1:numel(xyzWPT_p)
    % Total number of discrete values between x_init & x_goal
    n = abs( diff(xyzWPT_p{i}(1,:)) ) + 1;
    % Interpolate x/y/z initial and goal values
    x = linspace(xyzWPT_p{i}(1,1),xyzWPT_p{i}(1,2),n);
    y = linspace(xyzWPT_p{i}(2,1),xyzWPT_p{i}(2,2),n);
    z = linspace(xyzWPT_p{i}(3,1),xyzWPT_p{i}(3,1),n);
    
    % Define average brightness and cumulative 1/(avg. brightness + 1)
    % -> Average y-value
    y0 = mean(y);
    for j = 1:numel(x)
        % -> Mean average brightness over for sketch "diameter"
        ds(j) = mean(mean( double(imEND(d+y0,x(j))) ));
        % -> Cumulative 1/(avg. brightness + 1)
        s(j) = s0 + 1/(ds(j)+1);
        % -> Update current cumulative 1/(avg. brightness + 1)
        s0 = s(j);
    end
    
    % Update path arrays
    xALL = [xALL,x];
    yALL = [yALL,y];
    zALL = [zALL,z];
    dsALL = [dsALL,ds];
    sALL = [sALL,s];
end

%% Convert cumulative 1/(avg. brightness + 1) values ("s") to time
% -> We want to go slower for darker pixel averages and faster for lighter
%    pixel averages.
t_max = 10; % Desired total time to complete the drawing (seconds)
s2t = t_max/max(sALL);
tALL = sALL * s2t;

%% Convert average brightness values ("ds") to z height
% -> We want to press more (harder) for average brightness values closer 
%    to 0, and press less for average brightness values closer to 255.

% Given that the z-direction of Carl's image points into the working
% surface, a more negative z-value represents a lighter interaction and a
% z-value of zero represents the "hardest" interaction possible.
%     0 - Black --> 0 (i.e. push hardest) height
%   255 - White --> z_min (negative) height 
z_min = -5; % minimum height
p = polyfit([0,255],[0,z_min],1); % linear fit
zALL = polyval(p,dsALL); % z-heights

%% Fit a time-dependent function for the x/y/z path
pp(1) = spline(tALL,xALL);
pp(2) = spline(tALL,yALL);
pp(3) = spline(tALL,zALL);

%% Animate
% Define points in time
%   Frame p - relative to Carl's picture
%   Frame o - relative to the ScorBot base frame
fps = 30;   % assumed animation frame rate (frames per second)
t = [0:(1/fps):t_max,t_max];
for i = 1:numel(pp)
    X_p(i,:) = ppval(pp(i),t);
end
X_p(4,:) = 1;
X_o = H_p2o * X_p;

% Move to first point
H0(1:3,4) = X_o(1:3,1);
q0 = ScorSimGetBSEPR(sim);
qi = ScorPose2BSEPR(H0);
n = 20;
q = [];
for i = 1:numel(q0)
    q(i,:) = linspace(q0(i),qi(i),n);
end
for f = 1:size(q,2)
    ScorSimSetBSEPR(sim,q(:,f).','MoveType','Instant');
    drawnow;
end

% Draw Carl
for f = 1:size(X_p,2)
    % Move ScorBot
    H0(1:3,4) = X_o(1:3,f);
    ScorSimSetPose(sim,H0,'MoveType','Instant');
    
    % Update image mask
    D = (xALL - X_p(1,f)).^2 + (yALL - X_p(2,f)).^2 + (zALL - X_p(3,f)).^2;
    idx = find(D == min(D));
    bin = false(size(imNOW));
    for k = 1:idx
        bin(d+yALL(k),xALL(k),:) = true;
    end
    
    % Update image
    imNOW(bin) = imEND(bin);
    set(img,'CData',imNOW);
    
    drawnow;
end

% Move to home position
qi = ScorSimGetBSEPR(sim);
n = 20;
q = [];
for i = 1:numel(q0)
    q(i,:) = linspace(qi(i),q0(i),n);
end
for f = 1:size(q,2)
    ScorSimSetBSEPR(sim,q(:,f).','MoveType','Instant');
    drawnow;
end