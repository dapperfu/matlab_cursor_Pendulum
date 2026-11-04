function replayData = loadReplay(filePath)
%LOADREPLAY Read a MAT replay written by serializeReplay.
    loaded = load(filePath, 'replayData');
    replayData = loaded.replayData;
end
