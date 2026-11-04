function state = tryAttach(state, world, config)
%TRYATTACH One acquisition attempt. Failure does not queue a later attach.
    solidRects = solidMatrix(world.solids);
    [anchorId, ~] = pendulum.selectAnchor(state.player.position, state.player.velocity, ...
        world.anchorPos, world.anchorIds, solidRects, config);
    state.stats.attachAttempts = state.stats.attachAttempts + 1;
    if anchorId == 0
        state.stats.failedAttaches = state.stats.failedAttaches + 1;
        state.feedback.failedTick = state.tick;
        return
    end
    index = find(world.anchorIds == anchorId, 1, 'first');
    anchor = world.anchorPos(index, :);
    delta = state.player.position - anchor;
    ropeLength = hypot(delta(1), delta(2));
    theta = atan2(delta(1), -delta(2));
    tangent = [cos(theta), sin(theta)];
    tangentialSpeed = state.player.velocity(1) * tangent(1) + state.player.velocity(2) * tangent(2);
    state.mode = "ATTACHED";
    state.rope.anchorId = anchorId;
    state.rope.length = ropeLength;
    state.rope.theta = theta;
    state.rope.omega = tangentialSpeed / ropeLength;
    state.player.velocity = tangentialSpeed * tangent;
    state.feedback.attachTick = state.tick;
    state.feedback.failedTick = 0;
end

function rects = solidMatrix(solids)
    rects = zeros(numel(solids), 4);
    for index = 1:numel(solids)
        rects(index, :) = solids(index).rect;
    end
end
