function trainingStats = demoAgentTraining()
%DEMOAGENTTRAINING Short DQN run on the same step function. The witness remains the baseline.
    addpath(fileparts(fileparts(mfilename('fullpath'))));
    config = pendulum.validateConfig(pendulum.defaultConfig());
    config.enableAudio = false;
    level = pendulum.generateLevel(uint32(7), 1, config);
    [~, witness] = pendulum.simulate(level, level.witness.actions, config);
    fprintf('witness success=%d tick=%d\n', witness.success, witness.finalTick);
    probe = pendulum.observe(pendulum.reset(level, config), config);
    observationInfo = rlNumericSpec([numel(probe) 1]);
    observationInfo.Name = 'pendulum';
    actionInfo = rlFiniteSetSpec([0 1]);
    actionInfo.Name = 'space';
    env = rlFunctionEnv(observationInfo, actionInfo, ...
        @(action, logged) localStep(action, logged, config), ...
        @() localReset(level, config));
    agent = rlDQNAgent(observationInfo, actionInfo);
    options = rlTrainingOptions( ...
        'MaxEpisodes', 3, ...
        'MaxStepsPerEpisode', 80, ...
        'StopTrainingCriteria', 'EpisodeCount', ...
        'StopTrainingValue', 3, ...
        'Verbose', true, ...
        'Plots', 'none');
    trainingStats = train(agent, env, options);
    assert(witness.success);
end

function [observation, logged] = localReset(level, config)
    logged.state = pendulum.reset(level, config);
    observation = pendulum.observe(logged.state, config);
end

function [observation, reward, isDone, logged] = localStep(action, logged, config)
    value = uint8(action(1));
    [logged.state, observation, reward, terminated, truncated] = pendulum.step(logged.state, value, config);
    isDone = terminated || truncated;
end
