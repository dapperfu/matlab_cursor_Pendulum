function profile = difficultyProfile(levelIndex, config)
%DIFFICULTYPROFILE Stage bands for the bounded campaign and the fallback family.
    if nargin < 2 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.validateConfig(config);
    levelIndex = double(levelIndex);
    profile = struct();
    profile.levelIndex = levelIndex;
    profile.horizon = min(700, config.maxTicks);
    profile.deathY = -12;
    profile.minProgress = 3;
    profile.platformWidth = 3.3 + 0.08 * mod(levelIndex - 1, 8);
    profile.hazardCount = 0;
    profile.moving = false;
    profile.anchorAmplitude = 0;
    profile.stage = 1;
    if levelIndex <= 5
        titles = ["The First Swing", "Across the Shaft", "The Long Release", "The Brass Gap", "The Clock Gate"];
        profile.title = titles(levelIndex);
        profile.stageTitle = "The First Swing";
        profile.hazardCount = 0;
    elseif levelIndex <= 15
        profile.stage = 2;
        profile.stageTitle = "Gear Vaults";
        profile.title = "Gear Vault " + levelIndex;
        profile.hazardCount = 1 + mod(levelIndex, 2);
        profile.platformWidth = 3.35 + 0.05 * mod(levelIndex, 5);
    elseif levelIndex <= 20
        profile.stage = 3;
        profile.stageTitle = "The Moving Works";
        profile.title = "Moving Works " + levelIndex;
        profile.moving = true;
        profile.anchorAmplitude = 0.35;
        profile.hazardCount = 2;
        profile.platformWidth = 3.5 + 0.06 * mod(levelIndex, 4);
    else
        profile.stage = 4;
        profile.stageTitle = "The Broken City";
        profile.title = "Broken City " + levelIndex;
        profile.moving = true;
        profile.anchorAmplitude = 0.25;
        profile.hazardCount = 1;
        profile.platformWidth = 3.6;
    end
end
