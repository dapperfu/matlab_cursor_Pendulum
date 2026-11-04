function config = validateConfig(config)
%VALIDATECONFIG Fill missing configuration fields and reject invalid physics.
    defaults = pendulum.defaultConfig();
    if nargin < 1 || isempty(config)
        config = defaults;
    end
    names = fieldnames(defaults);
    for index = 1:numel(names)
        name = names{index};
        if ~isfield(config, name) || isempty(config.(name))
            config.(name) = defaults.(name);
        end
    end
    config.dt = double(config.dt);
    config.gravity = double(config.gravity);
    config.playerRadius = double(config.playerRadius);
    config.acquireRange = double(config.acquireRange);
    config.minRopeLength = double(config.minRopeLength);
    config.winchSpeed = double(config.winchSpeed);
    config.maxEpisodeSeconds = double(config.maxEpisodeSeconds);
    config.safetyMargin = double(config.safetyMargin);
    config.landingSpeed = double(config.landingSpeed);
    config.runSpeed = double(config.runSpeed);
    config.presentationSpeed = double(config.presentationSpeed);
    if config.dt <= 0 || config.gravity <= 0 || config.playerRadius <= 0
        error('pendulum:InvalidConfig', 'dt, gravity, and player radius must be positive.');
    end
    if config.minRopeLength <= 0 || config.acquireRange <= config.minRopeLength
        error('pendulum:InvalidConfig', 'Rope limits are inconsistent.');
    end
    if config.winchSpeed < 0 || config.maxEpisodeSeconds <= 0 || config.presentationSpeed <= 0
        error('pendulum:InvalidConfig', 'Winch, episode length, and presentation speed must be positive.');
    end
    config.maxTicks = round(config.maxEpisodeSeconds / config.dt);
    config.generatorVersion = string(config.generatorVersion);
    config.physicsVersion = string(config.physicsVersion);
    config.difficultyVersion = string(config.difficultyVersion);
    config.integratorId = string(config.integratorId);
    config.observationMode = string(config.observationMode);
    config.palette = string(config.palette);
    config.art = pendulum.artPalette(config.palette);
end
