function state = reset(level, config)
%RESET Start an episode in READY. The opening press is still required.
    if nargin < 2 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.bindConfig(level, config);
    state = struct();
    state.tick = 0;
    state.mode = "READY";
    state.player = struct( ...
        'position', reshape(double(level.start.position), 1, 2), ...
        'velocity', reshape(double(level.start.velocity), 1, 2), ...
        'radius', config.playerRadius);
    state.rope = struct('anchorId', 0, 'length', 0, 'theta', 0, 'omega', 0);
    state.input = struct('previousHeld', false, 'lastDownTick', 0, 'lastUpTick', 0, ...
        'currentHoldTicks', 0, 'currentReleaseTicks', 0);
    state.collectibles = false(numel(level.collectibles), 1);
    state.result = struct('outcome', "running", 'cause', "");
    state.level = level;
    state.config = config;
    state.finished = false;
    state.terminated = false;
    state.truncated = false;
    state.stats = struct('attachAttempts', 0, 'failedAttaches', 0, 'detachCount', 0);
    state.feedback = struct('failedTick', 0, 'attachTick', 0, 'detachTick', 0);
    state.candidateId = 0;
    state.candidateScore = -inf;
end
