function varargout = ScorWaitForMove(varargin)
% SCORWAITFORMOVE waits for current move to complete.
%   SCORWAITFORMOVE waits for current move to complete. If no inputs or
%   outputs are specified, a progress message will appear in the command
%   prompt.
%
%   NOTE: For an accurate BSEPR or XYZPR value when the robot has completed 
%   its move, it is recommended to use a "pause(2)" following the 
%   completion of ScorWaitForMove.
%
%   NOTE: To minimize the wait time between movements in applications that
%   do not require data acquisition during or after a movement, consider
%   using "while ScorIsMoving; end" instead of ScorWaitForMove.
%
%   SCORWAITFORMOVE('PropertyName',PropertyValue)
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
%                      PlotHandle.RobotAnimation - Robot animation handles
%         CollectData: {'On' ['Off']}
%
%       XYPRPlot - plot XYZPR parameters as a function of time as ScorBot
%           executes a move.
%       BSEPRPlot - plot BSEPR parameters as a function of time as ScorBot
%           executes a move.
%       RobotAnimation - plot ScorBot DH frames and end-effector pose
%           evolution as ScorBot executes a move.
%       PlotHandle - specify a struct containing the plot handles as
%           specified above. This is primarily used to avoid creating
%           multiple figures for recursive calls of ScorWaitForMove with
%           plots or animations enabled.
%       CollectData - collect time stamped XYZPR and BSEPR data into a
%           structured array.
%
%   NOTE: When using plots, animations, or collecting data, a "pause(2)" is
%   automatically used to collect the trailing data points following
%   ScorBot's execution of a move.
%
%   confirm = SCORWAITFORMOVE(___) returns 1 if successful and 0 otherwise.
%   
%   NOTE: Specifying one or more outputs for this function disables the 
%   command line progress display "Executing move..." 
%
%   [confirm,PlotHandle] = SCORWAITFORMOVE(___) returns binary confirming
%   success, and the plot handle structured array.
%
%   [confirm,PlotHandle,CollectedData] = SCORWAITFORMOVE(___) returns 
%   binary confirming success, the plot handle structured array, and data
%   collected during the move.
%       CollectedData.tXYZPR - Nx6 array containing [timeStamp (sec), XYZPR]
%       CollectedData.tBSEPR - Nx6 array containing [timeStamp (sec), BSEPR]
%
%   Examples:
%
%   Setup for Examples:
%       % Initialize and home ScorBot
%       ScorInit;
%       ScorHome;
%
%   Example 1: ScorWaitForHome without plots or progress display
%       % Define two joint positions
%       BSEPR(1,:) = [0,pi/2,-pi/2,-pi/2,0];
%       BSEPR(2,:) = [0,pi/2,-0.10,-pi/2,0];
%       % Initialize arm configuration
%       ScorSetSpeed(100);
%       ScorSetBSEPR(BSEPR(1,:));
%       ScorWaitForMove;
%
%       % ScorWaitForHome without plots or progress display
%       fprintf('Demonstrating without command line progress display.\n');
%       ScorSetBSEPR(BSEPR(1,:));
%       confirm = ScorWaitForMove;
%
%   Example 2: ScorWaitForHome with progress display
%       % Define two joint positions
%       BSEPR(1,:) = [0,pi/2,-pi/2,-pi/2,0];
%       BSEPR(2,:) = [0,pi/2,-0.10,-pi/2,0];
%       % Initialize arm configuration
%       ScorSetSpeed(100);
%       ScorSetBSEPR(BSEPR(2,:));
%       ScorWaitForMove;
%
%       % ScorWaitForMove with command line progress display
%       fprintf('Demonstrating command line progress display.\n');
%       for i = 1:size(BSEPR,1)
%           ScorSetBSEPR(BSEPR(i,:));
%           ScorWaitForMove;
%       end
%
%       % ScorWaitForMove with command line progress display and sampled
%       %   waypoint
%       fprintf('Demonstrating command line progress display.\n');
%       for i = 1:size(BSEPR,1)
%           ScorSetBSEPR(BSEPR(i,:));
%           ScorWaitForMove;
%           pause(2);         % Pause to allow ScorBot to fully stop
%           q = ScorGetBSEPR; % Sampled waypoint
%           fprintf('q = [%0.3f,%0.3f,%0.3f,%0.3f,%0.3f]\n',q);
%       end
%
%   Example 3: ScorWaitForHome with all plots
%       % Define two joint positions
%       BSEPR(1,:) = [0,pi/2,-pi/2,-pi/2,0];
%       BSEPR(2,:) = [0,pi/2,-0.10,-pi/2,0];
%       % Initialize arm configuration
%       ScorSetSpeed(100);
%       ScorSetBSEPR(BSEPR(2,:));
%       ScorWaitForMove;
%
%       % ScorWaitForMove with XYZPR, BSEPR, and Animation Plots
%       h = []; % initialize variable for plot handle
%       fprintf('Demonstrating XYZPR, BSEPR, and Animation Plots.\n');
%       for i = 1:size(BSEPR,1)
%           ScorSetBSEPR(BSEPR(i,:));
%           [~,h] = ScorWaitForMove(...
%                       'XYZPRPlot','On',...
%                       'BSEPRPlot','On',...
%                       'RobotAnimation','On',...
%                       'PlotHandle',h);
%           pause(1);
%       end
%
%   Example 4: ScorWaitForHome data collection
%       % Define two joint positions
%       BSEPR(1,:) = [0,pi/2,-pi/2,-pi/2,0];
%       BSEPR(2,:) = [0,pi/2,-0.10,-pi/2,0];
%       % Initialize arm configuration
%       ScorSetSpeed(100);
%       ScorSetBSEPR(BSEPR(2,:));
%       ScorWaitForMove;
%
%       % ScorWaitForMove with data collection
%       fprintf('Demonstrating Collect Data functionality:\n');
%       for i = 1:size(BSEPR,1)
%           ScorSetBSEPR(BSEPR(i,:));
%           [~,~,sData(i)] = ScorWaitForMove('CollectData','On');
%       end
%
%   Example 4.1: Combining and plotting data from multiple moves
%       % Combine data
%       tBSEPR = sData(1).tBSEPR;
%       tXYZPR = sData(1).tXYZPR;
%       tBSEPR = [tBSEPR;...
%           bsxfun(@plus,tBSEPR(end,1),sData(2).tBSEPR(:,1)),... % append time 
%           sData(2).tBSEPR(:,2:end)];
%       tXYZPR = [tXYZPR;...
%           bsxfun(@plus,tXYZPR(end,1),sData(2).tXYZPR(:,1)),... % append time 
%           sData(2).tXYZPR(:,2:end)];
%       plotColors = 'rgbmk';
%       % Plot appended BSEPR data 
%       fig = figure('Name','Appended BSEPR Plot');
%       axs = axes('Parent',fig);
%       hold on
%       xlabel('Time (s)');
%       ylabel('Angle (Radians)');
%       for i = 1:5
%           plot(axs,tBSEPR(:,1),tBSEPR(:,i+1),plotColors(i));
%       end
%       legend(axs,'Base Angle','Shoulder Angle','Elbow Angle','Wrist Pitch','Wrist Roll');
%       % Plot appended XYZ data 
%       fig = figure('Name','Appended XYZ Plot');
%       axs = axes('Parent',fig);
%       hold on
%       xlabel('Time (s)');
%       ylabel('Position (Millimeters)');
%       for i = 1:3
%           plot(axs,tXYZPR(:,1),tXYZPR(:,i+1),plotColors(i));
%       end
%       legend(axs(1),'x-pos','y-pos','z-pos');
%
%   See also ScorSetMoveTime ScorSetXYZPR ScorSetBSEPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function names:
%               "ScorWaitUntilDone.m"
%               "ScorBlockUntilMotionComplete.m"
%       
%   M. Kutzer, 13Aug2015, USNA

% Updates
%   25Aug2015 - Updated to correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   25Aug2015 - Updated RobotAnimation to include previous trajectories in
%               plot.
%   28Aug2015 - Updated help documentation to include a note about 2 second
%               pause that is added when data is collected or if
%               plots/animations are used.
%   28Aug2015 - Updated error handling
%   15Sep2015 - Added timeout to execute quick move, and execute regular
%               move
%   13Oct2015 - Bad property value identification in error
%   20Oct2015 - Updated "quick move" to include a wait for the change in
%               joint angles to drop below a threshold.
%   08Jan2016 - Error fix to set general "showProgress" default
%   08Jan2016 - Error fix to set general "iter" default
%   23Aug2016 - Corrected typo in help documentation.
%   01Sep2016 - Added comments to examples
%   01Sep2016 - Added rapid movement note, "while ScorIsMoving; end"

% Known Issues
%   15Sep2015 - Running ScorWaitForMove immediately following a
%               ScorSetTeachPendant('Auto') when the teach pendant is in 
%               'Teach' will result in a "TIMEOUT" 

%% Start timer
t_swfm = tic; 

%% Check number of outputs 
nargoutchk(0,3);

%% Initialize plot handle
h.XYZPRPlot = [];
h.BSEPRPlot = [];
h.RobotAnimation = [];

%% Initialize data structure
CollectedData.tXYZPR = [];
CollectedData.tBSEPR = [];

%% Check for ScorBot Error
isReady = ScorIsReady;
if ~isReady
    if nargout > 0
        varargout{1} = false;
    end
    if nargout > 1
        varargout{2} = h;
    end
    if nargout > 2
        varargout{3} = CollectedData;
    end
    return
end

%% Initialize flags
posOn = false;   % XYZPR Plot flag
jntOn = false;   % BSEPR Plot flag
robOn = false;   % Robot Animation flag
getData = false; % Collect XYZPR and BSEPR data flag 

%% Process inputs
% Check number of inputs
n = nargin;
if n/2 ~= round(n/2)
    error('Inputs must be specified as Property Name, Property Value pairs.');
end
% Parse inputs
for i = 1:2:n
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
        case 'robotanimation'
            switch lower(varargin{i+1})
                case 'on'
                    robOn = true;
                case 'off'
                    robOn = false;
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
    BSEPR(1,:) = ScorGetBSEPR;
    while ScorIsMoving
        % Update current joint state
        BSEPR(2,:) = ScorGetBSEPR;
        % Check movement
        if size(BSEPR,1) > 1 && toc(t_swfm) > 5
            dBSEPR = diff(BSEPR((end-1:end),:),1,1);
            if norm(dBSEPR) < 1e-8
                [isReady,~,errStruct] = ScorIsReady;
                if ~isReady
                    if showProgress
                        fprintf( char(repmat(8,1,mod(iter,4))) );
                        fprintf('...');
                        fprintf('FAILED\n');
                        ScorDispError(errStruct);
                    else
                        ScorDispError(errStruct);
                    end
                    confirm = false;
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
                else
                    if toc(t_swfm) > 8
                        if showProgress
                            fprintf( char(repmat(8,1,mod(iter,4))) );
                            fprintf('...');
                            fprintf('TIMEOUT\n');
                            ScorDispError(errStruct);
                            return
                        end
                    end
                end
            end
        end
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
            pause(0.10);
        else
            pause(0.01);
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
    % Wait for move to actually complete
    dq = inf(1,5);
    q(1,:) = ScorGetBSEPR;
    while norm(dq) > 1e-8
        pause(0.05);
        q(2,:) = ScorGetBSEPR;
        dq = diff(q,1);
        q(1,:) = q(2,:);
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
if ~isfield(h,'RobotAnimation')
    h.RobotAnimation = [];
else
    wipeRob = false;
    if ~isfield(h.RobotAnimation,'Sim')
        wipeRob = true;
    else
        if ~isfield(h.RobotAnimation.Sim,'Joints')
            wipeRob = true;
        end
    end
    if ~isfield(h.RobotAnimation,'Plot')
        wipeRob = true;
    end
    if ~isfield(h.RobotAnimation,'Waypoint')
        wipeRob = true;
    end
    if wipeRob
        h.RobotAnimation = [];
    end
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
    if ~isempty(h.RobotAnimation)
        if ~ishandle(h.RobotAnimation.Sim.Joints(i)) || ~ishandle(h.RobotAnimation.Plot)
            h.RobotAnimation = [];
        end
    end
end
% create XYZPR figure
if posOn && isempty(h.XYZPRPlot)
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
end
% create BSEPR figure
if jntOn && isempty(h.BSEPRPlot)
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
end
% create robot animation figure
if robOn && isempty(h.RobotAnimation)
    h.RobotAnimation.Sim = ScorSimInit;
    h.RobotAnimation.Plot = plot3(h.RobotAnimation.Sim.Axes,0,0,0,'m');
    h.RobotAnimation.Waypoint = [];
end

%% Wait for motion
confirm = true;
posT = [];
BSEPR = [];
jntT = [];
XYZPR = [];
newWaypoint = true;
while ScorIsMoving
    % Get XYZPR
    posT(end+1) = toc(t_swfm);
    tmp = ScorGetXYZPR;
    if ~isempty(tmp)
        XYZPR(end+1,:) = tmp;
    else
        posT(end) = [];
    end
    % Get BSEPR
    jntT(end+1) = toc(t_swfm);
    tmp = ScorGetBSEPR;
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
            if robOn
                ScorSimSetBSEPR(h.RobotAnimation.Sim,BSEPR(end,:));
                % Plot starting waypoint
                if size(XYZPR,1) == 1 && newWaypoint
                    h.RobotAnimation.Waypoint(end+1) = ...
                        plot3(h.RobotAnimation.Sim.Axes,...
                        XYZPR(1,1),XYZPR(1,2),XYZPR(1,3),'og');
                    newWaypoint = false;
                end
                % Get previous plot data
                xData = get(h.RobotAnimation.Plot,'xData');
                yData = get(h.RobotAnimation.Plot,'yData');
                zData = get(h.RobotAnimation.Plot,'zData');
                % Remove initialized point
                if numel(xData) == 1
                    if xData == 0 && yData == 0 && zData == 0
                        xData = [];
                        yData = [];
                        zData = [];
                    end
                end
                % Append new data
                xData(end+1) = XYZPR(end,1);
                yData(end+1) = XYZPR(end,2);
                zData(end+1) = XYZPR(end,3);
                % Update trajectory plot
                set(h.RobotAnimation.Plot,...
                    'xData',xData,...
                    'yData',yData,...
                    'zData',zData);
            end
        end
    end
    % Drawnow
    if posOn || jntOn || robOn
        drawnow
    end
    % Check movement
    if size(BSEPR,1) > 1 && toc(t_swfm) > 5
        dBSEPR = diff(BSEPR((end-1:end),:),1,1);
        if norm(dBSEPR) < 1e-8
            [isReady,~,errStruct] = ScorIsReady;
            if ~isReady
                ScorDispError(errStruct);
                confirm = false;
                break
            else
                if toc(t_swfm) > 8
                    if showProgress
                        fprintf( char(repmat(8,1,mod(iter,4))) );
                        fprintf('...');
                        fprintf('TIMEOUT\n');
                        ScorDispError(errStruct);
                        return
                    end
                end
            end
        end
    end
end

%% Add final points to collected data and plots
t_dwell = 1.2; % dwell time following ~ScorIsMoving
t_dwell_strt = toc(t_swfm);
dBSEPR = ones(1,5);
while norm(dBSEPR) > 1e-8 || (toc(t_swfm)-t_dwell_strt) < t_dwell
    if size(BSEPR,1) > 1
        dBSEPR = diff(BSEPR((end-1:end),:),1,1);
    end
    % Get XYZPR
    posT(end+1) = toc(t_swfm);
    tmp = ScorGetXYZPR;
    if ~isempty(tmp)
        XYZPR(end+1,:) = tmp;
    else
        posT(end) = [];
    end
    % Get BSEPR
    jntT(end+1) = toc(t_swfm);
    tmp = ScorGetBSEPR;
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
            if robOn
                ScorSimSetBSEPR(h.RobotAnimation.Sim,BSEPR(end,:));
                % Get previous plot data
                xData = get(h.RobotAnimation.Plot,'xData');
                yData = get(h.RobotAnimation.Plot,'yData');
                zData = get(h.RobotAnimation.Plot,'zData');
                % Remove initialized point
                if numel(xData) == 1
                    if xData == 0 && yData == 0 && zData == 0
                        xData = [];
                        yData = [];
                        zData = [];
                    end
                end
                % Append new data
                xData(end+1) = XYZPR(end,1);
                yData(end+1) = XYZPR(end,2);
                zData(end+1) = XYZPR(end,3);
                % Update trajectory plot
                set(h.RobotAnimation.Plot,...
                    'xData',xData,...
                    'yData',yData,...
                    'zData',zData);
            end
        end
    end
    % Drawnow
    if posOn || jntOn || robOn
        drawnow
    end
end

% Add final waypoint
if robOn
    % Plot final waypoint
    if size(XYZPR,1) >= 1
        h.RobotAnimation.Waypoint(end+1) = ...
            plot3(h.RobotAnimation.Sim.Axes,...
            XYZPR(end,1),XYZPR(end,2),XYZPR(end,3),'xr');
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
