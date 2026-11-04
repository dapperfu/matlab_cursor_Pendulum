function [anchorId, bestScore] = selectAnchor(position, velocity, anchorPositions, anchorIds, solidRects, config)
%SELECTANCHOR Deterministic grapple target. Ties keep the lowest anchor id.
    anchorId = 0;
    bestScore = -inf;
    if isempty(anchorPositions)
        return
    end
    [~, order] = sort(anchorIds(:), 'ascend');
    for index = order(:).'
        anchor = anchorPositions(index, :);
        delta = anchor - position;
        distance = hypot(delta(1), delta(2));
        if distance < config.minRopeLength || distance > config.acquireRange
            continue
        end
        if pendulum.segmentHitsSolid(position, anchor, solidRects)
            continue
        end
        forward = delta(1) / config.acquireRange;
        distanceNorm = distance / config.acquireRange;
        speed = hypot(velocity(1), velocity(2));
        if speed < 1e-8 || distance < 1e-8
            alignment = 0;
        else
            alignment = (velocity(1) * delta(1) + velocity(2) * delta(2)) / (speed * distance);
        end
        score = 2 * forward - 0.8 * distanceNorm + 0.5 * alignment;
        if score > bestScore + 1e-12
            bestScore = score;
            anchorId = anchorIds(index);
        end
    end
end
