%SCRIPT_ScorSimDance
% Execute a series of random joint configurations for the ScorBot simulation.
%
%   M. Kutzer 18Feb2016, USNA

% Update(S)
%   23Jun2023 - Added OPTION to show embedded interpolation vs manual
%               interpolation options

%% Define option
OPTION = 1;

%% Initialize simulation
sim = ScorSimInit;
ScorSimPatch(sim);

%% Animate random movements

% Allow movements up to a factor of k times the total distance between limits
k = 1.0; 

% Define parameters for manual interpolation
s_vec = @(s) [s; 1];

while true
    q_init = transpose( ScorSimGetBSEPR(sim) );
    q_goal = transpose( ScorBSEPRRandom(k) );

    switch OPTION
        case 1
            % OPTION 1 - Use the embedded ScorSim* linear joint interpolation
            ScorSimSetBSEPR(sim,q_goal,'MoveType','LinearJoint');
            ScorSimWaitForMove(sim);
        case 2
            % OPTION 2 - Use the embedded ScorSim* linear task
            %            interpolation
            ScorSimSetBSEPR(sim,q_goal,'MoveType','LinearTask');
            ScorSimWaitForMove(sim);
        case 3
            % OPTION 3 - Manually interpolate in joint space and use 
            %            'Instant' 'MoveType'
            T = [q_init, q_goal];
            S = [s_vec(0), s_vec(1)];
            M = T*S^(-1);
            s = linspace(0,1,round( 30*norm(diff(T,1,2)) ));
            for s_i = s
                ScorSimSetBSEPR(sim, transpose( M*s_vec(s_i) ),'MoveType','Instant' );
            end
    end
end