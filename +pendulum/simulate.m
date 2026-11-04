function [trace, summary] = simulate(level, actions, config)
%SIMULATE Replay a uint8 action vector through pendulum.step.
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.bindConfig(level, config);
    actions = uint8(actions(:));
    state = pendulum.reset(level, config);
    count = numel(actions);
    trace = blankTrace(count);
    totalReward = 0;
    components = struct('goal', 0, 'death', 0, 'timeout', 0, 'step', 0, 'shaping', 0);
    last = 0;
    for index = 1:count
        [state, ~, reward, terminated, truncated, info] = pendulum.step(state, actions(index), config);
        last = index;
        trace.position(index, :) = state.player.position;
        trace.velocity(index, :) = state.player.velocity;
        trace.mode(index) = state.mode;
        trace.ropeLength(index) = state.rope.length;
        trace.theta(index) = state.rope.theta;
        trace.omega(index) = state.rope.omega;
        trace.anchorId(index) = state.rope.anchorId;
        trace.reward(index) = reward;
        totalReward = totalReward + reward;
        components = addComponents(components, info.rewardComponents);
        if terminated || truncated
            break
        end
    end
    if last == 0
        last = 0;
    end
    trace = trimTrace(trace, last);
    summary = struct();
    summary.success = state.mode == "SUCCESS";
    summary.finalTick = state.tick;
    summary.outcome = state.result.outcome;
    summary.cause = state.result.cause;
    summary.reward = totalReward;
    summary.components = components;
    summary.attachAttempts = state.stats.attachAttempts;
    summary.failedAttaches = state.stats.failedAttaches;
    summary.terminated = state.terminated;
    summary.truncated = state.truncated;
    summary.clearance = clearanceOf(level, trace, config);
    summary.events = eventsFromTrace(trace);
    summary.position = state.player.position;
end

function trace = blankTrace(count)
    trace = struct();
    trace.position = zeros(count, 2);
    trace.velocity = zeros(count, 2);
    trace.mode = strings(count, 1);
    trace.ropeLength = zeros(count, 1);
    trace.theta = zeros(count, 1);
    trace.omega = zeros(count, 1);
    trace.anchorId = zeros(count, 1);
    trace.reward = zeros(count, 1);
end

function trace = trimTrace(trace, last)
    if last <= 0
        trace = blankTrace(0);
        return
    end
    trace.position = trace.position(1:last, :);
    trace.velocity = trace.velocity(1:last, :);
    trace.mode = trace.mode(1:last);
    trace.ropeLength = trace.ropeLength(1:last);
    trace.theta = trace.theta(1:last);
    trace.omega = trace.omega(1:last);
    trace.anchorId = trace.anchorId(1:last);
    trace.reward = trace.reward(1:last);
end

function total = addComponents(total, extra)
    total.goal = total.goal + extra.goal;
    total.death = total.death + extra.death;
    total.timeout = total.timeout + extra.timeout;
    total.step = total.step + extra.step;
    total.shaping = total.shaping + extra.shaping;
end

function gap = clearanceOf(level, trace, config)
    gap = 1e6;
    if isempty(level.hazards) || isempty(trace.position)
        return
    end
    for index = 1:size(trace.position, 1)
        world = pendulum.updateHazards(level, index);
        point = trace.position(index, :);
        for hazardIndex = 1:numel(world.hazards)
            hazard = world.hazards(hazardIndex);
            if hazard.shape == "circle"
                distance = hypot(point(1) - hazard.center(1), point(2) - hazard.center(2)) ...
                    - hazard.radius - config.playerRadius;
            else
                distance = outsideRect(point, hazard.rect) - config.playerRadius;
            end
            gap = min(gap, distance);
        end
    end
end

function distance = outsideRect(point, rect)
    closestX = min(max(point(1), rect(1)), rect(3));
    closestY = min(max(point(2), rect(2)), rect(4));
    distance = hypot(point(1) - closestX, point(2) - closestY);
end

function events = eventsFromTrace(trace)
    events = repmat(struct('tick', 0, 'type', ""), 0, 1);
    if isempty(trace.mode)
        return
    end
    previous = "";
    for index = 1:numel(trace.mode)
        mode = trace.mode(index);
        if mode == "ATTACHED" && previous ~= "ATTACHED"
            events(end + 1, 1) = struct('tick', index, 'type', "attach"); %#ok<AGROW>
        elseif previous == "ATTACHED" && mode ~= "ATTACHED" && mode ~= "DEAD" && mode ~= "SUCCESS"
            events(end + 1, 1) = struct('tick', index, 'type', "detach"); %#ok<AGROW>
        end
        if mode == "GROUNDED" && (previous == "FREE" || previous == "ATTACHED")
            events(end + 1, 1) = struct('tick', index, 'type', "land"); %#ok<AGROW>
        end
        if mode == "SUCCESS"
            events(end + 1, 1) = struct('tick', index, 'type', "success"); %#ok<AGROW>
        elseif mode == "DEAD"
            events(end + 1, 1) = struct('tick', index, 'type', "death"); %#ok<AGROW>
        end
        previous = mode;
    end
end
