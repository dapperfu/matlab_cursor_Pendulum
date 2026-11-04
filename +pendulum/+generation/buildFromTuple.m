function [level, ok] = buildFromTuple(seed, levelIndex, profile, tuple, preview, streams, config)
%BUILDFROMTUPLE Place the gate on a simulated swing, then reject the tuple if replay fails.
    ok = false;
    level = pendulum.blankLevel();
    level.meta.seed = uint32(seed);
    level.meta.levelIndex = double(levelIndex);
    level.meta.generatorVersion = config.generatorVersion;
    level.meta.physicsVersion = config.physicsVersion;
    level.meta.difficultyVersion = config.difficultyVersion;
    level.title = profile.title;
    level.stageTitle = profile.stageTitle;
    level.bounds = [-8 70 profile.deathY 24];
    level.physics = pendulum.physicsBlock(config);
    level.camera.viewWidth = config.viewWidth;
    level.camera.anchorFraction = config.anchorFraction;
    level.platforms = pendulum.makePlatform(1, [0, -1, profile.platformWidth, 0], true);
    level.start.position = [1, config.playerRadius];
    level.start.velocity = [config.runSpeed, 0];
    level.start.mode = "GROUNDED";
    level.goal.rect = [1e5, 0, 1e5 + 1, 1];
    level.goal.direction = "any";

    delay = tuple(1);
    hold = tuple(2);
    dx = tuple(3);
    dy = tuple(4);
    press = preview.leaveTick + delay;
    if press < 3 || press - 1 > size(preview.trace.position, 1)
        return
    end
    origin = preview.trace.position(press - 1, :);
    velocity = preview.trace.velocity(press - 1, :);
    distance = hypot(dx, dy);
    if distance < config.minRopeLength + 0.3 || distance > config.acquireRange - 0.5
        return
    end
    motion = pendulum.staticMotion();
    if profile.moving && profile.anchorAmplitude > 0
        motion.type = "horizontal";
        motion.amplitude = profile.anchorAmplitude;
        motion.period = 220;
        motion.phase = 0;
        motion.axis = "x";
    end
    pose = origin + [dx, dy];
    delta = pendulum.motionDelta(motion, press);
    % motionDelta uses the motion struct. Anchor base is chosen so the pose at the press tick is `pose`.
    anchor = pendulum.makeAnchor(1, pose - delta, motion);
    if norm(pendulum.anchorPose(anchor, press) - pose) > 1e-9
        return
    end
    level.anchors = anchor;
    world = pendulum.updateHazards(level, press);
    [chosen, ~] = pendulum.selectAnchor(origin, velocity, world.anchorPos, world.anchorIds, ...
        rectMatrix(world.solids), config);
    if chosen ~= 1
        return
    end

    releaseTick = press + hold;
    horizon = releaseTick + 160;
    actions = zeros(horizon, 1, 'uint8');
    actions(1) = 1;
    actions(press:releaseTick - 1) = 1;
    level.witness.actions = actions;
    [trace, ~] = pendulum.simulate(level, actions, config);
    if ~any(trace.mode == "ATTACHED") || releaseTick + 12 > size(trace.position, 1)
        return
    end
    held = press:min(numel(trace.ropeLength), releaseTick - 1);
    if distance - min(trace.ropeLength(held)) < 0.12
        return
    end
    goalTick = 0;
    center = [0 0];
    half = 0.45;
    separation = half + config.playerRadius + 0.3;
    for candidate = (releaseTick + 12):size(trace.position, 1)
        point = trace.position(candidate, :);
        if point(1) < level.start.position(1) + profile.minProgress || point(2) < profile.deathY + 4
            continue
        end
        earlier = trace.position(1:releaseTick, :);
        gap = hypot(earlier(:, 1) - point(1), earlier(:, 2) - point(2));
        if all(gap > separation)
            goalTick = candidate;
            center = point;
            break
        end
    end
    if goalTick == 0
        return
    end
    level.goal.rect = [center(1) - half, center(2) - half, center(1) + half, center(2) + half];
    actions = actions(1:goalTick);
    level.witness.actions = actions;
    level = pendulum.generation.placeHazards(level, trace.position(1:goalTick, :), profile, streams.hazards, config);
    level = pendulum.generation.placeDecoration(level, streams.decoration, profile);
    level = placeCollectible(level, pose, streams.collectibles);
    [~, summary] = pendulum.simulate(level, actions, config);
    if ~(summary.success && summary.finalTick > releaseTick)
        level.hazards = repmat(pendulum.makeHazard(0, "gear", "circle", [0 0], 0, [0 0 0 0]), 0, 1);
        extra = level.platforms(1);
        level.platforms = extra;
        [~, summary] = pendulum.simulate(level, actions, config);
    end
    if ~(summary.success && summary.finalTick > releaseTick)
        return
    end
    level.witness.actions = actions(1:summary.finalTick);
    level.witness.finalTick = summary.finalTick;
    level.witness.clearance = summary.clearance;
    level.witness.events = summary.events;
    level.witness.integratorId = config.integratorId;
    level.meta.verified = false;
    ok = true;
end

function rects = rectMatrix(solids)
    rects = zeros(numel(solids), 4);
    for index = 1:numel(solids)
        rects(index, :) = solids(index).rect;
    end
end

function level = placeCollectible(level, anchorPose, stream)
    spot = anchorPose + [0.4, 1.3] + (rand(stream, 1, 2) - 0.5) * 0.2;
    level.collectibles = pendulum.makeCollectible(1, spot);
end
