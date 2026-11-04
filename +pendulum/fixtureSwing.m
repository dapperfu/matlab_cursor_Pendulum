function level = fixtureSwing()
%FIXTURESWING Hand-built gap whose stored Space trace wins through step.
    config = pendulum.defaultConfig();
    level = pendulum.blankLevel();
    level.meta.seed = uint32(0);
    level.meta.levelIndex = 1;
    level.title = "Manual Gap";
    level.stageTitle = "Fixture";
    level.bounds = [-5 40 -8 20];
    level.physics = pendulum.physicsBlock(config);
    level.start.position = [1, config.playerRadius];
    level.start.velocity = [config.runSpeed, 0];
    level.start.mode = "GROUNDED";
    level.platforms = pendulum.makePlatform(1, [0, -1, 3.5, 0], true);
    level.anchors = pendulum.makeAnchor(1, [5.5, 5.5]);
    level.goal.rect = [7, -1, 16, 8];
    level.goal.direction = "any";
    actions = zeros(204, 1, 'uint8');
    actions(1) = 1;
    actions(140:190) = 1;
    level.witness.actions = actions;
    level.witness.integratorId = config.integratorId;
    [won, verification] = pendulum.verifyWitness(level, config);
    if ~won
        error('pendulum:FixtureUnverified', 'The manual swing fixture no longer reaches the gate.');
    end
    level.meta.verified = true;
    level.witness.finalTick = verification.finalTick;
    level.witness.clearance = verification.clearance;
    level.witness.events = verification.events;
    level.witness.checksum = pendulum.bytesToHex(pendulum.sha256Bytes(actions));
    level.meta.worldHash = pendulum.levelHash(level, "world");
    level.meta.hash = pendulum.levelHash(level, "full");
end
