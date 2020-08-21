function q = interpSimMove(scorSim,q_o,q_f,coefs)
% INTERPBSEPR linearly interpolates between two 5-element arrays assuming
% the motion begins and ends at rest.
%   q = INTERPBSEPR(scorSim,q_f,coefs)
%
%   Inputs:
%       scorSim - structured array containing 
%           q_o - 5-element array containing joint or task positions
%           q_f - 5-element array containing joint or task positions
%         coefs - 5-element structured array containing ... SOMETHING
%           ~ for now, coefs = [t_o,t_f] (not a cell array...)
%
%   M. Kutzer, 21Aug2020, USNA

% TODO - add acceleration and deceleration using coefs

%% Define dt
dt = 0.02;

%% Check inputs
% Check for zero inputs
if nargin < 1
    error('ScorSim:NoSimObj',...
        ['A valid ScorSim object must be specified.',...
        '\n\t-> Use "scorSim = ScorSimInit;" to create a ScorSim object',...
        '\n\t-> and "%s(scorSim);" to execute this function.'],mfilename)
end
% Check for proper number of inputs
narginchk(4,4);
% Check scorSim
if nargin >= 1
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
if numel(q_f) ~= 5
    error('Goal pose must be a 5-element array.');
end
if numel(coefs) < 2
    error('Coefficients array must have at least two elements.');
end

%% Get current speed
spd = ScorSimGetSpeed(scorSim);

%{
%% Parse & update coefficients
if numel(coefs) == 5
    a = coefs(1);
    b = coefs(2);
end

dt_dwell_o = coefs(end-2);
dt_move    = coefs(end-1);
dt_dwell_i = coefs(end);

%}

%% Define dwell time and move time
dt_dwell_o = coefs(1);
dt_move    = diff(coefs(1:2));

%% Update move time based on speed
dt_move = dt_move * (100/spd);

%% Isolate points in time
t0 = 0;
t1 = dt_dwell_o;
t2 = t1 + dt_move;

%% Interpolate
t = 0:dt:(dt_dwell_o + dt_move);    % Total time vector 

bin_dwell = (t >= t0) & (t <= t1);
bin_move  = (t > t1)  & (t <= t2);

tt_dwell = t(bin_dwell);
tt_move  = t(bin_move );
for i = 1:numel(q_o)
    p = polyfit([t1,t2],[q_o(i),q_f(i)],1);
    
    q_dwell(i,:) = repmat(q_o(i),size(tt_dwell));
    q_move(i,:)  = polyval(p,tt_move);
    
    % TODO - add acceleration/deceleration
end

q = [q_dwell, q_move];