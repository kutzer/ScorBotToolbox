function ScorSimGoHome(varargin)
% SCORSIMGOHOME moves the ScorBot visualization to the home position.
%   SCORSIMGOHOME(scorSim) moves the ScorBot visualization to the home 
%   position.
%       scorSim.Figure - figure handle of ScorBot visualization
%       scorSim.Axes   - axes handle of ScorBot visualization
%       scorSim.Joints - 1x5 array containing joint handles for ScorBot
%           visulization (hgtransform objects, use 
%           set(scorSim.Joints(i),'Matrix',Rz(angle)) to change a specific
%           joint angle)
%       scorSim.Frames - 1x5 array containing reference frame handles for
%           ScorBot (hgtransform objects with triad.m decendants)
%
%   See also ScorSimInit ScorSimSetBSEPR ScorSimGetBSEPR ScorSimSetXYZPR
%       ScorSimGetXYZPR etc
%
%   M. Kutzer, 14Aug2015, USNA

% Updates
%   01Oct2015 - Updated to include error checking
%   30Dec2015 - Updated error checking

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim);" to execute this function.'],mfilename)
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
            '\n\t-> and "%s(scorSim);" to execute this function.'],txt,mfilename);
    end
end
% Check for too many inputs
if nargin > 1
    warning('Too many inputs specified. Ignoring additional parameters.');
end

%% Go Home
BSEPRhome = [0.00000,2.09925,-1.65843,-1.54994,0.00000];
ScorSimSetBSEPR(scorSim,BSEPRhome);