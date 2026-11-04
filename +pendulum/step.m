function [state, observation, reward, terminated, truncated, info] = step(state, action, config)
%STEP One 120 Hz tick. Order is fixed: edge, grapple, motion, contacts, reward.
    if nargin < 3 || isempty(config)
        config = state.config;
    elseif ~isfield(config, 'maxTicks')
        config = pendulum.validateConfig(config);
    end
    if state.finished
        error('pendulum:TerminalState', 'Reset before stepping a finished episode.');
    end
    action = uint8(action);
    if ~isscalar(action) || (action ~= 0 && action ~= 1)
        error('pendulum:InvalidAction', 'Action must be scalar 0 or 1.');
    end

    previous = state;
    state.tick = state.tick + 1;
    pressedEdge = action == 1 && ~state.input.previousHeld;
    releasedEdge = action == 0 && state.input.previousHeld;
    state = noteEdges(state, action, pressedEdge, releasedEdge);

    startedThisTick = false;
    if state.mode == "READY" && pressedEdge
        state.mode = playMode(state.level.start.mode);
        startedThisTick = true;
        pressedEdge = false;
    end

    if ~startedThisTick
        world = pendulum.updateHazards(state.level, state.tick);
        before = state.player.position;
        if pressedEdge && (state.mode == "FREE" || state.mode == "GROUNDED")
            state = pendulum.tryAttach(state, world, config);
        end
        if releasedEdge && state.mode == "ATTACHED"
            state = pendulum.detach(state);
        end
        switch state.mode
            case "ATTACHED"
                anchor = anchorById(world, state.rope.anchorId);
                state = pendulum.updateAttached(state, anchor, action, config);
            case "GROUNDED"
                state = stepGrounded(state, world, config);
            case "FREE"
                [state.player.position, state.player.velocity] = pendulum.updateFreeFlight( ...
                    state.player.position, state.player.velocity, config.dt, config.gravity);
            otherwise
        end
        if state.mode ~= "READY"
            state = applyContacts(state, before, world, config);
        end
        state = rememberCandidate(state, world, config);
    end

    if ~state.finished && state.tick >= config.maxTicks
        state.truncated = true;
        state.finished = true;
        state.result.outcome = "timeout";
        state.result.cause = "timeout";
    end
    state.input.previousHeld = action == 1;
    [reward, components] = pendulum.computeReward(previous, state, config);
    observation = pendulum.observe(state, config);
    terminated = state.terminated;
    truncated = state.truncated;
    info = struct('tick', state.tick, 'cause', state.result.cause, ...
        'rewardComponents', components, 'mode', state.mode, ...
        'attachAttempts', state.stats.attachAttempts, ...
        'failedAttaches', state.stats.failedAttaches, ...
        'candidateId', state.candidateId);
end

function state = noteEdges(state, action, pressedEdge, releasedEdge)
    if action == 1
        if pressedEdge
            state.input.currentHoldTicks = 1;
            state.input.currentReleaseTicks = 0;
            state.input.lastDownTick = state.tick;
        else
            state.input.currentHoldTicks = state.input.currentHoldTicks + 1;
        end
    elseif releasedEdge
        state.input.currentReleaseTicks = 1;
        state.input.lastUpTick = state.tick;
    else
        state.input.currentReleaseTicks = state.input.currentReleaseTicks + 1;
    end
end

function mode = playMode(startMode)
    mode = upper(string(startMode));
    if mode == "DETACHED"
        mode = "FREE";
    end
    if mode ~= "GROUNDED" && mode ~= "FREE"
        error('pendulum:InvalidLevel', 'Start mode must be GROUNDED or FREE.');
    end
end

function state = stepGrounded(state, world, config)
    top = supportHeight(state.player.position, state.player.radius, world.solids, config);
    if isnan(top)
        state.mode = "FREE";
        [state.player.position, state.player.velocity] = pendulum.updateFreeFlight( ...
            state.player.position, state.player.velocity, config.dt, config.gravity);
        return
    end
    next = state.player.position;
    next(1) = next(1) + config.runSpeed * config.dt;
    next(2) = top + state.player.radius;
    state.player.velocity = [config.runSpeed, 0];
    state.player.position = next;
    if isnan(supportHeight(next, state.player.radius, world.solids, config))
        state.mode = "FREE";
    end
end

function top = supportHeight(position, radius, solids, config)
    top = nan;
    foot = position(2) - radius;
    for index = 1:numel(solids)
        if ~solids(index).canLand
            continue
        end
        rect = solids(index).rect;
        if position(1) < rect(1) || position(1) > rect(3)
            continue
        end
        if foot >= rect(4) - config.supportEpsilon && foot <= rect(4) + config.supportEpsilon
            if isnan(top) || rect(4) > top
                top = rect(4);
            end
        end
    end
end

function state = applyContacts(state, before, world, config)
    query = struct();
    query.config = config;
    query.radius = state.player.radius;
    query.solids = world.solids;
    query.hazards = world.hazards;
    query.collectibles = world.collectibles;
    query.collected = state.collectibles;
    query.goalRect = world.goalRect;
    query.goalDirection = world.goalDirection;
    query.deathY = world.deathY;
    query.ignoreLanding = state.mode == "GROUNDED";
    result = pendulum.collisionSweep(before, state.player.position, state.player.velocity, query);
    state.player.position = result.position;
    state.player.velocity = result.velocity;
    state.collectibles = result.collected;
    if result.died
        state.mode = "DEAD";
        state.terminated = true;
        state.finished = true;
        state.result.outcome = "death";
        state.result.cause = string(result.cause);
        state.rope.anchorId = 0;
        return
    end
    if result.reachedGoal
        state.mode = "SUCCESS";
        state.terminated = true;
        state.finished = true;
        state.result.outcome = "success";
        state.result.cause = "goal";
        return
    end
    if result.landed
        if state.mode == "ATTACHED"
            state = pendulum.detach(state);
        end
        state.mode = "GROUNDED";
        state.player.position(2) = result.supportTop + state.player.radius;
        state.player.velocity = [config.runSpeed, 0];
        return
    end
    if state.mode == "ATTACHED" && result.hitSolid
        anchor = anchorById(world, state.rope.anchorId);
        state = rebuildRope(state, anchor, config);
    elseif state.mode == "GROUNDED"
        if isnan(supportHeight(state.player.position, state.player.radius, world.solids, config))
            state.mode = "FREE";
        end
    end
end

function state = rebuildRope(state, anchor, config)
    delta = state.player.position - anchor;
    ropeLength = hypot(delta(1), delta(2));
    if ~isfinite(ropeLength) || ropeLength < config.minRopeLength || ropeLength > config.acquireRange
        state = pendulum.detach(state);
        return
    end
    theta = atan2(delta(1), -delta(2));
    tangent = [cos(theta), sin(theta)];
    tangential = state.player.velocity(1) * tangent(1) + state.player.velocity(2) * tangent(2);
    state.rope.length = ropeLength;
    state.rope.theta = theta;
    state.rope.omega = tangential / ropeLength;
    state.player.velocity = tangential * tangent;
    state.player.position = anchor + ropeLength * [sin(theta), -cos(theta)];
end

function state = rememberCandidate(state, world, config)
    if state.finished || isempty(world.anchorPos)
        state.candidateId = 0;
        state.candidateScore = -inf;
        return
    end
    rects = zeros(numel(world.solids), 4);
    for index = 1:numel(world.solids)
        rects(index, :) = world.solids(index).rect;
    end
    [state.candidateId, state.candidateScore] = pendulum.selectAnchor( ...
        state.player.position, state.player.velocity, world.anchorPos, world.anchorIds, rects, config);
end

function position = anchorById(world, anchorId)
    index = find(world.anchorIds == anchorId, 1, 'first');
    if isempty(index)
        position = [nan nan];
        return
    end
    position = world.anchorPos(index, :);
end
