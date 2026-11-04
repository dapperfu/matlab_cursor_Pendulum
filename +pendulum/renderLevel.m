function handles = renderLevel(ax, level, config)
%RENDERLEVEL Create cached graphics for one level. Later frames only set data.
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.validateConfig(config);
    cla(ax);
    colors = config.art;
    hold(ax, 'on');
    ax.Color = colors.abyss;
    ax.XColor = 'none';
    ax.YColor = 'none';
    ax.XTick = [];
    ax.YTick = [];
    ax.DataAspectRatio = [1 1 1];
    ax.Interactions = [];
    disableDefaultInteractivity(ax);
    handles = struct();
    handles.ax = ax;
    handles.level = level;
    handles.colors = colors;
    handles.config = config;
    decorationCount = numel(level.decorations);
    handles.decor = gobjects(max(decorationCount, 0), 1);
    for index = 1:decorationCount
        handles.decor(index) = patch(ax, nan, nan, colors.far, 'EdgeColor', 'none', 'FaceAlpha', 0.85);
    end
    handles.platforms = gobjects(numel(level.platforms), 1);
    handles.platformTops = gobjects(numel(level.platforms), 1);
    for index = 1:numel(level.platforms)
        handles.platforms(index) = patch(ax, nan, nan, colors.platform, 'EdgeColor', colors.outline, 'LineWidth', 1);
        handles.platformTops(index) = line(ax, nan, nan, 'Color', colors.platformTop, 'LineWidth', 2.5);
    end
    handles.hazards = gobjects(numel(level.hazards), 1);
    for index = 1:numel(level.hazards)
        handles.hazards(index) = line(ax, nan, nan, 'Color', colors.hazard, 'LineWidth', 1.4);
    end
    handles.collect = gobjects(numel(level.collectibles), 1);
    for index = 1:numel(level.collectibles)
        handles.collect(index) = patch(ax, nan, nan, colors.collectible, 'EdgeColor', colors.goalBrass, 'FaceAlpha', 0.9);
    end
    handles.anchors = gobjects(numel(level.anchors), 1);
    handles.anchorCores = gobjects(numel(level.anchors), 1);
    handles.selectRings = gobjects(numel(level.anchors), 1);
    for index = 1:numel(level.anchors)
        handles.anchors(index) = line(ax, nan, nan, 'Color', colors.anchor, 'LineWidth', 2);
        handles.anchorCores(index) = line(ax, nan, nan, 'Color', colors.anchorCore, 'LineWidth', 1.2);
        handles.selectRings(index) = line(ax, nan, nan, 'Color', colors.select, 'LineWidth', 1.1, 'LineStyle', '--');
    end
    handles.goal = line(ax, nan, nan, 'Color', colors.goal, 'LineWidth', 2);
    handles.goalInner = line(ax, nan, nan, 'Color', colors.goalBrass, 'LineWidth', 1);
    handles.ropeGlow = line(ax, nan, nan, 'Color', colors.ropeGlow, 'LineWidth', 3, 'Visible', 'off');
    handles.rope = line(ax, nan, nan, 'Color', colors.rope, 'LineWidth', 1.4, 'Visible', 'off');
    handles.chevrons = line(ax, nan, nan, 'Color', colors.rope, 'LineStyle', 'none', 'Marker', '>', 'Visible', 'off');
    handles.player = patch(ax, nan, nan, colors.explorer, 'EdgeColor', colors.outline, 'LineWidth', 1);
    handles.eye = line(ax, nan, nan, 'Color', colors.eye, 'Marker', 'o', 'MarkerFaceColor', colors.eye, 'LineStyle', 'none');
    handles.fail = line(ax, nan, nan, 'Color', colors.fail, 'Marker', 's', 'LineStyle', 'none', 'Visible', 'off');
    handles.acquire = line(ax, nan, nan, 'Color', colors.select, 'LineStyle', ':', 'Visible', 'off');
    handles.witness = line(ax, nan, nan, 'Color', [0.95 0.95 0.7], 'LineWidth', 1, 'Visible', 'off');
    handles.bounds = gobjects(numel(level.platforms) + numel(level.hazards), 1);
    for index = 1:numel(handles.bounds)
        handles.bounds(index) = line(ax, nan, nan, 'Color', [0.4 0.9 0.7], 'LineStyle', ':', 'Visible', 'off');
    end
    if config.showWitness && ~isempty(level.witness.actions)
        trace = pendulum.simulate(level, level.witness.actions, config);
        set(handles.witness, 'XData', trace.position(:, 1), 'YData', trace.position(:, 2), 'Visible', 'on');
    end
    handles.startMark = line(ax, level.start.position(1), level.start.position(2), ...
        'Color', colors.eye, 'Marker', 'o', 'MarkerSize', 8, 'LineStyle', 'none');
end
