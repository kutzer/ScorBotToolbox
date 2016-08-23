function confirm = ScorCreateVector(vName,n)
% SCORCREATEVECTOR creates a "vector" on the ScorBot controller.
%   SCORCREATEVECTOR(name,length) creates a "vector" on the ScorBot 
%   controller with the specified name and length.
%       name - string containing up to 16 characters.
%       n - scalar defining the total number of points in the vector
%           up to 10,000.
%
%   NOTE: The ScorBot controller defines a "vector" as a list of XYZPR
%   "points" with a name and length assigned using "ScorCreateVector.m". 
%   Multiple (up to 10,000, but prescribed when the vector is created) 
%   points can be stored in a vector using "ScorSetPoint.m". The ScorBot
%   can be moved to points in a vector using "ScorGotoPoint.m"
%
%   confirm = SCORCREATEVECTOR(___) returns 1 if successful and 0 otherwise.
%
%   See also ScorSetPoint ScorGotoPoint
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorCreateVector.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Check inputs
narginchk(2,2);
if ~ischar(vName)
    error('The specified vector name must be a valid character string.');
end
if numel(vName) > 16
    error('The specified vector name must be 16 characters or less.');
end
if n > 1e4
    error('The specified vector length must be less than 10,000.');
end

%% Create vector
success = calllib(libname,'RDefineVector',vName,n);
if success
    confirm = true;
else
    confirm = false;
    if nargout == 0
        warning('Failed to create vector "%s".',vName);
    end
end

