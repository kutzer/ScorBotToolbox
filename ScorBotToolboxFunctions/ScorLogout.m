function ScorLogout
% SCORLOGOUT executes the ScorSafeShutdown function then logs out of the
% user account.
%
%   M. Kutzer, USNA, 02Oct2018

%% Shutdown the robot
ScorSafeShutdown;

%% Log out of the user account
system('shutdown -L');