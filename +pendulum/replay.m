function [trace, summary] = replay(level, replayData, config)
%REPLAY Reject a mismatched world, then step the stored actions.
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    end
    if string(replayData.format) ~= "pendulum-replay-1"
        error('pendulum:ReplayMismatch', 'Unsupported replay format.');
    end
    if string(replayData.hash) ~= string(level.meta.hash)
        error('pendulum:ReplayMismatch', 'Replay hash does not match the level.');
    end
    if string(replayData.physicsVersion) ~= string(level.meta.physicsVersion) || ...
            string(replayData.generatorVersion) ~= string(level.meta.generatorVersion)
        error('pendulum:ReplayMismatch', 'Replay version does not match the level.');
    end
    if abs(double(replayData.dt) - level.physics.dt) > 1e-12
        error('pendulum:ReplayMismatch', 'Replay time step does not match the level.');
    end
    [trace, summary] = pendulum.simulate(level, replayData.actions, config);
end
