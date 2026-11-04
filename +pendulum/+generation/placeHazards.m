function level = placeHazards(level, path, profile, stream, config)
%PLACEHAZARDS Add lethal bodies whose swept volume misses the witness path.
    if profile.hazardCount <= 0 || isempty(path)
        return
    end
    pockets = [-5, -4; 10, 10; 16, -5; -6, 11; 22, 7; 26, -4; 18, 12; -4, 8];
    placed = level.hazards;
    if isempty(placed)
        placed = repmat(pendulum.makeHazard(0, "gear", "circle", [0 0], 0, [0 0 0 0]), 0, 1);
    end
    for index = 1:size(pockets, 1)
        if numel(placed) >= profile.hazardCount
            break
        end
        jitter = (rand(stream, 1, 2) - 0.5) * 0.8;
        center = pockets(index, :) + jitter;
        kindRoll = randi(stream, 3);
        motion = pendulum.staticMotion();
        amplitude = 0;
        if profile.moving
            motion.type = "horizontal";
            motion.amplitude = 0.55;
            motion.period = 180 + randi(stream, 40);
            motion.axis = "x";
            amplitude = motion.amplitude;
        end
        if kindRoll == 1
            radius = 0.55;
            hazard = pendulum.makeHazard(numel(placed) + 1, "gear", "circle", center, radius, [0 0 0 0], motion);
        elseif kindRoll == 2
            radius = 0.32;
            hazard = pendulum.makeHazard(numel(placed) + 1, "saw", "circle", center, radius, [0 0 0 0], motion);
        else
            radius = 0.7;
            rect = [center(1) - 0.35, center(2) - 0.15, center(1) + 0.35, center(2) + 0.55];
            hazard = pendulum.makeHazard(numel(placed) + 1, "spike", "aabb", center, 0, rect, motion);
        end
        if clearsPath(center, radius, amplitude, path, config)
            placed(end + 1, 1) = hazard; %#ok<AGROW>
        end
    end
    if profile.moving
        carriage = pendulum.staticMotion();
        carriage.type = "vertical";
        carriage.amplitude = 0.4;
        carriage.period = 200;
        carriage.axis = "y";
        padCenter = [-6, profile.deathY + 3];
        if clearsPath(padCenter, 1.2, carriage.amplitude, path, config)
            rect = [padCenter(1) - 1.5, padCenter(2) - 0.3, padCenter(1) + 1.5, padCenter(2) + 0.3];
            level.platforms(end + 1, 1) = pendulum.makePlatform(numel(level.platforms) + 1, rect, true, carriage);
        end
        far = pendulum.staticMotion();
        far.type = "horizontal";
        far.amplitude = 0.8;
        far.period = 260;
        far.axis = "x";
        farAnchor = pendulum.makeAnchor(numel(level.anchors) + 1, [-14, 16], far);
        if min(hypot(path(:, 1) + 14, path(:, 2) - 16)) > config.acquireRange + 1
            level.anchors(end + 1, 1) = farAnchor;
        end
    end
    level.hazards = placed;
end

function ok = clearsPath(center, radius, amplitude, path, config)
    distance = hypot(path(:, 1) - center(1), path(:, 2) - center(2));
    ok = all(distance > config.playerRadius + radius + config.safetyMargin + amplitude + 0.35);
end
