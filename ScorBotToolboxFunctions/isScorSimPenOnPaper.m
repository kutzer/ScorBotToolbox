function [tf,msg] = isScorSimPenOnPaper(varargin)
% ISSCORSIMPENONPAPER checks to see if the ScorSimDraw pen is in contact
% with the paper
%   [tf,msg] = ISSCORSIMPENONPAPER(scorSim) 
%
%   M. Kutzer, 18Aug2020, USNA

preamble = 'ScorSimDraw';

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

%% Check if the drawing tool is active
str = get(scorSim.DrawText,'String');
if ~iscell(str)
    switch lower( get(scorSim.DrawText,'String') )
        case 'inactive.'
            tf = false;
            msg = 'Inactive';
            return
    end
end

%% Get transformations
buffer = 10; % +/- 10mm buffer (assum pen has spring travel) 
H_p2w = getAbsoluteTransform(scorSim.Paper);
H_t2w = getAbsoluteTransform(scorSim.DrawTool);

H_t2p = invSE(H_p2w)*H_t2w; % Pen tip relative to paper frame

if abs( H_t2p(3,4) ) <= buffer
    % Pen is close enough to the table plane
    
elseif H_t2p(3,4) > buffer
    tf = false;
    msg = 'Off Table.';
    set(scorSim.DrawText,'String',sprintf('%s\n%s',preamble,msg));
    set(scorSim.DrawFlag,'FaceColor','y');
    appendInkPoint(scorSim,nan(3,1));
    return
elseif H_t2p(3,4) < buffer
    tf = false;
    msg = 'Table Impact!';
    set(scorSim.DrawText,'String',sprintf('%s\n%s',preamble,msg));
    set(scorSim.DrawFlag,'FaceColor','r');
    appendInkPoint(scorSim,nan(3,1));
    return
end

%% Get paper size
ptc = findobj(scorSim.Paper,'Type','Patch');
x = ptc.Vertices(:,1);
y = ptc.Vertices(:,2);
in = inpolygon(H_t2p(1,4),H_t2p(2,4),x,y);
if in
    tf = true;
    msg = 'Drawing!';
    set(scorSim.DrawText,'String',sprintf('%s\n%s',preamble,msg));
    set(scorSim.DrawFlag,'FaceColor','g');
    appendInkPoint(scorSim,[H_t2p(1,4); H_t2p(2,4); 0.05]);
    return
else
    tf = false;
    msg = 'Off Page.';
    set(scorSim.DrawText,'String',sprintf('%s\n%s',preamble,msg));
    set(scorSim.DrawFlag,'FaceColor','y');
    appendInkPoint(scorSim,nan(3,1));
    return
end

end

function appendInkPoint(sim,X_new_p)
ZERO = 1e-3;

% Get ink positions
X_p(1,:) = get(sim.DrawLine,'XData');
X_p(2,:) = get(sim.DrawLine,'YData');
X_p(3,:) = get(sim.DrawLine,'ZData');

% Check if we are appending nan
if any( isnan(X_new_p) )
    if any(isnan( X_p(:,end) ))
        % NaN breakpoint already exists
        return
    else
        X_p(:,end+1) = nan;
    end
else
    if any(isnan( X_p(:,end) ))
        X_p(:,end+1) = X_new_p;
    elseif norm(X_new_p - X_p(:,end)) > ZERO
        X_p(:,end+1) = X_new_p;
    else
        % Points are close together, ignore new point to save memory
        return
    end
end

set(sim.DrawLine,'XData',X_p(1,:),'YData',X_p(2,:),'ZData',X_p(3,:));

end