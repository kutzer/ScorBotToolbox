function logBase = ScorErrorLogBase
% SCORERRORLOGBASE retuns the base name used for all ScorBot error logs.
%   logBase = SCORERRORLOGBASE returns the base name used for all ScorBot
%   error logs. Note that this includes both the computer and username. 
%
%   M. Kutzer, 11Sep2018, USNA

%% Setup base of error log file
u_name = getenv('username');
c_name = getenv('computername');
logBase = sprintf('ScorErrorLog_%s_%s_',c_name,u_name);