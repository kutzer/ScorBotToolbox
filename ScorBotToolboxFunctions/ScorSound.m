function ScorSound()
% SCORSOUND produces a unique tone (different from the system tone) for 
% ScorBot-related user interaction.
%
%   Example:
%       for i = 1:10
%           ScorSound;
%           pause(0.1);
%       end
%
%   See also beep
%
%   References:
%       [1] M. Gagnon, "Robot Blip 2", Attribution 3.0 license, 01/05/2011.
%
%   M. Kutzer, 10Aug2015, USNA

%% Define sound as a persistent to avoid loading multiple times
persistent ScorBotWav

%% Load sound on first function call
if isempty(ScorBotWav)
    [y, Fs] = audioread('RobotBlip2.wav',[4000,20900]);
    ScorBotWav.y = y;
    ScorBotWav.Fs = Fs;
end

%% Play sound
sound(ScorBotWav.y,ScorBotWav.Fs);
