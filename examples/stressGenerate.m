function stressGenerate()
%STRESSGENERATE Time the large seed matrix and one render loop. Writes measured numbers only.
    addpath(fileparts(fileparts(mfilename('fullpath'))));
    config = pendulum.defaultConfig();
    config.enableAudio = false;
    config.showWitness = false;
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    earlySeconds = zeros(100, 5);
    earlyOk = false(100, 5);
    started = tic;
    for seed = 1:100
        for index = 1:5
            sample = tic;
            level = pendulum.generateLevel(uint32(seed), index, config);
            [won, ~] = pendulum.verifyWitness(level, config);
            earlySeconds(seed, index) = toc(sample);
            earlyOk(seed, index) = won;
        end
        fprintf('early seed %d\n', seed);
    end
    lateSeconds = zeros(30, 1);
    lateOk = false(30, 1);
    for seed = 1:30
        sample = tic;
        level = pendulum.generateLevel(uint32(seed), 16, config);
        [won, ~] = pendulum.verifyWitness(level, config);
        lateSeconds(seed) = toc(sample);
        lateOk(seed) = won;
    end
    level = pendulum.generateLevel(uint32(1), 1, config);
    actions = level.witness.actions;
    rollout = tic;
    pendulum.simulate(level, actions, config);
    rolloutSeconds = toc(rollout);
    stepsPerSecond = numel(actions) / rolloutSeconds;
    figureHandle = uifigure('Visible', 'off', 'Position', [0 0 960 540]);
    cleanup = onCleanup(@() closeFigure(figureHandle));
    axesHandle = uiaxes(figureHandle, 'Position', [0 0 960 540]);
    state = pendulum.reset(level, config);
    handles = pendulum.renderLevel(axesHandle, level, config);
    frames = 60;
    renderSample = tic;
    for frame = 1:frames
        if ~state.finished
            action = uint8(0);
            if frame < numel(actions)
                action = actions(frame);
            end
            [state, ~, ~, ~, ~, ~] = pendulum.step(state, action, config);
        end
        pendulum.renderFrame(handles, state, config);
        drawnow limitrate nocallbacks
    end
    renderSeconds = toc(renderSample);
    report = sprintf([ ...
        '# Measured performance\n\n' ...
        'Machine: MATLAB %s on %s.\n\n' ...
        '- Early gate: %d / %d seed-level pairs verified (seeds 1:100, levels 1:5).\n' ...
        '- Early mean generate+verify: %.3f s. Total early wall time is included in the script timer below.\n' ...
        '- Late gate: %d / %d level-16 worlds verified (seeds 1:30).\n' ...
        '- Late mean generate+verify: %.3f s.\n' ...
        '- Headless witness rollout: %.0f steps/s (%.3f s for %d ticks).\n' ...
        '- Offscreen renderFrame: %.2f ms/frame over %d frames (%.1f FPS if the machine keeps that pace).\n' ...
        '- Script timer: %.1f s.\n'], ...
        version, computer, sum(earlyOk, 'all'), numel(earlyOk), mean(earlySeconds, 'all'), ...
        sum(lateOk), numel(lateOk), mean(lateSeconds), stepsPerSecond, rolloutSeconds, numel(actions), ...
        1000 * renderSeconds / frames, frames, frames / renderSeconds, toc(started));
    docPath = fullfile(rootDir, 'docs', 'performance.md');
    fid = fopen(docPath, 'w');
    cleaner = onCleanup(@() fclose(fid));
    fwrite(fid, report);
    fprintf('%s\n', report);
    assert(all(earlyOk, 'all'));
    assert(all(lateOk));
end

function closeFigure(figureHandle)
    if isvalid(figureHandle)
        close(figureHandle);
    end
end
