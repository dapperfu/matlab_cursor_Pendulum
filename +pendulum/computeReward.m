function [reward, components] = computeReward(previous, state, config)
%COMPUTEREWARD Sparse terminal rewards plus a small step cost and clipped shaping.
    components = struct('goal', 0, 'death', 0, 'timeout', 0, 'step', -config.stepCost, 'shaping', 0);
    if state.mode == "SUCCESS"
        components.goal = config.rewardGoal;
    elseif state.mode == "DEAD"
        components.death = config.rewardDeath;
    elseif state.truncated
        components.timeout = config.rewardTimeout;
    end
    delta = pendulum.goalPotential(state, config) - pendulum.goalPotential(previous, config);
    components.shaping = max(-config.shapingLimit, min(config.shapingLimit, delta));
    reward = components.goal + components.death + components.timeout + components.step + components.shaping;
end
