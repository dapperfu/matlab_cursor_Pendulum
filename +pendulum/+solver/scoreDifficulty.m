function score = scoreDifficulty(level, verification)
%SCOREDIFFICULTY Numeric summary of a verified episode. Not a solvability proof.
    if nargin < 2
        [~, verification] = pendulum.verifyWitness(level);
    end
    attachCount = 0;
    if ~isempty(verification.events)
        attachCount = sum([verification.events.type] == "attach");
    end
    score = struct();
    score.grapples = attachCount;
    score.ticks = verification.finalTick;
    score.clearance = verification.clearance;
    score.success = verification.success;
    score.levelIndex = level.meta.levelIndex;
end
