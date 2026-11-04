function result = collisionSweep(p0, p1, velocity, query)
%COLLISIONSWEEP Swept circle. Lethal contact wins over solids, pickups, and the goal.
    config = query.config;
    radius = query.radius;
    result = blankResult(p1, velocity);
    result.collected = query.collected(:);
    solids = query.solids;
    if isfield(query, 'ignoreLanding') && query.ignoreLanding && ~isempty(solids)
        keep = arrayfun(@(solid) ~solid.canLand, solids);
        solids = solids(keep);
    end
    travel = hypot(p1(1) - p0(1), p1(2) - p0(2));
    steps = max(1, ceil(travel / config.sampleSpacing));
    for sample = 0:steps
        point = p0 + (sample / steps) * (p1 - p0);
        if point(2) < query.deathY
            result.position = point;
            result.velocity = velocity;
            result.died = true;
            result.cause = "death_plane";
            return
        end
        [lethal, cause] = lethalHit(point, radius, query.hazards, config.skin);
        if lethal
            result.position = point;
            result.velocity = velocity;
            result.died = true;
            result.cause = cause;
            return
        end
        result.collected = collectAt(point, radius, query.collectibles, result.collected);
        [hit, point, velocity, landed, supportTop] = resolveSolids(point, velocity, radius, solids, config);
        if hit
            result.position = point;
            result.velocity = velocity;
            result.hitSolid = true;
            result.landed = landed;
            result.supportTop = supportTop;
            return
        end
        if pendulum.checkGoal(point, radius, velocity, query.goalRect, query.goalDirection)
            result.position = point;
            result.velocity = velocity;
            result.reachedGoal = true;
            return
        end
        result.position = point;
        result.velocity = velocity;
    end
end

function result = blankResult(position, velocity)
    result = struct('position', position, 'velocity', velocity, 'died', false, ...
        'cause', "", 'landed', false, 'supportTop', nan, 'hitSolid', false, ...
        'reachedGoal', false, 'collected', false(0, 1));
end

function [hit, cause] = lethalHit(position, radius, hazards, skin)
    hit = false;
    cause = "";
    for index = 1:numel(hazards)
        hazard = hazards(index);
        if hazard.shape == "circle"
            reach = radius + hazard.radius - skin;
            delta = position - hazard.center;
            overlaps = reach > 0 && delta(1) ^ 2 + delta(2) ^ 2 < reach ^ 2;
        else
            overlaps = pendulum.circleOverlapsRect(position, radius, hazard.rect, skin);
        end
        if overlaps
            hit = true;
            cause = string(hazard.kind);
            return
        end
    end
end

function collected = collectAt(position, radius, collectibles, collected)
    for index = 1:numel(collectibles)
        if index <= numel(collected) && collected(index)
            continue
        end
        delta = position - collectibles(index).position;
        reach = radius + collectibles(index).radius;
        if delta(1) ^ 2 + delta(2) ^ 2 <= reach ^ 2
            collected(index) = true;
        end
    end
end

function [hit, position, velocity, landed, supportTop] = resolveSolids(position, velocity, radius, solids, config)
    hit = false;
    landed = false;
    supportTop = nan;
    if isempty(solids)
        return
    end
    [~, order] = sort([solids.id], 'ascend');
    solids = solids(order);
    for pass = 1:4
        moved = false;
        for index = 1:numel(solids)
            rect = solids(index).rect;
            if ~pendulum.circleOverlapsRect(position, radius, rect, config.skin)
                continue
            end
            incoming = velocity;
            [position, normal, topContact] = separateCircle(position, radius, rect);
            moved = true;
            hit = true;
            inward = incoming(1) * normal(1) + incoming(2) * normal(2);
            if inward < 0
                velocity = incoming - inward * normal;
            else
                velocity = incoming;
            end
            safeLanding = topContact && solids(index).canLand && incoming(2) < 0 && ...
                -incoming(2) <= config.landingSpeed && normal(2) > 0.9;
            if safeLanding
                landed = true;
                supportTop = rect(4);
                position(2) = supportTop + radius;
                velocity = [config.runSpeed, 0];
            elseif topContact && solids(index).canLand && incoming(2) < 0
                velocity(1) = velocity(1) * (1 - config.friction);
            end
        end
        if ~moved
            break
        end
    end
end

function [position, normal, topContact] = separateCircle(position, radius, rect)
    closestX = min(max(position(1), rect(1)), rect(3));
    closestY = min(max(position(2), rect(2)), rect(4));
    delta = position - [closestX, closestY];
    distance = hypot(delta(1), delta(2));
    topContact = false;
    if distance > 1e-8
        normal = delta / distance;
        position = [closestX, closestY] + normal * radius;
        topContact = abs(closestY - rect(4)) <= 1e-6 && normal(2) > 0.9;
        return
    end
    gaps = [position(1) - rect(1), rect(3) - position(1), position(2) - rect(2), rect(4) - position(2)];
    [~, which] = min(gaps);
    switch which
        case 1
            normal = [-1, 0];
            position(1) = rect(1) - radius;
        case 2
            normal = [1, 0];
            position(1) = rect(3) + radius;
        case 3
            normal = [0, -1];
            position(2) = rect(2) - radius;
        otherwise
            normal = [0, 1];
            position(2) = rect(4) + radius;
            topContact = true;
    end
end
