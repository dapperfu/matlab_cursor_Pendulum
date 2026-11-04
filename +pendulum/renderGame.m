function handles = renderGame(level, config)
%RENDERGAME Open the widescreen figure and the cached level artists.
    if nargin < 2 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.validateConfig(config);
    colors = config.art;
    fig = uifigure('Name', 'Pendulum: The Clockwork Ruins', 'Color', colors.panel, ...
        'Position', [40 40 1280 720]);
    ax = uiaxes(fig, 'Position', [0 28 1280 692]);
    handles = pendulum.renderLevel(ax, level, config);
    handles.figure = fig;
    handles.hudStage = uilabel(fig, 'Position', [16 688 640 24], 'FontColor', colors.hud, ...
        'BackgroundColor', colors.panel, 'Text', '');
    handles.hudTime = uilabel(fig, 'Position', [980 688 140 24], 'FontColor', colors.hud, ...
        'BackgroundColor', colors.panel, 'HorizontalAlignment', 'right', 'Text', '');
    handles.hudArtifacts = uilabel(fig, 'Position', [1120 688 140 24], 'FontColor', colors.hud, ...
        'BackgroundColor', colors.panel, 'HorizontalAlignment', 'right', 'Text', '');
    handles.hudHint = uilabel(fig, 'Position', [16 2 900 24], 'FontColor', colors.hud, ...
        'BackgroundColor', colors.panel, 'Text', '');
    handles.hudSeed = uilabel(fig, 'Position', [920 2 340 24], 'FontColor', colors.hud, ...
        'BackgroundColor', colors.panel, 'HorizontalAlignment', 'right', ...
        'Text', sprintf('seed %u   level %d', level.meta.seed, level.meta.levelIndex));
end
