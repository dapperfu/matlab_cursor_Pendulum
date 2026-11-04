function level = placeDecoration(level, stream, profile)
%PLACEDECORATION Background geometry. It never enters the collision world.
    kinds = ["arch", "wheel", "chain", "column"];
    count = 7;
    decorations = repmat(pendulum.makeDecoration(0, "arch", [0 0], [1 1], 0), count, 1);
    span = level.bounds(2) - level.bounds(1);
    for index = 1:count
        kind = kinds(randi(stream, numel(kinds)));
        x = level.bounds(1) + rand(stream) * span;
        y = 6 + rand(stream) * 12;
        depth = randi(stream, 3) - 1;
        decorations(index) = pendulum.makeDecoration(index, kind, [x y], [1.4 + rand(stream), 2 + rand(stream)], depth);
    end
    if profile.stage == 1
        decorations(1).kind = "arch";
    end
    level.decorations = decorations;
end
