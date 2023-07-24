%% -- Main code for LunarLander -- %%

%% Initialize code
clc
close all
clear all

% Fix seed for reproducibility
rng(42)

% Load configurations file
config;

%% Prepare computing setup
nCores = feature('numcores');
p = gcp('nocreate');
if isempty(p) && settings.runParallel == true
    % There is no parallel pool
    pool = parpool(nCores);
    disp(['Parallel pool running with cores: ', num2str(nCores)])
else
    if settings.runParallel ==  true
        % There is a parallel pool of <p.NumWorkers> workers
        disp(['Parallel started with cores: ', num2str(nCores)])
    else
        disp('Running single core')
    end
end

%% Create Observation and Action spaces

ObservationInfo = rlNumericSpec([5 1]); % Tells MATLAB my state is of 5 elements: Y = [x; y; vx; vy; c] 
ObservationInfo.Name = 'LunarLander state vector';
ObservationInfo.Description = 'x, y, vx, vy, c';

ActionInfo = rlFiniteSetSpec(settings.ActionSpace); % Tells MATLAB which actions my vehicle can take at every step
ActionInfo.Name = 'LunarLander guidance';
ObservationInfo.Description = 'Possible actions at each timestep';

%% Create environment using observation and action functions

% Create handles for reset and step functions
ResetHandle = @() funcReset(settings); 
StepHandle = @(Action,LoggedSignals) funcStep(Action,LoggedSignals,settings); 
env = rlFunctionEnv(ObservationInfo,ActionInfo,StepHandle,ResetHandle); % Creates environment using the functions filenames

%% Create DQN agent neural network

% Create an array containing the network structure
net = [
    featureInputLayer(ObservationInfo.Dimension(1)) % Input layer has size of state vector (i.e. 5)
    fullyConnectedLayer(256, ...
                        WeightsInitializer = 'glorot', ...
                        BiasInitializer = 'zeros') % First hidden layer
    leakyReluLayer % First hidden layer activation function
    fullyConnectedLayer(256, ...
                        WeightsInitializer = 'glorot', ...
                        BiasInitializer = 'zeros') % Second hidden layer
    reluLayer % Second hidden layer activation function
    fullyConnectedLayer(length(ActionInfo.Elements)) % Output layer: has size of the number of discrete actions (i.e. 4)
    ];

% Actually initialize the network
net = dlnetwork(net);

% Display and plot network structure
% summary(net);

% figure()
% plot(net);

%% Create the agent based on the DQN neural network

% Create the critic approximator with environment, available actions and NN
critic = rlVectorQValueFunction(net,ObservationInfo,ActionInfo, UseDevice = settings.mainDevice);

% Create and tune the agent based on the critic above
agent = rlDQNAgent(critic);
agent.AgentOptions.UseDoubleDQN = true;
agent.AgentOptions.TargetSmoothFactor = 1;
agent.AgentOptions.TargetUpdateFrequency = 5;
agent.AgentOptions.MiniBatchSize = 128;
agent.AgentOptions.ExperienceBufferLength = 200000;
agent.AgentOptions.EpsilonGreedyExploration.Epsilon = 1;
agent.AgentOptions.EpsilonGreedyExploration.EpsilonDecay = 0.05;
agent.AgentOptions.EpsilonGreedyExploration.EpsilonMin = 0.001;
agent.AgentOptions.DiscountFactor = 0.99;
%agent.AgentOptions.CriticOptimizerOptions.Algorithm = "sgdam";
%agent.AgentOptions.CriticOptimizerOptions.OptimizerParameters.Momentum = 0.9; 
agent.AgentOptions.CriticOptimizerOptions.LearnRate = 1e-3; % Reduce this if I make the network bigger
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 1;

%% Train the agent

settings.resultType = "training";
if settings.trainAgent == true
    if settings.plotBadTrajectory == true
        % Define training settings for the agent
        trainOpts = rlTrainingOptions(...
            MaxEpisodes=settings.episodes_before_plot, ...
            MaxStepsPerEpisode=500, ...
            Verbose=false, ...
            Plots="none",... 
            StopTrainingCriteria="EpisodeCount", ...
            StopTrainingValue=settings.episodes_before_plot, ...
            UseParallel=false);
         % Train the agent
         trainingStats = train(agent,env,trainOpts);
    else 
        % Define training settings for the agent
        trainOpts = rlTrainingOptions(...
            MaxEpisodes=settings.total_max_episodes, ...
            MaxStepsPerEpisode=500, ...
            Verbose=false, ...
            Plots="training-progress",...  
            StopTrainingCriteria="AverageReward", ...
            ScoreAveragingWindowLength = 50, ...
            StopTrainingValue = 70, ...
            UseParallel=settings.runParallel);
        % Train the agent
        trainingStats = train(agent,env,trainOpts);
        save(pwd + "/SimOut_Data/trainingStats.mat", 'trainingStats');
        save(pwd + "/SimOut_Agents/agentRef.mat", 'agent');
    end
    if settings.runParallel == false
        Y_tot = env.LoggedSignals.cumulativeState;
        T_tot = env.LoggedSignals.cumulativeThrust;
        % Plot trajectory
        f_trajectory_plot(Y_tot, T_tot, settings)
        % Generate animation
        % disp("Saving trajectory animation ... ")
        % f_trajectory_animation (Y_tot, T_tot, settings);
        % disp("... done")
        % Print relevant data on screen
        disp("Cumulative reward: " + num2str(sum(sum(env.LoggedSignals.cumulativeReward))))
        disp("Penalty proportional distance: " + num2str(sum(env.LoggedSignals.cumulativeReward(1, :))))
        disp("Penalty proportional speed: " + num2str(sum(env.LoggedSignals.cumulativeReward(2, :))))
        disp("Penalty side engines: " + num2str(sum(env.LoggedSignals.cumulativeReward(3, :))))
        disp("Penalty main engine: " + num2str(sum(env.LoggedSignals.cumulativeReward(4, :))))
        disp("Penalty exit boundaries: " + num2str(sum(env.LoggedSignals.cumulativeReward(5, :))))
        disp("Penalty crash outside: " + num2str(sum(env.LoggedSignals.cumulativeReward(6, :))))
        disp("Penalty crash inside landing pad: " + num2str(sum(env.LoggedSignals.cumulativeReward(7, :))))
        disp("Reward successful landing " + num2str(sum(env.LoggedSignals.cumulativeReward(8, :))))
        disp("Touchdown vx " + num2str(env.LoggedSignals.velocityTouchdown(1)))
        disp("Touchdown vy " + num2str(env.LoggedSignals.velocityTouchdown(2)))
        disp("Total number of steps: " + num2str(size(Y_tot, 2)))
        disp("Total landing duration in simulation time [s]: " + num2str(size(Y_tot, 2)*settings.dt))
    end
    disp("Training terminated")
    disp("-----------------")
else
    load(pwd + "/SimOut_Agents/agentRef", 'agent');
    load(pwd + "/SimOut_Data/trainingStats.mat", 'trainingStats');
end

%% Extract and plot rewards timesries after training
if settings.plotBadTrajectory == false
    f_rewards_plot(trainingStats, settings)
end

%% Simulate the agent once training is over

% Change random seed
rng(0)

% Define simulation options for the trained agent
simOpts = rlSimulationOptions(MaxSteps = 500, ...
                              NumSimulations= 1);

% Simulate the trained agent
experience = sim(env,agent,simOpts);

% Extract results from experience object
settings.resultType = "simulation";
for i = 1:size(experience, 1)
    % Extract timeseries vector
    t_sim = zeros(1, size(experience(i).Observation.LunarLanderStateVector.Time, 1));
    t_sim(:) = experience(i).Observation.LunarLanderStateVector.Time(:, 1);

    % Extract states
    Y_sim = zeros(5, size(experience(i).Observation.LunarLanderStateVector.Data, 3));
    Y_sim(:, :) = experience(i).Observation.LunarLanderStateVector.Data(:, 1, :);

    % Extract actions and separate them in Tx and Ty
    combinedActions = experience(i).Action.LunarLanderGuidance.Data(1, 1, :);

    T_x = zeros(1, size(experience(i).Action.LunarLanderGuidance.Data, 3));
    T_y = zeros(1, size(experience(i).Action.LunarLanderGuidance.Data, 3));

    T_x_positive_idx = find(combinedActions == settings.ActionSpace(4));
    T_x_negative_idx = find(combinedActions == settings.ActionSpace(5));
    T_y_low_idx = find(combinedActions == settings.ActionSpace(2));
    T_y_high_idx = find(combinedActions == settings.ActionSpace(3));

    T_x(T_x_positive_idx) = settings.ActionSpace(4);
    T_x(T_x_negative_idx) = settings.ActionSpace(5);
    T_y(T_y_low_idx) = settings.ActionSpace(2);
    T_y(T_y_high_idx) = settings.ActionSpace(3);

    T_sim = [0, T_x; 
             0, T_y];

    % Plot trajectory
    f_trajectory_plot(Y_sim, T_sim, settings)

    % Generate animation
    % disp("Saving trajectory animation ... ")
    % f_trajectory_animation (Y_sim, T_sim, settings);
    % disp("... done")

    % Generate 3D plot for cover page
    % -- ! missing code ! -- %
end


