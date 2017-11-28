%SCRIPT_ScorDance
% Execute a series of random joint configurations for the ScorBot.
%
%   M. Kutzer 13Aug2015, USNA

% Updates
%   28Nov2017 - Updated to override ScorHome prompt

tBSEPRData = [];
k = 1.0; % Allow movements up to a factor of k times the total distance between limits
ScorSetSpeed(70);
while true
    isReady = ScorIsReady;
    if ~isReady
        ScorHome(true);
    end
    
    BSEPR = ScorBSEPRRandom(k);
    % Check for possible table contact
    XYZPR = ScorBSEPR2XYZPR(BSEPR);
    if XYZPR(3) < 100
        fprintf('Possible table contact expected, skipping move.\n');
    else
        confirm = ScorSetBSEPR(BSEPR,'MoveType','LinearJoint');
        if confirm
            [~,~,cData] = ScorWaitForMove('CollectData','On');
            tBSEPRData = [tBSEPRData; cData.tBSEPR];
        end
    end
end