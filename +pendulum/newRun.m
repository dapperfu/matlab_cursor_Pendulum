function run = newRun(options)
%NEWRUN Record a master seed. Omit Seed to draw entropy once.
    arguments
        options.Seed = []
        options.Config = pendulum.defaultConfig()
    end
    run = struct();
    run.config = pendulum.validateConfig(options.Config);
    if isempty(options.Seed)
        [run.seed, run.entropy] = pendulum.freshSeed();
    else
        run.seed = uint32(options.Seed);
        run.entropy = "explicit";
    end
end
