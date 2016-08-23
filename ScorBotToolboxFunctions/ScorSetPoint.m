function confirm = ScorSetPoint(varargin)
% SCORSETPOINT creates an individual "point" within a specified "vector" 
% on the ScorBot controller.
%   SCORSETPOINT(XYZPR) adds the 5-element task-space vector containing
%   the end-effector x,y,z position and end-effector pitch and roll 
%   orientation into the default "USNA" vector into the default index of 
%   1000.
%       XYZPR - 5-element vector containing end-effector position and
%       orientation.
%           XYZPR(1) - end-effector x-position in millimeters
%           XYZPR(2) - end-effector y-position in millimeters
%           XYZPR(3) - end-effector z-position in millimeters
%           XYZPR(4) - end-effector pitch in radians
%           XYZPR(5) - end-effector roll in radians
%
%   SCORSETPOINT(idx,XYZPR) adds the 5-element task-space vector containing
%   the end-effector x,y,z position and end-effector pitch and roll 
%   orientation into the default "USNA" vector into the specified index.
%
%   SCORSETPOINT(name,idx,XYZPR) adds the 5-element task-space vector 
%   containing the end-effector x,y,z position and end-effector pitch and 
%   roll orientation into the specified vector "name" into the specified
%   index "idx".
%
%   SCORSETPOINT(...,'Mode',mode) specifies whether the point is designated
%   as an absolute or relative.
%       Mode: {['Absolute'] 'Relative'}
%
%   confirm = SCORSETPOINT(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorCreateVector ScorGotoPoint ScorSetXYZPR
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorAddToVec.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Redundand "ScorIsReady" added at the end of the function
%               for additional error checking
%   28Aug2015 - Updated error handling

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check inputs
narginchk(1,5);

pMode = 'Absolute'; 
nInputs = nargin;
if nInputs >= 3
    if strcmpi('mode',varargin{end-1})
        pMode = varargin{end};
        nInputs = nInputs - 2;
    end
end
if nInputs == 3
    vName = varargin{1};
    idx   = varargin{2};
    XYZPR = varargin{3};
end
if nInputs == 2
    vName = 'USNA';
    idx   = varargin{1};
    XYZPR = varargin{2};
end
if nInputs == 1
    vName = 'USNA';
    idx   = 1000;
    XYZPR = varargin{1};
end

% confirm valid vector name
if ~ischar(vName)
    error('The specified vector name must be a valid character string.');
end
if numel(vName) > 16
    error('The specified vector name must be 16 characters or less.');
end
% check index value against maximum bound
if idx < 0 || idx ~= round(idx)
    error('The specified vector index value must be a positive integer.');
end
if idx > 1e4
    error('The specified vector index value must be less than 10,000.');
end

%% Convert XYZPR to ScorBot units
x = round(XYZPR(1)*1e3); % x-position in micrometers
y = round(XYZPR(2)*1e3); % y-position in micrometers
z = round(XYZPR(3)*1e3); % z-position in micrometers
p = round(rad2deg(XYZPR(4))*1e3); % end-effector pitch in 1/1000's of a degree
r = round(rad2deg(XYZPR(5))*1e3); % end-effector pitch in 1/1000's of a degree

%% Set point
switch lower(pMode)
    case 'absolute'
        % 0 for absolute point
        isSet = calllib(libname,'RAddToVecXYZPR',vName,idx,0,x,y,z,p,r);
        if isSet
            confirm = true;
        else
            confirm = false;
%             if nargin == 0
%                 warning('Failed to add the specified %s point to index value %d of vector %s',pMode,idx,vName);
%             end
        end
    case 'relative'
        % 1 for relative point
        isSet = calllib(libname,'RAddToVecXYZPR',vName,idx,1,x,y,z,p,r);
        if isSet
            confirm = true;
        else
            confirm = false;
%             if nargin == 0
%                 warning('Failed to add the specified %s point to index value %d of vector %s',pMode,idx,vName);
%             end
        end
    otherwise
        error('The specified point must be designated as an "Absolute" or "Relative".');
end

%% Check for errors
ScorIsReady;
