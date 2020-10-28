function ScorSimLabBench(varargin)
% SCORSIMLABBENCH enable the ScorBot simulator lab bench visualization.
%   SCORSIMLABBENCH(scorSim) creates a lab bench in the ScorBot simulation
%   environment. 
%
%   SCORSIMLABBENCH(scorSim,'Clear') clears all objects placed on the lab
%   bench.
%
%   SCORSIMLABBENCH(scorSim,'Disable') disables the drawing functionality.
%
%   See also ScorSimDraw
%
%   M. Kutzer, 28Oct2020, USNA

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

% Disable drawing
ScorSimDraw(scorSim,'Disable');
if nargin > 1
    switch lower(varargin{2})
        case 'clear'
            h_x2l = findobj('Parent',scorSim.LabBench,'Type','hgtransform');
            delete(h_x2l);
        case 'disable'
            h_x2l = findobj('Parent',scorSim.LabBench,'Type','hgtransform');
            delete(h_x2l);
            set(scorSim.LabBench,'Visible','off');
            return
    end
end

%% Show lab bench 
set(scorSim.LabBench,'Visible','on');

%% Update noisy background
xx = 1000;
yy = 1000;
bkTag = 'LabBenchBackground';
bk = uint8(255 *...
    (repmat(reshape([0.96,0.96,0.86],1,1,3),xx,yy)...
    + (rand(xx,yy,3) - 0.5*ones(xx,yy,3))*0.3));
h_bk2l = findobj('Parent',scorSim.LabBench,'Tag',bkTag,'Type','hgtransform');
if isempty(h_bk2l)
    h_bk2l = hgtransform('Parent',scorSim.LabBench,...
        'Matrix',Tx(-300)*Ty(-yy/2)*Tz(-20),'Tag',bkTag);
end
img = findobj('Parent',h_bk2l,'Tag',bkTag,'Type','hgtransform');
if isempty(img)
    img = imshow(bk,'Parent',scorSim.Axes);
    set(img,'Parent',h_bk2l,'Tag',bkTag);
else
    set(img,'CData',bk);
end
set(scorSim.Axes,'Visible','on');

%% Move the light
lgt = addSingleLight(scorSim.Axes);
pos = [2*(rand(1,2)-0.5), 0.7 + rand(1)];
set(lgt,'Position',pos);
