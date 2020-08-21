function executeSimMove(scorSim,q,pType,mType)

figure( scorSim.Figure );
timerName = 'timer-ScorSim';
T = timerfind('Name',timerName);

if ScorSimIsMoving(scorSim)
    if ~isempty(T)
        stop(T);
    end
    error('ScorSimSet:NoSimObj',...
        ['!!! Use ScorSimWaitForMove(simObj) !!!',...
        '\n\tThe simulation must finish a move before setting ',...
        'the next waypoint.']);
end
        
dt = 0.02;
if ~isempty(T)
    if numel(T) > 1
        stop(T(2:end));
        delete(T(2:end));
        T = T(1);
    end
else
    T = timer('name',timerName);
end

set(T,...
    'TimerFcn',@incrementMove,...
    'StartFcn',@startMove,...
    'StopFcn',@stopMove,...
    'Period',dt,...
    'ExecutionMode','FixedRate',...
    'TasksToExecute',size(q,2),...
    'Name',timerName);

start(T);

    function incrementMove(src,evt)
        if ~ScorSimIsMoving(scorSim)
            stop(T);
            error('ScorSimSet:NoSimObj',...
                ['Use ScorSimWaitForMove(simObj)!',...
                '\n\tThe simulation must finish a move before setting ',...
                'the next waypoint.']);
        end
        
        switch lower(mType)
            case 'linearjoint'
                ScorSimSetBSEPR(scorSim,q(:,1).','MoveType','Instant');
            case 'lineartask'
                ScorSimSetXYZPR(scorSim,q(:,1).','MoveType','Instant');
            otherwise
                stop(T)
                return
        end
        q(:,1) = [];  % Remove executed value of T
    end

    function startMove(src,evt)
        ScorSimIsMoving(scorSim,true);
    end

    function stopMove(src,evt)
        ScorSimIsMoving(scorSim,false);
    end
end