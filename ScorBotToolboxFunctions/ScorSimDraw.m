function confirm = ScorSimDraw(varargin)
% SCORSIMDRAW enable the ScorBot simulator drawing interface.
%   SCORSIMDRAW(scorSim) creates a lab bench, 8.5" x 11" sheet of paper,
%   and adds an end-effector "pen" offset to the ScorBot gripper.
%
%   SCORSIMDRAW(scorSim,'Clear') clears the current drawing.
%
%   SCORSIMDRAW(scorSim,'Disable') disables the drawing functionality.
%
%   SCORSIMDRAW(scorSim,'ExportPaper') copies the paper into a new figure.
%
%   M. Kutzer, 18Aug2020, USNA

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

if nargin > 1
    switch lower(varargin{2})
        case 'clear'
            set(scorSim.DrawLine,'XData',nan,'YData',nan,'ZData',nan);
            drawnow;
        case 'disable'
            set(scorSim.DrawTool,'Visible','off');
            set(scorSim.LabBench,'Visible','off');
            set(scorSim.Paper,   'Visible','off');

            set(scorSim.DrawFlag,'Visible','off');
            set(scorSim.DrawText,'String','Inactive.','Visible','off');
            set(scorSim.DrawLine,'XData',nan,'YData',nan,'ZData',nan);
            drawnow;
            return
        case 'exportpaper'
            fig = figure('Name','ScorSimDraw Paper');
            axs = axes('Parent',fig);
            daspect(axs,[1 1 1]);
            xlabel('x (mm)');
            ylabel('y (mm)');
            
            obj.Paper.Transform = copyobj(scorSim.Paper,axs);
            obj.Paper.Patch = findobj(obj.Paper.Transform,'Type','patch');
            obj.Paper.Line  = findobj(obj.Paper.Transform,'Type','line');
            
            set(obj.Paper.Patch,'EdgeColor','k');
            set(obj.Paper.Transform,'Matrix',Rz(pi/2));
            axis(axs,'tight');
        otherwise
            % TODO - add extra drawing modifiers
            warning('Unrecognized modifier.');
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
