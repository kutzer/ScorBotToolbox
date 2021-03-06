function confirm = ScorSimSetDeltaBSEPR(varargin)
% SCORSIMSETDELTABSEPR set the ScorBot visualization by increments 
%   specified in the 5-element joint configuration.
%   SCORSIMSETDELTABSEPR(scorSim,BSEPR) set the ScorBot visualization 
%   specified in "scorSim" by increments specified in the 5-element joint 
%   configuration "BSEPR".
%       DeltaBSEPR - 5-element joint vector in radians
%           DeltaBSEPR(1) - relative base joint movement angle in radians
%           DeltaBSEPR(2) - relative shoulder joint movement angle in radians
%           DeltaBSEPR(3) - relative elbow joint movement angle in radians
%           DeltaBSEPR(4) - relative wrist pitch movement angle in radians
%           DeltaBSEPR(5) - relative wrist roll movement angle in radians
%
%   SCORSIMSETDELTABSEPR(...,'MoveType',mode) specifies whether the  
%   movement is linear in task space or linear in joint space.
%       Mode: {'LinearTask' ['LinearJoint'] 'Instant'}
%
%   confirm = SCORSIMSETDELTABSEPR(___) returns 1 if successful and 0 
%   otherwise.
%
%   See also ScorSimInit ScorSimSetBSEPR ScorSimSetDeltaXYZPR
%
%   M. Kutzer, 25Sep2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated to add "confirm" output
%   20Aug2020 - Added 'MoveType' for interpolation and better aligned 
%               documentation with ScorSet* equivalent function

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,DeltaBSEPR);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,DeltaBSEPR);" to execute this function.'],txt,mfilename);
    end
end
% No dBSEPR
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:NoDeltaBSEPR',...
        ['Change in joint configuration must be specified.',...
        '\n\t-> Use "%s(%s,DeltaBSEPR)".'],mfilename,txt);
end
% Check dBSEPR
if nargin >= 2
    dBSEPR = varargin{2};
    if ~isnumeric(dBSEPR) || numel(dBSEPR) ~= 5
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadDeltaBSEPR',...
            ['Change in joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "%s(%s,[DeltaJoint1,DeltaJoint2,...,DeltaJoint5])".'],mfilename,txt);
    end
end
% Set default move type
mType = 'LinearJoint';
mName = mfilename;
if numel(mName) >= 11, vName = mName(11:end); else, vName = 'q'; end
% Check property designator
if nargin >= 3
    pType = varargin{3};
    if ~ischar(pType) || ~strcmpi('MoveType',pType)
        error('ScorSimSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearJoint'')"',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearTask'')", or',....
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''Instant'')".'],...
            pType,mName,vName,mName,vName,mName,vName);
    end
    if nargin < 4
        error('ScorSimSet:NoPropVal',...
            ['No property value for "%s" specified.',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearJoint'')"',...
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearTask'')", or',....
            '\n\t-> Use "%s(scorSim,%s,''MoveType'',''Instant'')".'],...
            pType,mName,vName,mName,vName,mName,vName);
    end
end
% Check property value
if nargin >= 4
    mType = varargin{4};
    switch lower(mType)
        case 'linearjoint'
            % Linear move in joint space
        case 'lineartask'
            % Linear move in task space
	case 'instant'
            % Instant move 
        otherwise
            error('ScorSimSet:BadPropVal',...
                ['Unexpected property value: "%s".',...
                '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearJoint'')"',...
                '\n\t-> Use "%s(scorSim,%s,''MoveType'',''LinearTask'')", or',....
                '\n\t-> Use "%s(scorSim,%s,''MoveType'',''Instant'')".'],...
                mType,mName,vName,mName,vName,mName,vName);
    end
end
% Check for too many inputs
if nargin > 4
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Move simulation
BSEPR = ScorSimGetBSEPR(scorSim);
BSEPR = BSEPR + dBSEPR;
confirm = ScorSimSetBSEPR(scorSim,BSEPR,'MoveType',mType);
