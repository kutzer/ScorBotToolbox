function ScorDrawMaker
% SCORDRAWMAKER initializes a visualization of the ScorBot and renders an
% image of Professor Emeritus Carl Wick. Carl continues to be instrumental 
% in the development of all versions of the ScorBot Toolbox his creation 
% of RobotDll back in 2010 for the Matlab Toolbox for the Intelitek Scorbot
% (MTIS), his USBC version fix in 2019 leading to the addition and use of 
% ScorConfigurationSync.m in the ScorBot Toolbox, and his development of
% the 64bit update to the toolbox that enables full use of the documented
% functionality of the Intelitek USB library. 
%
%   Thank you for everything Carl!
%
%   M. Kutzer, 21Nov2019, USNA

%% Read Image
% Load image
imEND = imread('Wick.png');
% Crop image for uniform aspect ratio
imEND = imcrop(imEND,[16,19,2399,2699]);
% Resize image
%imEND = imresize(imEND,(1/6));
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
%set(sim.Figure,'Units','Inches','Position',[0.5,0.5,10,6],'Color',[1,1,1]);
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
% Render image
figTMP = figure;
axsTMP = axes('Parent',figTMP);
img = imshow(imNOW,'Parent',axsTMP);
set(img,'Parent',h_p2o);
delete(figTMP);

%% Define drawing parameters
% Initialize drawing pose
R0 = ...
    [ 1, 0, 0;...
    0,-1, 0;...
    0, 0,-1];
H0 = eye(4);
H0(1:3,1:3) = R0;
% Define drawing waypoints
r = 7; % Closted gripper tip is ~7mm wide
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
        
        ScorSimSetPose(sim,H0);
        drawnow;
    end
    %}
end

%% Define path information
s0 = 0;
d = -r:(r-1);
xALL = [];
yALL = [];
zALL = [];
sALL = [];
dsALL = [];
for i = 1:numel(xyzWPT_p)
    n = abs( diff(xyzWPT_p{i}(1,:)) ) + 1;
    x = linspace(xyzWPT_p{i}(1,1),xyzWPT_p{i}(1,2),n);
    y = linspace(xyzWPT_p{i}(2,1),xyzWPT_p{i}(2,2),n);
    z = linspace(xyzWPT_p{i}(3,1),xyzWPT_p{i}(3,1),n);
    
    y0 = mean(y);
    for j = 1:numel(x)
        ds(j) = mean(mean( double(imEND(d+y0,x(j))) ));
        s(j) = s0 + 1/(ds(j)+1);
        s0 = s(j);
    end
    
    xALL = [xALL,x];
    yALL = [yALL,y];
    zALL = [zALL,z];
    sALL = [sALL,s];
    dsALL = [dsALL,ds];
end

%% Convert "s" to time
t_max = 10; % seconds
s2t = t_max/max(sALL);
tALL = sALL * s2t;

%% Convert "ds" to z
z_min = -5;
p = polyfit([0,255],[z_min,0],1);
zALL = polyval(p,dsALL);

%% Spline for path
pp(1) = spline(tALL,xALL);
pp(2) = spline(tALL,yALL);
pp(3) = spline(tALL,zALL);

%% Animate
% Define points in time
fps = 30;
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
    ScorSimSetBSEPR(sim,q(:,f).');
    drawnow;
end

% Draw Carl
for f = 1:size(X_p,2)
    H0(1:3,4) = X_o(1:3,f);
    ScorSimSetPose(sim,H0);
    
    D = (xALL - X_p(1,f)).^2 + (yALL - X_p(2,f)).^2 + (zALL - X_p(3,f)).^2;
    idx = find(D == min(D));
    bin = false(size(imNOW));
    for k = 1:idx
        bin(d+yALL(k),xALL(k),:) = true;
    end
    
    imNOW(bin) = imEND(bin);
    set(img,'CData',imNOW);
    
    drawnow;
end

% Move to home
qi = ScorSimGetBSEPR(sim);
n = 20;
q = [];
for i = 1:numel(q0)
    q(i,:) = linspace(qi(i),q0(i),n);
end
for f = 1:size(q,2)
    ScorSimSetBSEPR(sim,q(:,f).');
    drawnow;
end