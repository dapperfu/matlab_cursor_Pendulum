function world = updateHazards(level, tick)
%UPDATEHAZARDS Pure poses of every dynamic body at one tick.
    anchors = level.anchors;
    anchorCount = numel(anchors);
    world.anchorPos = zeros(anchorCount, 2);
    world.anchorIds = zeros(anchorCount, 1);
    for index = 1:anchorCount
        world.anchorPos(index, :) = pendulum.anchorPose(anchors(index), tick);
        world.anchorIds(index) = anchors(index).id;
    end

    platforms = level.platforms;
    platformCount = numel(platforms);
    solidTemplate = struct('id', 0, 'rect', [0 0 0 0], 'canLand', true);
    world.solids = repmat(solidTemplate, platformCount, 1);
    for index = 1:platformCount
        world.solids(index).id = platforms(index).id;
        world.solids(index).rect = pendulum.platformPose(platforms(index), tick);
        world.solids(index).canLand = platforms(index).canLand;
    end

    hazards = level.hazards;
    hazardCount = numel(hazards);
    world.hazards = repmat(pendulum.makeHazard(0, "gear", "circle", [0 0], 0, [0 0 0 0]), hazardCount, 1);
    for index = 1:hazardCount
        world.hazards(index) = pendulum.hazardPose(hazards(index), tick);
    end

    world.collectibles = level.collectibles;
    world.goalRect = level.goal.rect;
    world.goalDirection = string(level.goal.direction);
    world.deathY = level.bounds(3);
end
