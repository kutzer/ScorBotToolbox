function varargout = ScorSimWaitForMove(varargin)
% SCORSIMWAITFORMOVE waits for current simulated move to complete.
%   SCORSIMWAITFORMOVE(simObj) waits for current move to complete. If no 
%   additional inputs or outputs are specified, a progress message will 
%   appear in the command prompt.
%
%   SCORSIMWAITFORMOVE(simObj,'PropertyName',PropertyValue)
%
%   NOTE: Setting one or more plot or data paramter to 'On' disables the
%   command line progress display "Executing move..."
%
%       Property Name: {PropertyValues}
%           XYZPRPlot: {'On' ['Off']}
%           BSEPRPlot: {'On' ['Off']}
%      RobotAnimation: {'On' ['Off']}
%          PlotHandle: Structured array containing plot information
%                      PlotHandle.XYZPRPlot - XYZPRPlot handles
%                      PlotHandle.BSEPRPlot - BSEPRPlot handles
%         CollectData: {'On' ['Off']}
%
%       XYPRPlot - plot XYZPR parameters as a function of time as ScorBot
%           executes a move.
%       BSEPRPlot - plot BSEPR parameters as a function of time as ScorBot
%           executes a move.
%       PlotHandle - specify a struct containing the plot handles as
%           specified above. This is primarily used to avoid creating
%           multiple figures for recursive calls of ScorWaitForMove with
%           plots or animations enabled.
%       CollectData - collect time stamped XYZPR and BSEPR data into a
%           structured array.
%
%   confirm = SCORSIMWAITFORMOVE(___) returns 1 if successful and 0 
%   otherwise.
%   
%   NOTE: Specifying one or more outputs for this function disables the 
%   command line progress display "Executing move..." 
%
%   [confirm,PlotHandle] = SCORSIMWAITFORMOVE(___) returns binary 
%   confirming success, and the plot handle structured array.
%
%   [confirm,PlotHandle,CollectedData] = SCORSIMWAITFORMOVE(___) returns 
%   binary confirming success, the plot handle structured array, and data
%   collected during the move.
%       CollectedData.tXYZPR - Nx6 array containing [timeStamp (sec), XYZPR]
%       CollectedData.tBSEPR - Nx6 array containing [timeStamp (sec), BSEPR]
%
%   M. Kutzer, 21Aug2020, USNA

%% Start timer
t_swfm = tic; 

%% Check number of outputs 
nargoutchk(0,3);

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

%% Initialize plot handle
h.XYZPRPlot = [];
h.BSEPRPlot = [];

%% Initialize data structure
CollectedData.tXYZPR = [];
CollectedData.tBSEPR = [];

%% Initialize flags
posOn = false;   % XYZPR Plot flag
jntOn = false;   % BSEPR Plot flag
robOn = false;   % Robot Animation flag
getData = false; % Collect XYZPR and BSEPR data flag 

%% Process inputs
% Check number of inputs
n = nargin;
n = n - 1; % Account for scorSim (required input)
if n/2 ~= round(n/2)
    error('Inputs must be specified as Property Name, Property Value pairs.');
end
% Parse inputs
for i = 2:2:n
    switch lower(varargin{i})
        case 'xyzprplot'
            switch lower(varargin{i+1})
                case 'on'
                    posOn = true;
                case 'off'
                    posOn = false;
                otherwise
                    error('Unexpected property value for "%s".',varargin{i});
            end
        case 'bseprplot'
            switch lower(varargin{i+1})
                case 'on'
                    jntOn = true;
                case 'off'
                    jntOn = false;
                otherwise
                    error('Unexpected property value for "%s".',varargin{i});
            end
        case 'plothandle'
            h = varargin{i+1};
        case 'collectdata'
            switch lower(varargin{i+1})
                case 'on'
                    getData = true;
                case 'off'
                    getData = false;
                otherwise
                    error('Unexpected property value for "%s".',varargin{i});
            end
        otherwise
            error(sprintf('Unexpected Property Name "%s".',varargin{i}));
    end
end

% -------------------------------------------------------------------------

%% Execute quick move when no data or plots are required
iter = 0; % set default value
showProgress = false; % set default value
if ~posOn && ~jntOn && ~robOn && ~getData
    % Show progress in command window if no outputs are declared
    if nargout == 0
        showProgress = true;
    else
        showProgress = false;
    end
    if showProgress
        fprintf('Executing move...');
    end
    confirm = true;
    iter = 0;
    BSEPR(1,:) = ScorSimGetBSEPR(scorSim);
    while ScorSimIsMoving(scorSim)
        % Update current joint state
        BSEPR(2,:) = ScorSimGetBSEPR(scorSim);
        % Show progress in command window
        if showProgress
            if mod(iter,4) == 0
                fprintf(char([8,8,8]));
            else
                fprintf('.');
            end
            iter = iter+1;
        end
        if showProgress
            %pause(0.10);
        else
            %pause(0.01);
        end
        % Update initial joint state
        BSEPR(1,:) = BSEPR(2,:);
    end
    if showProgress
        fprintf( char(repmat(8,1,mod(iter-1,4))) );
        fprintf('...');
        fprintf('SUCCESS\n');
    end
    % Package output
    if nargout > 0
        varargout{1} = confirm;
    end
    if nargout > 1
        varargout{2} = h;
    end
    if nargout > 2
        varargout{3} = CollectedData;
    end
    return
end

%% Create figures
% check plot handle structure fields
if ~isfield(h,'XYZPRPlot')
    h.XYZPRPlot = [];
end
if ~isfield(h,'BSEPRPlot')
    h.BSEPRPlot = [];
end

% check plot handles
for i = 1:5
    if ~isempty(h.XYZPRPlot)
        if ~ishandle(h.XYZPRPlot(i))
            h.XYZPRPlot = [];
        end
    end
    if ~isempty(h.BSEPRPlot)
        if ~ishandle(h.BSEPRPlot(i))
            h.BSEPRPlot = [];
        end
    end
end
% create XYZPR figure
if posOn && isempty(h.XYZPRPlot)
    warning off % TODO - figure out why the warnings are being thrown!
    
    fig = figure('Name','XYZPR Data');
    set(fig,'Units','Normalized',...
        'Position',[0.0036,0.5200,2/3-0.008,0.4000],...
        'NumberTitle','Off');
    axs(1) = subplot(1,2,1,'Parent',fig);
    hold on
    axs(2) = subplot(1,2,2,'Parent',fig);
    hold on
    h.XYZPRPlot(1) = plot(axs(1),0,0,'r');
    h.XYZPRPlot(2) = plot(axs(1),0,0,'g');
    h.XYZPRPlot(3) = plot(axs(1),0,0,'b');
    h.XYZPRPlot(4) = plot(axs(2),0,0,'c');
    h.XYZPRPlot(5) = plot(axs(2),0,0,'k');
    legend(axs(1),'x-pos','y-pos','z-pos');
    legend(axs(2),'pitch','roll');
    xlabel(axs(1),'Time (s)');
    ylabel(axs(1),'Position (millimeters)');
    xlabel(axs(2),'Time (s)');
    ylabel(axs(2),'Angle (radians)');
    
    warning on  % TODO - figure out why the warnings are being thrown!
end

% create BSEPR figure
if jntOn && isempty(h.BSEPRPlot)
    warning off % TODO - figure out why the warnings are being thrown!
    
    fig = figure('Name','BSEPR Data');
    set(fig,'Units','Normalized',...
        'Position',[2/3+0.005,0.5200,1/3-0.01,0.4000],...
        'NumberTitle','Off');
    axs = axes('Parent',fig);
    hold on
    h.BSEPRPlot(1) = plot(axs,0,0,'r');
    h.BSEPRPlot(2) = plot(axs,0,0,'g');
    h.BSEPRPlot(3) = plot(axs,0,0,'b');
    h.BSEPRPlot(4) = plot(axs,0,0,'c');
    h.BSEPRPlot(5) = plot(axs,0,0,'k');
    legend(axs,'Base Angle','Shoulder Angle','Elbow Angle','Wrist Pitch','Wrist Roll');
    xlabel(axs,'Time (s)');
    ylabel(axs,'Angle (radians)');
    
    warning on  % TODO - figure out why the warnings are being thrown!
end

%% Wait for motion
confirm = true;
posT = [];
BSEPR = [];
jntT = [];
XYZPR = [];
newWaypoint = true;
while ScorSimIsMoving(scorSim)
    % Get XYZPR
    posT(end+1) = toc(t_swfm);
    tmp = ScorSimGetXYZPR(scorSim);
    if ~isempty(tmp)
        XYZPR(end+1,:) = tmp;
    else
        posT(end) = [];
    end
    % Get BSEPR
    jntT(end+1) = toc(t_swfm);
    tmp = ScorSimGetBSEPR(scorSim);
    if ~isempty(tmp)
        BSEPR(end+1,:) = tmp;
    else
        jntT(end) = [];
    end
    % Update BSEPR and XYZPR Plots
    if ~isempty(BSEPR) && ~isempty(XYZPR)
        for i = 1:5
            if posOn
                set(h.XYZPRPlot(i),'xData',posT,'yData',transpose(XYZPR(:,i)));
            end
            if jntOn
                set(h.BSEPRPlot(i),'xData',jntT,'yData',transpose(BSEPR(:,i)));
            end
        end
    end
    % Drawnow
    if posOn || jntOn
        drawnow
    end
end

%% Package data
if getData
    CollectedData.tXYZPR = [transpose(posT),XYZPR];
    CollectedData.tBSEPR = [transpose(jntT),BSEPR];
end

%% Package output
if nargout > 0
    varargout{1} = confirm;
end
if nargout > 1
    varargout{2} = h;
end
if nargout > 2
    varargout{3} = CollectedData;
end

%{
%% Wait for move 
while ScorSimIsMoving(scorSim)
    % Wait for move to finish
end
%}