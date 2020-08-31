function confirm = ScorSimSetBSEPR(varargin)
% SCORSIMSETBSEPR set the ScorBot visualization to the specified 5-element
% joint configuration.
%   SCORSIMSETBSEPR(scorSim,BSEPR) set the ScorBot visualization specified 
%   by "scorSim" to the specified 5-element joint configuration "BSEPR".
%       BSEPR - 5-element joint vector in radians
%           BSEPR(1) - base joint angle in radians
%           BSEPR(2) - shoulder joint angle in radians
%           BSEPR(3) - elbow joint angle in radians
%           BSEPR(4) - wrist pitch angle in radians
%           BSEPR(5) - wrist roll angle in radians
%
%   SCORSIMSETBSEPR(...,'MoveType',mode) specifies whether the movement is
%   linear in task space or linear in joint space.
%       Mode: {'LinearTask' ['LinearJoint'] 'Instant'}
%
%   confirm = SCORSIMSETBSEPR(___) returns 1 if successful and 0 otherwise.
%
%   Note: Wrist pitch angle of BSEPR does not equal the pitch angle of 
%   XYZPR. BSEPR pitch angle is body-fixed while the pitch angle of XYZPR 
%   is calculated relative to the base.
%
%   See also ScorSimInit ScorSimSetDeltaBSEPR ScorSimSetXYZPR
%
%   M. Kutzer, 13Aug2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking
%   30Dec2015 - Updated to add "confirm" output
%   01Sep2016 - Updated to include BSEPR/XYZPR pitch distinction
%   18Aug2020 - Added ScorSimDraw functionality
%   20Aug2020 - Added 'MoveType' for interpolation and better aligned 
%               documentation with ScorSet* equivalent function
%   25Aug2020 - Updated to include a 3-parameter coefficient
%   26Aug2020 - Updated to interpolate based on move type
%   27Aug2020 - Updated to include acceleration/deceleration
%   31Aug2020 - Added global for ScorSimWaitForMove collect data workaround

%% Declare global for ScorSimWaitForMove workaround
global ScorSimInterpGlobal

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim,BSEPR);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim,BSEPR);" to execute this function.'],txt,mfilename);
    end
end
% No BSEPR
if nargin < 2
    if isempty(inputname(1))
        txt = 'scorSim';
    else
        txt = inputname(1);
    end
    error('ScorSimSet:BadPose',...
        ['Joint configuration must be specified.',...
        '\n\t-> Use "%s(%s,BSEPR)".'],mfilename,txt);
end
% Check BSEPR
if nargin >= 2
    BSEPR = varargin{2};
    if ~isnumeric(BSEPR) || numel(BSEPR) ~= 5
        if isempty(inputname(1))
            txt = 'scorSim';
        else
            txt = inputname(1);
        end
        error('ScorSimSet:BadBSEPR',...
            ['Joint configuration must be specified as a 5-element numeric array.',...
            '\n\t-> Use "%s(%s,[Joint1,Joint2,...,Joint5]);".'],mfilename,txt);
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

confirm = false;

%% Move simulation
switch lower(mType)
    case 'linearjoint'
        coefs = [0.5,1,3.5]; % <--- Coefficients for interpolation
        % Interpolate in joint space
        q_o = ScorSimGetBSEPR(scorSim);
        q_f = BSEPR;
        
        % Check if init and goal are the same point
        ZERO = 0.001;
        if max( abs(q_f-q_o) ) < ZERO
            confirm = true;
            return
        end
        
        % Interpolate move
        [q,t] = interpSimMove(scorSim,q_o,q_f,coefs,mType);
        % Update global
        BSEPRs = q.';
        XYZPRs = interpSimBSEPR2XYZPR(q).';
        ScorSimInterpGlobal.tBSEPR = [t.',BSEPRs];
        ScorSimInterpGlobal.tXYZPR = [t.',XYZPRs];
        % Execute move
        executeSimMove(scorSim,q,'MoveType',mType);
        confirm = true;
        
    case 'lineartask'
        coefs = [0.5,1,4.5]; % <--- Coefficients for interpolation
        % Interpolate in task space
        q_o = ScorSimGetXYZPR(scorSim);
        q_f = ScorBSEPR2XYZPR(BSEPR);
        
        % Check if init and goal are the same point
        ZERO = 0.01;
        if max( abs(q_f-q_o) ) < ZERO
            confirm = true;
            return
        end
        
        [q,t] = interpSimMove(scorSim,q_o,q_f,coefs,mType);
        % Update global
        BSEPRs = interpSimXYZPR2BSEPR(q).';
        XYZPRs = q.';
        ScorSimInterpGlobal.tBSEPR = [t.',BSEPRs];
        ScorSimInterpGlobal.tXYZPR = [t.',XYZPRs];
        % Execute move
        executeSimMove(scorSim,q,'MoveType',mType);
        confirm = true;
    case 'instant'
        % Move directly to the point
        for i = 1:numel(scorSim.Joints)
            set(scorSim.Joints(i),'Matrix',Rz(BSEPR(i)));
        end
        confirm = true;
        isScorSimPenOnPaper(scorSim);
        drawnow
end