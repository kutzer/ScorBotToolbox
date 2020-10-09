function im = ScorSimGetSnapshot(scorSim)
% SCORSIMGETSNAPSHOT creates a simulated image of the ScorBot assuming an
% overhead 640x480 camera. 
%   im = SCORSIMGETSNAPSHOT(scorSim)
%
%   See also ScorSimInit, ScorSimPatch, getFOVSnapshot
%
%   M. Kutzer, 08Oct2020, USNA

%% Check input(s)
narginchk(1,1);

if ~isScorSim(scorSim)
    error('Input must be a valid scorSim structured array.');
end

%% Get and set current warning state
wrn = warning('query');
warning('off');

%% Recover simulated camera properties
figTag = 'ScorSim Simulated Camera FOV, Figure';
axsTag = 'ScorSim Simulated Camera FOV, Axes';
lgtTag = 'ScorSim Simulated Camera FOV, Light';
hgtTag = 'ScorSim Simulated Camera FOV, H_o2c';
txtTag = 'Simulated Camera FOV, Resolution';

cam.Figure = findobj('Type','Figure','Tag',figTag);
if isempty(cam.Figure)
    open('ScorSimCameraView.fig');
    cam.Figure = findobj('Type','Figure','Tag',figTag); 
    if isempty(cam.Figure)
        error('Unable to load simulated camera view');
    end
end
cam.Axes = findobj('Parent',cam.Figure,'Type','Axes','Tag',axsTag);

% Recover resolution
txt = findobj('Parent',cam.Axes,'Tag',txtTag);
res = sscanf(get(txt,'String'),'[%d,%d]',[1,2]);
cam.hRes   = res(1); % horizontal resolution of the camera
cam.vRes   = res(2); % vertical resolution of the camera
% sim.hAOV   - approximate horizontal angle of view for the camera
% sim.vAOV   - approximate vertical angle of view for the camera

h_o2c = findobj('Parent',cam.Axes,'Type','hgtransform','Tag',hgtTag);

%% Move simulation to simulated camera
set(scorSim.Frames(1),'Parent',h_o2c);
drawnow;

%% Get image
im = getFOVSnapshot(cam);

%% Return simulation
set(scorSim.Frames(1),'Parent',scorSim.Axes);

%% Restore current warning state
for i = 1:numel(wrn)
    warning(wrn(i).state,wrn(i).identifier);
end