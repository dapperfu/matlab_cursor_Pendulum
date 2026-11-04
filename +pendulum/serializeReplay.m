function replayData = serializeReplay(level, actions, summary, filePath)
%SERIALIZEREPLAY MAT replay plus a supplemental JSON file when a path is given.
    replayData = struct();
    replayData.format = "pendulum-replay-1";
    replayData.seed = uint32(level.meta.seed);
    replayData.levelIndex = double(level.meta.levelIndex);
    replayData.generatorVersion = string(level.meta.generatorVersion);
    replayData.physicsVersion = string(level.meta.physicsVersion);
    replayData.integratorId = string(level.witness.integratorId);
    replayData.hash = string(level.meta.hash);
    replayData.worldHash = string(level.meta.worldHash);
    replayData.dt = level.physics.dt;
    replayData.actions = uint8(actions(:));
    replayData.outcome = string(summary.outcome);
    replayData.finalTick = double(summary.finalTick);
    if nargin >= 4 && ~isempty(filePath)
        save(filePath, 'replayData');
        [folder, name] = fileparts(filePath);
        jsonText = jsonencode(replayData);
        fid = fopen(fullfile(folder, name + ".json"), 'w');
        cleaner = onCleanup(@() fclose(fid));
        fwrite(fid, jsonText);
    end
end
