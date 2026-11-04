function level = generateLevel(seed, levelIndex, config)
%GENERATELEVEL Deterministic level with a witness that wins through step.
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    else
        config = pendulum.validateConfig(config);
    end
    if nargin < 2
        error('pendulum:InvalidLevel', 'generateLevel requires a seed and a level index.');
    end
    seed = uint32(seed);
    levelIndex = double(levelIndex);
    if ~isfinite(levelIndex) || levelIndex < 1 || levelIndex ~= floor(levelIndex)
        error('pendulum:InvalidLevel', 'levelIndex must be a positive integer.');
    end
    profile = pendulum.generation.difficultyProfile(levelIndex, config);
    streams = pendulum.createStreams(seed, levelIndex, config);
    [level, ok] = pendulum.generation.growWitnessRoute(seed, levelIndex, profile, streams, config);
    if ~ok
        streams = pendulum.createStreams(seed, levelIndex, config);
        [level, ok] = pendulum.generation.fallbackTemplate(seed, levelIndex, profile, streams, config);
    end
    if ~ok
        error('pendulum:GeneratorUnverified', ...
            'No verified witness for seed %u level %d.', seed, levelIndex);
    end
    [won, verification] = pendulum.verifyWitness(level, config);
    if ~won
        error('pendulum:GeneratorUnverified', ...
            'Witness replay failed for seed %u level %d (%s).', seed, levelIndex, verification.cause);
    end
    level.meta.verified = true;
    level.witness.finalTick = verification.finalTick;
    level.witness.clearance = verification.clearance;
    level.witness.events = verification.events;
    level.witness.integratorId = config.integratorId;
    level.witness.checksum = pendulum.bytesToHex(pendulum.sha256Bytes(uint8(level.witness.actions(:))));
    level.meta.worldHash = pendulum.levelHash(level, "world");
    level.meta.hash = pendulum.levelHash(level, "full");
end
