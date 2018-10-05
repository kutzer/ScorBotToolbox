function txt = ScorErrorLastInit
% SCORERRORLASTINIT creates a text object handle within the
% ScorSafeShutdown figure for tracking error codes.
%   txt = SCORERRORLASTINIT returns the handle for the text object created
%   to monitor the last error code.
%
%   See also ScorErrorLastGet ScorErrorLastSet
%
%   M. Kutzer, 25Sep2018, USNA

%% Define shutdown figure handle
ShutdownFig = 1845;

% Check for valid shutdown figure
if ~ishandle(ShutdownFig)
    % ScorBot has not been initialized
    return
end

%% Get/create axes
% Check for existing axes
axs = findobj(ShutdownFig,'Tag','ScorBot Handle, Shutdown Axes');
% Create axes if one does not exist
if isempty(axs)
    axs = axes('Parent',ShutdownFig,'Visible','off','Tag','ScorBot Handle, Shutdown Axes');
end

%% Create text object to contain the last error
% Check for existing handle
txt = findobj(ShutdownFig,'Tag','ScorBot Handle, Last Error');
% Create new text handle if one does not exist
if isempty(txt)
    txt = text(0,0,'0','Parent',axs,'Tag','ScorBot Handle, Last Error');
end