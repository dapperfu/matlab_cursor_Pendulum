function renderFrame(handles, state, config)
%RENDERFRAME Update cached artists from the simulation state. No physics writes.
    if nargin < 3 || isempty(config)
        config = state.config;
    end
    colors = handles.colors;
    world = pendulum.updateHazards(state.level, max(state.tick, 1));
    camera = pendulum.cameraState(state, config);
    set(handles.ax, 'XLim', camera.xlim, 'YLim', camera.ylim);
    drawDecorations(handles, state.level, camera, colors);
    drawPlatforms(handles, world, colors);
    drawHazards(handles, world, state, colors, config);
    drawCollectibles(handles, state, world, colors);
    drawAnchors(handles, state, world, colors, config);
    drawGoal(handles, state, colors);
    drawRope(handles, state, world, colors, config);
    drawPlayer(handles, state, colors, config);
    drawDebug(handles, state, world, config);
    if isfield(handles, 'hudStage') && isvalid(handles.hudStage)
        handles.hudStage.Text = sprintf('%s  ·  %s', state.level.stageTitle, state.level.title);
        handles.hudTime.Text = sprintf('%.2f s', state.tick * config.dt);
        collected = sum(state.collectibles);
        handles.hudArtifacts.Text = sprintf('artifacts %d', collected);
        handles.hudHint.Text = hintFor(state);
    end
end

function drawDecorations(handles, level, camera, colors)
    center = mean(camera.xlim);
    for index = 1:numel(level.decorations)
        decor = level.decorations(index);
        factor = 0.22 + 0.18 * decor.depth;
        shownX = center + (decor.position(1) - center) * factor;
        shownY = decor.position(2);
        width = decor.size(1);
        height = decor.size(2);
        if decor.kind == "wheel" || decor.kind == "chain"
            [x, y] = circle(shownX, shownY, 0.5 * width, 18);
        else
            x = shownX + [-width, width, width, -width] / 2;
            y = shownY + [-height, -height, height, height] / 2;
        end
        shade = colors.far;
        if decor.depth > 0
            shade = colors.mid;
        end
        set(handles.decor(index), 'XData', x, 'YData', y, 'FaceColor', shade);
    end
end

function drawPlatforms(handles, world, colors)
    for index = 1:numel(world.solids)
        rect = world.solids(index).rect;
        set(handles.platforms(index), 'XData', [rect(1) rect(3) rect(3) rect(1)], ...
            'YData', [rect(2) rect(2) rect(4) rect(4)], 'FaceColor', colors.platform);
        set(handles.platformTops(index), 'XData', [rect(1) rect(3)], 'YData', [rect(4) rect(4)], ...
            'Color', colors.platformTop);
    end
end

function drawHazards(handles, world, state, colors, config)
    spin = 0;
    if ~config.reducedMotion
        spin = state.tick * 0.08;
    end
    for index = 1:numel(world.hazards)
        hazard = world.hazards(index);
        if hazard.shape == "circle"
            [x, y] = gear(hazard.center(1), hazard.center(2), max(hazard.radius, 0.2), spin);
            color = colors.spike;
            if hazard.kind == "saw"
                color = colors.saw;
            end
            set(handles.hazards(index), 'XData', x, 'YData', y, 'Color', color);
        else
            rect = hazard.rect;
            x = [rect(1), (rect(1) + rect(3)) / 2, rect(3), rect(1)];
            y = [rect(2), rect(4), rect(2), rect(2)];
            set(handles.hazards(index), 'XData', x, 'YData', y, 'Color', colors.spike);
        end
    end
end

function drawCollectibles(handles, state, world, colors)
    spin = state.tick * 0.05;
    for index = 1:numel(world.collectibles)
        item = world.collectibles(index);
        if index <= numel(state.collectibles) && state.collectibles(index)
            set(handles.collect(index), 'Visible', 'off');
            continue
        end
        [x, y] = hexagon(item.position(1), item.position(2), item.radius, spin);
        set(handles.collect(index), 'XData', x, 'YData', y, 'Visible', 'on', 'FaceColor', colors.collectible);
    end
end

function drawAnchors(handles, state, world, colors, config)
    pulse = 1;
    if ~config.reducedMotion
        pulse = 1 + 0.06 * sin(state.tick / 12);
    end
    for index = 1:size(world.anchorPos, 1)
        center = world.anchorPos(index, :);
        [x, y] = circle(center(1), center(2), 0.28, 20);
        set(handles.anchors(index), 'XData', x, 'YData', y, 'Color', colors.anchor);
        [cx, cy] = circle(center(1), center(2), 0.07, 8);
        set(handles.anchorCores(index), 'XData', cx, 'YData', cy, 'Color', colors.anchorCore);
        selected = state.candidateId == world.anchorIds(index) && state.mode ~= "ATTACHED";
        if selected
            [sx, sy] = circle(center(1), center(2), 0.48 * pulse, 24);
            set(handles.selectRings(index), 'XData', sx, 'YData', sy, 'Visible', 'on', 'Color', colors.select);
        else
            set(handles.selectRings(index), 'Visible', 'off');
        end
    end
end

function drawGoal(handles, state, colors)
    rect = state.level.goal.rect;
    cx = (rect(1) + rect(3)) / 2;
    cy = (rect(2) + rect(4)) / 2;
    scale = 1;
    if state.mode == "SUCCESS"
        scale = 1.15;
    end
    corners = [rect(1) rect(2); rect(3) rect(2); rect(3) rect(4); rect(1) rect(4); rect(1) rect(2)];
    corners(:, 1) = cx + scale * (corners(:, 1) - cx);
    corners(:, 2) = cy + scale * (corners(:, 2) - cy);
    set(handles.goal, 'XData', corners(:, 1), 'YData', corners(:, 2), 'Color', colors.goal);
    halfWidth = scale * (rect(3) - rect(1)) / 2;
    span = linspace(pi, 0, 24);
    archY = corners(3, 2) + halfWidth * 0.45 * sin(span);
    set(handles.goalInner, 'XData', cx + halfWidth * cos(span), 'YData', archY, 'Color', colors.goalBrass);
end

function drawRope(handles, state, world, colors, config)
    if state.mode ~= "ATTACHED" || state.rope.anchorId == 0
        set(handles.rope, 'Visible', 'off');
        set(handles.ropeGlow, 'Visible', 'off');
        set(handles.chevrons, 'Visible', 'off');
        return
    end
    index = find(world.anchorIds == state.rope.anchorId, 1, 'first');
    if isempty(index)
        return
    end
    anchor = world.anchorPos(index, :);
    player = state.player.position;
    set(handles.ropeGlow, 'XData', [anchor(1) player(1)], 'YData', [anchor(2) player(2)], ...
        'Visible', 'on', 'Color', colors.ropeGlow);
    set(handles.rope, 'XData', [anchor(1) player(1)], 'YData', [anchor(2) player(2)], ...
        'Visible', 'on', 'Color', colors.rope);
    if config.reducedMotion || state.input.previousHeld == false
        set(handles.chevrons, 'Visible', 'off');
        return
    end
    samples = linspace(0.2, 0.8, 3) + 0.05 * sin(state.tick / 4);
    samples = min(0.9, max(0.1, samples));
    xs = anchor(1) + samples * (player(1) - anchor(1));
    ys = anchor(2) + samples * (player(2) - anchor(2));
    set(handles.chevrons, 'XData', xs, 'YData', ys, 'Visible', 'on', 'Color', colors.rope);
end

function drawPlayer(handles, state, colors, config)
    local = [0 0.24; 0.09 0.14; 0.12 0.02; 0.07 -0.06; 0.14 -0.18; 0.03 -0.16; ...
        0 -0.22; -0.08 -0.16; -0.15 -0.06; -0.11 0.05; -0.07 0.16; 0 0.24];
    angle = 0;
    if ~config.reducedMotion
        if state.mode == "ATTACHED"
            angle = state.rope.theta * 0.35;
        elseif state.mode == "GROUNDED"
            angle = 0.12 * sin(state.tick / 3);
        elseif hypot(state.player.velocity(1), state.player.velocity(2)) > 0.4
            angle = 0.2 * atan2(state.player.velocity(2), state.player.velocity(1));
        end
    end
    rotation = [cos(angle), -sin(angle); sin(angle), cos(angle)];
    world = (rotation * local.').' + state.player.position;
    face = colors.explorer;
    if state.mode == "DEAD"
        face = colors.fail;
    end
    set(handles.player, 'XData', world(:, 1), 'YData', world(:, 2), 'FaceColor', face);
    eye = state.player.position + (rotation * [0.04; 0.12]).';
    set(handles.eye, 'XData', eye(1), 'YData', eye(2), 'Color', colors.eye, 'MarkerFaceColor', colors.eye);
    if state.feedback.failedTick > 0 && state.tick - state.feedback.failedTick < 18 && state.mode ~= "ATTACHED"
        set(handles.fail, 'XData', state.player.position(1) + 0.18, 'YData', state.player.position(2) + 0.05, 'Visible', 'on');
    else
        set(handles.fail, 'Visible', 'off');
    end
end

function drawDebug(handles, state, world, config)
    visible = 'off';
    if config.showDebugOverlay
        visible = 'on';
    end
    [x, y] = circle(state.player.position(1), state.player.position(2), config.acquireRange, 48);
    set(handles.acquire, 'XData', x, 'YData', y, 'Visible', visible);
    cursor = 1;
    for index = 1:numel(world.solids)
        rect = world.solids(index).rect;
        set(handles.bounds(cursor), 'XData', [rect(1) rect(3) rect(3) rect(1) rect(1)], ...
            'YData', [rect(2) rect(2) rect(4) rect(4) rect(2)], 'Visible', visible);
        cursor = cursor + 1;
    end
    for index = 1:numel(world.hazards)
        hazard = world.hazards(index);
        if hazard.shape == "circle"
            [hx, hy] = circle(hazard.center(1), hazard.center(2), hazard.radius, 20);
        else
            rect = hazard.rect;
            hx = [rect(1) rect(3) rect(3) rect(1) rect(1)];
            hy = [rect(2) rect(2) rect(4) rect(4) rect(2)];
        end
        set(handles.bounds(cursor), 'XData', hx, 'YData', hy, 'Visible', visible);
        cursor = cursor + 1;
    end
end

function text = hintFor(state)
    if state.mode == "READY"
        text = 'PRESS: BEGIN';
    elseif state.mode == "DEAD"
        text = 'PRESS: RETRY';
    elseif state.mode == "SUCCESS"
        text = 'PRESS: NEXT';
    elseif state.level.meta.levelIndex <= 5
        text = 'PRESS: GRAPPLE    HOLD: REEL    RELEASE: FLY    WAIT: COAST';
    else
        text = '';
    end
end

function [x, y] = circle(cx, cy, radius, count)
    theta = linspace(0, 2 * pi, count + 1);
    x = cx + radius * cos(theta);
    y = cy + radius * sin(theta);
end

function [x, y] = gear(cx, cy, radius, spin)
    count = 12;
    theta = linspace(0, 2 * pi, count * 2 + 1) + spin;
    radii = radius * ones(size(theta));
    radii(1:2:end) = radius * 1.18;
    x = cx + radii .* cos(theta);
    y = cy + radii .* sin(theta);
end

function [x, y] = hexagon(cx, cy, radius, spin)
    theta = linspace(0, 2 * pi, 7) + spin;
    x = cx + radius * cos(theta);
    y = cy + radius * sin(theta);
end
