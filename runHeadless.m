function runHeadless()
%RUNHEADLESS Replay the seed-1 witness for levels 1-5 without a figure.
    startup();
    config = pendulum.defaultConfig();
    config.enableAudio = false;
    for index = 1:5
        level = pendulum.generateLevel(uint32(1), index, config);
        [~, summary] = pendulum.simulate(level, level.witness.actions, config);
        fprintf('seed=1 level=%d hash=%s verified=%d success=%d\n', ...
            index, level.meta.hash, level.meta.verified, summary.success);
        assert(summary.success);
        assert(pendulum.verifyWitness(level, config));
    end
end
