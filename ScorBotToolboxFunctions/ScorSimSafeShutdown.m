function varargout = ScorSimSafeShutdown(varargin)
% SCORSIMSAFESHUTDOWN runs all processes to safely close the ScorBot 
% simulation.
%   SCORSIMSAFESHUTDOWN(scorSim) closes the ScorBot simulation.
%
%   confirm = SCORSIMSAFESHUTDOWN(___) returns 1 if successful and 0 
%   otherwise.
%
%   M. Kutzer, 24Aug2020, USNA

confirm = false;

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
% TODO - use varargin to specify simple/complex and coarse/fine
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Close all teach figures
tags = {...
    'ScorSim XYZPR Teach, Do Not Change',...
    'ScorSim BSEPR Teach, Do Not Change'};

fprintf('Closing teach mode windows...');
for i = 1:numel(tags)
    figs = findobj(0,'Type','Figure','Tag',tags{i});
    delete(figs);
end
fprintf('[COMPLETE]\n');
drawnow;

%% Close simulation
fprintf('Closing simulation window...');
if ishandle(scorSim.Figure)
    delete(scorSim.Figure);
    fprintf('[COMPLETE]\n');
else
    fprintf('[NOT VALID HANDLE, FAILED]\n');
end

%% Clear the simulation struct from the workspace
vInName = inputname(1);
assignin('base',vInName,[]);

confirm = true;
if nargout > 0
    varargout{1} = confirm;
end

