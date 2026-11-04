function demoReplay()
%DEMOREPLAY Save a witness replay and run it back through step.
    addpath(fileparts(fileparts(mfilename('fullpath'))));
    config = pendulum.defaultConfig();
    level = pendulum.generateLevel(uint32(1), 3, config);
    [~, summary] = pendulum.simulate(level, level.witness.actions, config);
    folder = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'docs', 'figures');
    if ~isfolder(folder)
        mkdir(folder);
    end
    filePath = fullfile(folder, 'seed1-level3-replay.mat');
    replayData = pendulum.serializeReplay(level, level.witness.actions, summary, filePath);
    loaded = pendulum.loadReplay(filePath);
    [~, played] = pendulum.replay(level, loaded, config);
    fprintf('replay success=%d tick=%d file=%s\n', played.success, played.finalTick, replayData.hash);
    assert(played.success);
end
