function grip = ScorGetGripper()
% SCORGETGRIPPER gets the gripper state as measured in millimeters above
% fully closed.
%   grip = SCORGETGRIPPER gets the gripper state in millimeters. State is
%   measured as the distance between the gripper fingers. A fully closed 
%   gripper has a "grip" of 0 mm. A fully open gripper has a "grip" of 
%   approximately 70 mm.
%
%   See also ScorSetGripper
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorGetGripper.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 12Aug2015, USNA
%
%   J. Donnal, 28Jun2017, USNA (64-bit Support)

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   28Aug2015 - Updated error handling
%   25Sep2015 - Ignore isReady flag
%   17Jul2019 - Updated to replace instances of "calllib.m" with
%               "ScorCallLib.m" to include J. Donnal 64-bit solution 

%% Check ScorBot and define library alias
[isReady,libname] = ScorIsReady;
% if ~isReady
%     grip = [];
%     return
% end

%% Get gripper state
grip = ScorCallLib(libname,'RGetJaw');
