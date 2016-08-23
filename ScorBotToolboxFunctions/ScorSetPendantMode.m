function confirm = ScorSetPendantMode(pMode)
% SCORSETPENDANTMODE gets the current mode of the ScorBot teach pendant
%   SCORSETPENDANTMODE(pMode) checks the current mode of the ScorBot teach 
%   pendant (either "Teach" or "Auto") and prompts the user to switch modes
%   if necessary.
%
%   confirm = SCORSETPENDANTMODE(___) returns a 1 if mode is successfully
%   set and a 0 otherwise.
%
%   See also ScorGetPendantMode
%
%   References:
%       [1] C. Wick, J. Esposito, & K. Knowles, US Naval Academy, 2010
%           http://www.usna.edu/Users/weapsys/esposito-old/_files/scorbot.matlab/MTIS.zip
%           Original function name "ScorRequestPendantMode.m"
%       
%   C. Wick, J. Esposito, K. Knowles, & M. Kutzer, 10Aug2015, USNA

% Updates
%   25Aug2015 - Updated correct help documentation, "J. Esposito K. 
%               Knowles," to "J. Esposito, & K. Knowles,"
%               Erik Hoss
%   01Sep2015 - Added ScorIsReady to eliminate error(s) associated with
%               setting the teach pendant mode before ScorBot is homed.

%% Check inputs
switch lower(pMode)
    case 'auto'
        pMode = 'Auto';
    case 'teach'
        pMode = 'Teach';
    otherwise
        error('Unexpected value for ScorBot Teach Pendant mode.');
end

%% Check if ScorBot is ready
isReady = ScorIsReady;
if ~isReady
    confirm = false;
    return
end

%% Set teach pendant mode
nDots = 3;
if ~strcmp(pMode,ScorGetPendantMode)
    tic;
    fprintf('Please switch ScorBot Teach Pendant to "%s" mode',pMode);
    fprintf(repmat('.',1,nDots));
    iter = 0;
    while ~strcmp(pMode,ScorGetPendantMode)
        % Running dots
        if mod(iter,nDots+1) == 0
            fprintf( char(repmat(8,1,nDots)) );
        else
            fprintf('.');
        end
        iter = iter+1;
        % Make sound 
        if toc > 1
            ScorSound;
            tic;
        end
        pause(0.1);
        %TODO - add time-based stopping condition
    end
    if mod(iter,nDots+1) ~= 0
        fprintf( char(repmat(8,1,mod(iter,nDots+1))) );
    end
    fprintf(repmat('.',1,nDots));
    fprintf('SUCCESS\n');
    confirm = true;
else
    confirm = true;
end

