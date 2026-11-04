function [level, ok] = growWitnessRoute(seed, levelIndex, profile, streams, config)
%GROWWITNESSROUTE Try the ordered tuples until one replay reaches the gate.
    ok = false;
    level = pendulum.blankLevel();
    preview = previewRun(profile, config);
    if isempty(preview.leaveTick)
        return
    end
    [tuples, order] = pendulum.generation.searchCandidateActions(streams.solver, true);
    limit = min(64, numel(order));
    for index = 1:limit
        tuple = tuples(order(index), :);
        [candidate, built] = pendulum.generation.buildFromTuple( ...
            seed, levelIndex, profile, tuple, preview, streams, config);
        if built
            level = candidate;
            ok = true;
            return
        end
    end
end

function preview = previewRun(profile, config)
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
    freeTicks = find(trace.mode == "FREE", 1, 'first');
    if isempty(freeTicks)
        preview.leaveTick = [];
    else
        preview.leaveTick = freeTicks;
    end
end
