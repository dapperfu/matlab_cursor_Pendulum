function observation = observe(state, config)
%OBSERVE Fixed-length numeric observation. The witness is not included.
    if nargin < 2 || isempty(config)
        config = state.config;
    elseif ~isfield(config, 'maxTicks')
        config = pendulum.validateConfig(config);
    end
    modeName = string(config.observationMode);
    if modeName == "partial"
        observation = partialObservation(state, config);
    else
        observation = fullObservation(state, config);
    end
    observation = observation(:);
end

function values = fullObservation(state, config)
    player = playerBlock(state, config);
    goal = goalBlock(state, config);
    world = pendulum.updateHazards(state.level, max(state.tick, 0));
    [candidate, candidateValid] = candidateBlock(state, world, config);
    [anchors, anchorMask] = bodyBlock(state.player.position, world.anchorPos, 8, config, world, true);
    [hazards, hazardMask] = hazardBlock(state, world, 8, config);
    [platforms, platformMask] = platformBlock(state, world, 8, config);
    values = [player, goal, candidate, candidateValid, anchors, anchorMask, hazards, hazardMask, platforms, platformMask];
end

function values = partialObservation(state, config)
    scale = config.norm;
    position = state.player.position / scale.position;
    velocity = state.player.velocity / scale.velocity;
    mode = modeHot(state.mode);
    attached = double(state.mode == "ATTACHED");
    rope = [state.rope.length / scale.length, state.rope.theta / pi, state.rope.omega / scale.omega];
    remaining = 1 - state.tick / config.maxTicks;
    goal = goalBlock(state, config);
    world = pendulum.updateHazards(state.level, max(state.tick, 0));
    [anchors, anchorMask] = bodyBlock(state.player.position, world.anchorPos, 4, config, world, true);
    [hazards, hazardMask] = hazardBlock(state, world, 4, config);
    values = [position, velocity, mode, attached, rope, remaining, goal, anchors, anchorMask, hazards, hazardMask];
end

function values = playerBlock(state, config)
    scale = config.norm;
    values = [state.player.position / scale.position, state.player.velocity / scale.velocity, ...
        modeHot(state.mode), double(state.mode == "ATTACHED"), ...
        state.rope.length / scale.length, state.rope.theta / pi, state.rope.omega / scale.omega, ...
        double(state.input.previousHeld), state.tick / config.maxTicks];
end

function values = goalBlock(state, config)
    rect = state.level.goal.rect;
    center = [(rect(1) + rect(3)) * 0.5, (rect(2) + rect(4)) * 0.5];
    delta = (center - state.player.position) / config.norm.position;
    distance = hypot(delta(1), delta(2));
    values = [delta, distance];
end

function [values, valid] = candidateBlock(state, world, config)
    rects = rectMatrix(world.solids);
    [anchorId, ~] = pendulum.selectAnchor(state.player.position, state.player.velocity, ...
        world.anchorPos, world.anchorIds, rects, config);
    valid = double(anchorId ~= 0);
    values = [0 0];
    if anchorId ~= 0
        index = find(world.anchorIds == anchorId, 1, 'first');
        values = (world.anchorPos(index, :) - state.player.position) / config.norm.position;
    end
end

function [values, mask] = bodyBlock(origin, positions, slots, config, world, withEligible)
    values = zeros(1, slots * 3);
    mask = zeros(1, slots);
    count = min(slots, size(positions, 1));
    rects = rectMatrix(world.solids);
    for index = 1:count
        delta = (positions(index, :) - origin) / config.norm.position;
        distance = hypot(delta(1), delta(2));
        values((index - 1) * 3 + (1:3)) = [delta, distance];
        mask(index) = 1;
        if withEligible
            % Eligibility is carried by a finite distance inside acquisition range.
            reach = hypot(positions(index, 1) - origin(1), positions(index, 2) - origin(2));
            blocked = pendulum.segmentHitsSolid(origin, positions(index, :), rects);
            if reach < config.minRopeLength || reach > config.acquireRange || blocked
                values((index - 1) * 3 + 3) = -1;
            end
        end
    end
end

function [values, mask] = hazardBlock(state, world, slots, config)
    positions = zeros(numel(world.hazards), 2);
    for index = 1:numel(world.hazards)
        positions(index, :) = world.hazards(index).center;
    end
    [values, mask] = bodyBlock(state.player.position, positions, slots, config, world, false);
end

function [values, mask] = platformBlock(state, world, slots, config)
    positions = zeros(numel(world.solids), 2);
    for index = 1:numel(world.solids)
        rect = world.solids(index).rect;
        positions(index, :) = [(rect(1) + rect(3)) * 0.5, (rect(2) + rect(4)) * 0.5];
    end
    [values, mask] = bodyBlock(state.player.position, positions, slots, config, world, false);
end

function hot = modeHot(mode)
    names = ["READY", "GROUNDED", "FREE", "ATTACHED", "DEAD", "SUCCESS"];
    hot = double(names == string(mode));
end

function rects = rectMatrix(solids)
    rects = zeros(numel(solids), 4);
    for index = 1:numel(solids)
        rects(index, :) = solids(index).rect;
    end
end
