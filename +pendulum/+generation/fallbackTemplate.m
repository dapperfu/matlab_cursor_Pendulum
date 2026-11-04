function [level, ok] = fallbackTemplate(seed, levelIndex, profile, streams, config)
%FALLBACKTEMPLATE Known-conservative swing. Still rejected unless step() wins.
    profile.platformWidth = 3.6;
    profile.anchorAmplitude = min(profile.anchorAmplitude, 0.35);
    preview = struct();
    level = pendulum.blankLevel();
    level.bounds = [-8 70 profile.deathY 24];
    level.physics = pendulum.physicsBlock(config);
    level.platforms = pendulum.makePlatform(1, [0, -1, profile.platformWidth, 0], true);
    level.start.position = [1, config.playerRadius];
    level.start.velocity = [config.runSpeed, 0];
    level.start.mode = "GROUNDED";
    level.goal.rect = [1e5, 0, 1e5 + 1, 1];
    actions = zeros(profile.horizon, 1, 'uint8');
    actions(1) = 1;
    trace = pendulum.simulate(level, actions, config);
    preview.trace = trace;
    preview.leaveTick = find(trace.mode == "FREE", 1, 'first');
    tuple = [30, 45, 1.0, 4.8];
    if isempty(preview.leaveTick)
        ok = false;
        return
    end
    [level, ok] = pendulum.generation.buildFromTuple(seed, levelIndex, profile, tuple, preview, streams, config);
end
