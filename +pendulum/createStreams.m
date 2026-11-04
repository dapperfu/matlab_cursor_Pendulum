function streams = createStreams(masterSeed, levelIndex, config)
%CREATESTREAMS Independent mt19937ar streams. Does not touch the global RNG.
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    end
    names = ["topology", "hazards", "decoration", "collectibles", "solver"];
    for index = 1:numel(names)
        name = names(index);
        seed = pendulum.deriveSeed(masterSeed, levelIndex, name, config.generatorVersion);
        streams.(name) = RandStream('mt19937ar', 'Seed', seed);
    end
end
