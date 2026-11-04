function demoSeededLevel()
%DEMOSEEDEDLEVEL Print seed-1 hashes and write five inspection frames.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    config = pendulum.defaultConfig();
    config.enableAudio = false;
    folder = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'docs', 'figures');
    if ~isfolder(folder)
        mkdir(folder);
    end
    for index = 1:5
        level = pendulum.generateLevel(uint32(1), index, config);
        fprintf('seed=1 level=%d hash=%s verified=%d\n', index, level.meta.hash, level.meta.verified);
        assert(pendulum.verifyWitness(level, config));
        pendulum.saveLevelImage(level, fullfile(folder, "seed1-level" + index + ".png"), config);
    end
end
