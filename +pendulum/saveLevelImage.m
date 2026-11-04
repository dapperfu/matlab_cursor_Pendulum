function saveLevelImage(level, imagePath, config)
%SAVELEVELIMAGE Render one witnessed frame without entering the play loop.
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.validateConfig(config);
    config.enableAudio = false;
    config.showWitness = true;
    figureHandle = uifigure('Visible', 'off', 'Position', [0 0 1280 720]);
    cleanup = onCleanup(@() closeFigure(figureHandle));
    axesHandle = uiaxes(figureHandle, 'Position', [0 0 1280 720]);
    state = pendulum.reset(level, config);
    actions = uint8(level.witness.actions(:));
    frameTick = max(1, round(numel(actions) * 0.55));
    for index = 1:min(frameTick, numel(actions))
        [state, ~, ~, ~, ~, ~] = pendulum.step(state, actions(index), config);
        if state.finished
            break
        end
    end
    handles = pendulum.renderLevel(axesHandle, level, config);
    pendulum.renderFrame(handles, state, config);
    exportgraphics(axesHandle, imagePath, 'Resolution', 100);
end

function closeFigure(figureHandle)
    if isvalid(figureHandle)
        close(figureHandle);
    end
end
