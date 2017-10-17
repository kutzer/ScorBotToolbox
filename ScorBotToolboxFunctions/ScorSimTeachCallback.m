function ScorSimTeachCallback(src, callbackdata)
% SCORSIMTEACHCALLBACK callback function to enable teach mode of the
% ScorBot Simulation.
%
%   NOTE: This function is not intended for general use.
%
%   M. Kutzer, 16Oct2015, USNA

% Updates
%   23Oct2015 - Updates to status indicator.
%   17Oct2017 - Updated comments.

%% Declare globals
global scorSimGlobalVariable scorSimTeachBSEPR scorSimTeachXYZPR

%% Initialize global variables
if isempty(scorSimGlobalVariable)
    scorSimGlobalVariable.Figure = [];
end

if isempty(scorSimTeachBSEPR)
    scorSimTeachBSEPR = false;
end

if isempty(scorSimTeachXYZPR)
    scorSimTeachXYZPR = false;
end

simObj = scorSimGlobalVariable;

% Source tag info
tag_src = get(src,'Tag');
tag_XYZPR = 'ScorSim XYZPR Teach, Do Not Change';
tag_BSEPR = 'ScorSim BSEPR Teach, Do Not Change';

%% Update status
% If handle is no longer valid, ignore
if isempty(simObj.Figure)
    scorSimGlobalVariable.Figure = [];
    scorSimTeachBSEPR = false;
    scorSimTeachXYZPR = false;
    switch tag_src
        case tag_XYZPR
            warning('No valid ScorBot simulation specified. Closing Teach window.');
            close(src);
            return
        case tag_BSEPR
            warning('No valid ScorBot simulation specified. Closing Teach window.');
            close(src);
            return
    end
    return
end
% If handle is no longer valid, ignore
if ~ishandle(simObj.Figure)
    scorSimGlobalVariable.Figure = [];
    scorSimTeachBSEPR = false;
    scorSimTeachXYZPR = false;
    switch tag_src
        case tag_XYZPR
            warning('No valid ScorBot simulation specified. Closing Teach window.');
            close(src);
            return
        case tag_BSEPR
            warning('No valid ScorBot simulation specified. Closing Teach window.');
            close(src);
            return
    end
    return
end
% If both teach flags are false, update status and ignore
if ~scorSimTeachBSEPR && ~scorSimTeachXYZPR
    closeTeach;
    return
end

%% Confirm and set simObj
if ~isempty(simObj)
    num_glbl = get(simObj.Figure,'Number');
    num_clbk = get(src,'Number');
    if num_glbl == num_clbk
        % Update simulation
    else
        % Update global variable
        switch tag_src
            case tag_XYZPR
                if scorSimTeachXYZPR
                    % Continue
                else
                    % Close figure
                    closeTeach;
                    warning('No valid ScorBot simulation specified. Closing Teach window.');
                    close(src);
                    return
                end
            case tag_BSEPR
                if scorSimTeachBSEPR
                    % Continue
                else
                    % Close figure
                    closeTeach;
                    warning('No valid ScorBot simulation specified. Closing Teach window.');
                    close(src);
                    return
                end
            otherwise
                closeTeach;
                return
        end
    end
else
    closeTeach;
    return
end

%% Initialize parameters
angScale = 0.0175; % Angular resolution (radians)
linScale = 1.0000; % Linear resolution (millimeters)
if scorSimTeachBSEPR
    teachStr = 'BSEPR Teach';
    set([simObj.TeachFlag,simObj.TeachText],'Visible','on');
    scale = angScale;
else
    teachStr = 'XYZPR Teach';
    set([simObj.TeachFlag,simObj.TeachText],'Visible','on');
    scale = linScale;
end

delta = [0,0,0,0,0];

%% Parse key
switch lower(callbackdata.Key)
    case 'numpad7'
        % -x / -b
        statusBusy;
        delta = -scale*[1,0,0,0,0];
    case 'numpad9'
        % +x / +b
        statusBusy;
        delta =  scale*[1,0,0,0,0];
    case 'numpad4'
        % -y / -s
        statusBusy;
        delta = -scale*[0,1,0,0,0];
    case 'numpad6'
        % +y / +s
        statusBusy;
        delta =  scale*[0,1,0,0,0];
    case 'numpad1'
        % -z / -e
        statusBusy;
        delta = -scale*[0,0,1,0,0];
    case 'numpad3'
        % +z / +e
        statusBusy;
        delta =  scale*[0,0,1,0,0];
    case '7'
        % -x / -b
        statusBusy;
        delta = -scale*[1,0,0,0,0];
    case '9'
        % +x / +b
        statusBusy;
        delta =  scale*[1,0,0,0,0];
    case '4'
        % -y / -s
        statusBusy;
        delta = -scale*[0,1,0,0,0];
    case '6'
        % +y / +s
        statusBusy;
        delta =  scale*[0,1,0,0,0];
    case '1'
        % -z / -e
        statusBusy;
        delta = -scale*[0,0,1,0,0];
    case '3'
        % +z / +e
        statusBusy;
        delta =  scale*[0,0,1,0,0];
    case 'leftarrow'
        % -p / -p
        statusBusy;
        delta = -angScale*[0,0,0,1,0];
    case 'rightarrow'
        % +p / +p
        statusBusy;
        delta =  angScale*[0,0,0,1,0];
    case 'downarrow'
        % -r / -r
        statusBusy;
        delta = -angScale*[0,0,0,0,1];
    case 'uparrow'
        % +r / +r
        statusBusy;
        delta =  angScale*[0,0,0,0,1];
    case 'space'
        statusBusy;
        % Initialize grip
        grip = ScorSimGetGripper(simObj);
        % Choose open vs close with shift modifier
        if numel(callbackdata.Modifier) == 1
            if strcmpi('shift',callbackdata.Modifier{1});
                openFlag = false;
            else
                openFlag = true;
            end
        else
            openFlag = true;
        end
        % Update gripper value
        if openFlag
            grip = grip + 1;
            if grip > 70
                grip = 70;
            end
        else
            grip = grip - 1;
            if grip < 0
                grip = 0;
            end
        end
        % Set grip
        ScorSimSetGripper(simObj,grip);
        % Refresh data
        drawnow
        % Set ready indicator
        statusReady;
        return
    otherwise
        return
end

%% Set simulation
if scorSimTeachBSEPR
    BSEPR = ScorSimGetBSEPR(simObj);
    BSEPR = BSEPR + delta;
    ScorSimSetBSEPR(simObj,BSEPR);
    
    % Refresh data
    drawnow
    % Set ready indicator
    statusReady;
end

if scorSimTeachXYZPR
    % Inverse kinematics method
    XYZPR = ScorSimGetXYZPR(simObj);
    XYZPR = XYZPR + delta;
    ScorSimSetXYZPR(simObj,XYZPR);
    
    % Jacobian method
    %BSEPR = ScorSimGetBSEPR(simObj);
    %J = ScorXYZPRJacobian(BSEPR);
    %dq = minv(J)*delta';
    %dq = dq/norm(dq);
    %dq = angScale*dq;
    %BSEPR = BSEPR + dq';
    %ScorSimSetBSEPR(simObj,BSEPR);
    
    % Refresh data
    drawnow
    % Set ready indicator
    statusReady;
end

%% Internal functions
function closeTeach
    set(simObj.TeachFlag,'FaceColor','w');
    set(simObj.TeachText,'String','Inactive.');
    set([simObj.TeachFlag,simObj.TeachText],'Visible','off');
end

function statusBusy
    statusStr = 'Busy...';
    set(simObj.TeachFlag,'FaceColor','r');
    set(simObj.TeachText,'String',sprintf('%s\n%s',teachStr,statusStr));
end

function statusReady
    readyStr = 'Ready.';
    set(simObj.TeachFlag,'FaceColor','g');
    set(simObj.TeachText,'String',sprintf('%s\n%s',teachStr,readyStr));
end

end
