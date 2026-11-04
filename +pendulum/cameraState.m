function camera = cameraState(state, config)
%CAMERASTATE Deterministic view. The explorer sits near 35 percent from the left.
    if nargin < 2 || isempty(config)
        config = state.config;
    end
    viewWidth = state.level.camera.viewWidth;
    if isempty(viewWidth)
        viewWidth = config.viewWidth;
    end
    fraction = state.level.camera.anchorFraction;
    viewHeight = viewWidth * 9 / 16;
    left = state.player.position(1) - fraction * viewWidth;
    bottom = state.player.position(2) - 0.42 * viewHeight;
    camera = struct('xlim', [left, left + viewWidth], 'ylim', [bottom, bottom + viewHeight], ...
        'viewWidth', viewWidth, 'viewHeight', viewHeight);
end
