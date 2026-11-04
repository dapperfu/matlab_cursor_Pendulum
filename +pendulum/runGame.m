function runGame(options)
%RUNGAME Space is the only gameplay key: begin, grapple, retry, and advance.
    arguments
        options.Seed = []
        options.Level = 1
        options.Config = []
        options.MaxFrames = inf
    end
    config = options.Config;
    if isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.validateConfig(config);
    config.enableAudio = true;
    if isempty(options.Seed)
        run = pendulum.newRun('Config', config);
    else
        run = pendulum.newRun('Seed', options.Seed, 'Config', config);
    end
    session = newSession(run.seed, options.Level, config);
    level = pendulum.generateLevel(session.seed, session.levelIndex, config);
    state = pendulum.reset(level, config);
    handles = pendulum.renderGame(level, config);
    fig = handles.figure;
    fig.WindowKeyPressFcn = @(~, event) keyDown(event);
    fig.WindowKeyReleaseFcn = @(~, event) keyUp(event);
    % uifigure has no WindowFocusLostFcn. FigureDeactivated is its focus-loss event.
    addlistener(fig, 'FigureDeactivated', @(~, ~) focusLost());
    fig.CloseRequestFcn = @(src, ~) closeFigure(src);
    fig.UserData = struct('stop', false);
    ticksPerFrame = max(1, round((1 / 60) / config.dt * config.presentationSpeed));
    frames = 0;
    while isvalid(fig) && ~fig.UserData.stop && frames < options.MaxFrames
        frames = frames + 1;
        for sample = 1:ticksPerFrame
            if ~isvalid(fig) || session.paused
                break
            end
            [state, session, handles] = pump(state, session, handles);
        end
        if ~isvalid(fig)
            break
        end
        pendulum.renderFrame(handles, state, config);
        drawnow limitrate
    end

    function keyDown(event)
        session.keys = pendulum.onKeyDown(session.keys, event.Key);
    end

    function keyUp(event)
        session.keys = pendulum.onKeyUp(session.keys, event.Key);
    end

    function focusLost()
        if frames < 1 || ~isvalid(fig)
            return
        end
        session.keys.spaceHeld = false;
        session.paused = true;
        session.needRelease = true;
    end

    function closeFigure(src)
        src.UserData.stop = true;
        delete(src);
    end
end

function session = newSession(seed, levelIndex, config)
    session = struct();
    session.config = config;
    session.seed = seed;
    session.levelIndex = double(levelIndex);
    session.keys = pendulum.blankKeys();
    session.prevHeld = false;
    session.paused = false;
    session.needRelease = false;
    session.suppressStep = false;
    session.lastAttach = 0;
    session.lastDetach = 0;
    session.lastFail = 0;
    session.sawDeath = false;
    session.sawSuccess = false;
end

function [state, session, handles] = pump(state, session, handles)
    pressed = session.keys.spaceHeld && ~session.prevHeld;
    session.prevHeld = session.keys.spaceHeld;
    if session.paused
        if pressed
            session.paused = false;
            session.suppressStep = true;
        end
        return
    end
    if session.suppressStep
        session.suppressStep = false;
        return
    end
    if state.finished
        if session.keys.spaceHeld
            session.needRelease = true;
        elseif session.needRelease
            session.needRelease = false;
        elseif pressed
            [state, session, handles] = advance(state, session, handles);
        end
        return
    end
    if state.mode == "READY"
        if pressed
            state = pendulum.step(state, uint8(1), session.config);
        end
    else
        state = pendulum.step(state, uint8(session.keys.spaceHeld), session.config);
    end
    session = cueAudio(state, session);
end

function [state, session, handles] = advance(state, session, handles)
    if state.mode == "SUCCESS"
        session.levelIndex = session.levelIndex + 1;
    end
    level = pendulum.generateLevel(session.seed, session.levelIndex, session.config);
    state = pendulum.reset(level, session.config);
    artists = pendulum.renderLevel(handles.ax, level, session.config);
    artists.figure = handles.figure;
    artists.hudStage = handles.hudStage;
    artists.hudTime = handles.hudTime;
    artists.hudArtifacts = handles.hudArtifacts;
    artists.hudHint = handles.hudHint;
    artists.hudSeed = handles.hudSeed;
    artists.hudSeed.Text = sprintf('seed %u   level %d', level.meta.seed, level.meta.levelIndex);
    handles = artists;
    session.needRelease = false;
    session.prevHeld = true;
    session.sawDeath = false;
    session.sawSuccess = false;
    session.lastAttach = 0;
    session.lastDetach = 0;
    session.lastFail = 0;
end

function session = cueAudio(state, session)
    if state.feedback.attachTick > session.lastAttach
        session.lastAttach = state.feedback.attachTick;
        pendulum.playTone("attach", session.config);
    end
    if state.feedback.detachTick > session.lastDetach
        session.lastDetach = state.feedback.detachTick;
        pendulum.playTone("release", session.config);
    end
    if state.feedback.failedTick > session.lastFail
        session.lastFail = state.feedback.failedTick;
        pendulum.playTone("fail", session.config);
    end
    if state.mode == "DEAD" && ~session.sawDeath
        session.sawDeath = true;
        pendulum.playTone("death", session.config);
    end
    if state.mode == "SUCCESS" && ~session.sawSuccess
        session.sawSuccess = true;
        pendulum.playTone("success", session.config);
    end
end
