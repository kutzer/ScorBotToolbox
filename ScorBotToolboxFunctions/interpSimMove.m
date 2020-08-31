function [q,t] = interpSimMove(scorSim,q_o,q_f,coefs,mType)
% INTERPBSEPR linearly interpolates between two 5-element arrays assuming
% the motion begins and ends at rest.
%   q = INTERPBSEPR(scorSim,q_f,coefs,mType)
%
%   [q,t] = INTERPBSEPR(___)
%
%   Inputs:
%       scorSim - structured array containing 
%           q_o - 5-element array containing joint or task positions
%           q_f - 5-element array containing joint or task positions
%         coefs - 3-element structured array containing acceleration radius
%                 movement start time, and movement finish time.
%
%                   coefs = [t_o,t_i,t_f]
%                       t_o - ramp start time (assuming 180 degree move)
%                       t_i - move start time (assuming 180 degree move)
%                       t_f - move end time   (assuming 180 degree move)
%
%         mType - Move type {['LinearJoint'],'LinearTask'} 
%
%   Outputs:
%       q - 5 x N element array containing joint or task positions
%           depending on mType context 
%       t - 1 x N element array containing time stamps
%
%   M. Kutzer, 21Aug2020, USNA

% Updates:
%   26Aug2020 - Added correlation between move length and move duration
%   26Aug2020 - Added ramp radius and time
%   25Aug2020 - Updated to include a 3-parameter time coefficient
%   26Aug2020 - Updated to interpolate based on move type
%   27Aug2020 - Updated to include acceleration/deceleration

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
narginchk(4,5);
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

if nargin < 5
    mType = 'LinearJoint';
end

%% Get current speed
spd = ScorSimGetSpeed(scorSim);

%% Define dwell time and move time
dt_dwell_o = coefs(1);
dt_ramp    = diff(coefs(1:2));
dt_move    = diff(coefs(2:3));

%% Update move time based on speed
% Determine longest possible move time 
dt_move = dt_move * (100/spd);

% Find the variable that moves the most
switch lower(mType)
    case 'linearjoint'
        dq_move = max( abs(q_f - q_o) );
    case 'lineartask'
        dq_move = max( abs(ScorXYZPR2BSEPR(q_f) - ScorXYZPR2BSEPR(q_o)) );
    case 'instant'
        warning('This function is not intended for instant moves.');
        q = q_f;
        return
    otherwise
        mName = mfilename;
        error('ScorSimSet:BadPropDes',...
            ['Unexpected property: "%s"',...
            '\n\t-> Use "%s(___,''LinearJoint'')"',...
            '\n\t-> Use "%s(___,''LinearTask'')", or',....
            '\n\t-> Use "%s(___,''Instant'')".'],...
            pType,mName,mName,mName);
end

dq_max = pi; % Assume move time is based on a 180 degree movement
dt_move = dt_move * (dq_move/dq_max);

%% Adjust dt_ramp
dt_ramp = dt_ramp * (spd/100) * (dq_move/dq_max);

%% Isolate points in time
% TODO - make dwell times based in something
t0 = 0;                     % Time to start dwell
t1 = t0 + (2/3)*dt_dwell_o; % Time to start ramp up 
t2 = t1 + dt_ramp;          % Time to start constant move
t3 = t2 + dt_move;          % Time to start ramp down
t4 = t3 + dt_ramp;          % Time to start dwell
t5 = t4 + (1/3)*dt_dwell_o; % Time to end move

%% Interpolate
t = t0:dt:t5;    % Total time vector 

bin_dwell_1 = (t >= t0) & (t <= t1);
bin_ramp_1  = (t >  t1) & (t <= t2);
bin_move    = (t >  t2) & (t <= t3);
bin_ramp_2  = (t >  t3) & (t <= t4);
bin_dwell_2 = (t >  t4) & (t <= t5);

tt_dwell_1 = t(bin_dwell_1);
tt_ramp_1  = t(bin_ramp_1);
tt_move    = t(bin_move);
tt_ramp_2  = t(bin_ramp_2);
tt_dwell_2 = t(bin_dwell_2);

vt3  = @(t)([1*t^3; 1*t^2; 1*t^1; t^0]);
dvt3 = @(t)([3*t^2; 2*t^1; 1*t^0; 0]);
for i = 1:numel(q_o)
    
    % First dwell
    q_dwell_1(i,:) = repmat(q_o(i),size(tt_dwell_1));
    
    % Define change in joint angle
    dq = q_f(i) - q_o(i);
    
    % Define dq for ramp up and ramp down
    %   TODO - Make this tunable or actually based in something
    dq_ramp = (1/2)*(dt_ramp/dt_move)*dq; % Ramping represents 20% of total move
    
    % Define dq for fixed velocity move
    dq_move = dq - 2*dq_ramp; 
    
    % Define q values to pair with time
    q0 = q_o(i);
    q1 = q0 + 0;
    q2 = q1 + dq_ramp;
    q3 = q2 + dq_move;
    q4 = q3 + dq_ramp;
    q5 = q4 + 0;
    
    % Fit dwells and fixed velocity move
    p_dwell_1 = polyfit([t0,t1],[q0,q1],1);
    p_move    = polyfit([t2,t3],[q2,q3],1);
    p_dwell_2 = polyfit([t4,t5],[q4,q5],1);
    
    % Fit ramps
    dq1dt1 = 0;
    dq2dt2 = p_move(1); % Derivative at t2
    dq3dt3 = p_move(1); % Derivative at t3
    dq4dt4 = 0;
    % Ramp up
    T = [vt3(t1),dvt3(t1),vt3(t2),dvt3(t2)];
    Q = [q1, dq1dt1, q2, dq2dt2];
    p_ramp_1 = Q*(T^-1);
    % Ramp down
    T = [vt3(t3),dvt3(t3),vt3(t4),dvt3(t4)];
    Q = [q3, dq3dt3, q4, dq4dt4];
    p_ramp_2 = Q*(T^-1);
    
    % Evaluate polynomials
    q_dwell_1(i,:) = polyval(p_dwell_1, tt_dwell_1);
    q_ramp_1(i,:)  = polyval(p_ramp_1 , tt_ramp_1 );
    q_move(i,:)    = polyval(p_move   , tt_move   );
    q_ramp_2(i,:)  = polyval(p_ramp_2 , tt_ramp_2 );
    q_dwell_2(i,:) = polyval(p_dwell_2, tt_dwell_2);
end

q = [q_dwell_1, q_ramp_1, q_move, q_ramp_2, q_dwell_2];

%{
figure;
axes;
hold on
size(t)
size(q)
for i = 1:size(q,1)
    plot(t,q(i,:),'LineWidth',1.5);
end
%}