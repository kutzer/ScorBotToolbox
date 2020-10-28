function ScorSimLabBench(varargin)
% SCORSIMLABBENCH enable the ScorBot simulator lab bench visualization.
%   SCORSIMLABBENCH(scorSim) creates a lab bench in the ScorBot simulation
%   environment. 
%
%   SCORSIMLABBENCH(scorSim,'Clear') clears all objects placed on the lab
%   bench.
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

if nargin > 1
    switch lower(varargin{2})
        case 'clear'
            set(scorSim.DrawLine,'XData',nan,'YData',nan,'ZData',nan);
            % Remove single point contacts
            tag = 'ScorSimDraw Single Point Contact';
            mom = get(scorSim.DrawLine,'Parent');
            plt = findobj('Parent',mom,'Tag',tag);
            if ~isempty(plt)
                delete(plt);
            end
            drawnow;
    end
end
%% Show lab bench 
set(scorSim.LabBench,'Visible','on');