function bytes = canonicalizeLevel(level, scope)
%CANONICALIZELEVEL Versioned little-endian bytes. Hash fields are not inputs.
    if nargin < 2 || isempty(scope)
        scope = "full";
    end
    scope = string(scope);
    bytes = uint8([]);
    bytes = pushText(bytes, "pendulum-level-1");
    bytes = pushText(bytes, scope);
    bytes = pushU32(bytes, uint32(level.meta.seed));
    bytes = pushI32(bytes, int32(level.meta.levelIndex));
    bytes = pushText(bytes, level.meta.generatorVersion);
    bytes = pushText(bytes, level.meta.physicsVersion);
    bytes = pushText(bytes, level.meta.difficultyVersion);
    bytes = pushU8(bytes, uint8(logical(level.meta.verified)));
    bytes = pushText(bytes, level.title);
    bytes = pushText(bytes, level.stageTitle);
    bytes = pushDoubles(bytes, level.bounds);
    physics = level.physics;
    bytes = pushDoubles(bytes, [physics.dt, physics.gravity, physics.playerRadius, ...
        physics.acquireRange, physics.minRopeLength, physics.winchSpeed, ...
        physics.landingSpeed, physics.runSpeed]);
    bytes = pushText(bytes, physics.integratorId);
    bytes = pushDoubles(bytes, level.start.position);
    bytes = pushDoubles(bytes, level.start.velocity);
    bytes = pushText(bytes, level.start.mode);
    bytes = pushDoubles(bytes, level.goal.rect);
    bytes = pushText(bytes, level.goal.direction);
    bytes = pushDoubles(bytes, [level.camera.viewWidth, level.camera.anchorFraction]);
    bytes = pushAnchors(bytes, sortById(level.anchors));
    bytes = pushPlatforms(bytes, sortById(level.platforms));
    bytes = pushHazards(bytes, sortById(level.hazards));
    bytes = pushCollectibles(bytes, sortById(level.collectibles));
    bytes = pushDecorations(bytes, sortById(level.decorations));
    if scope == "full"
        bytes = pushWitness(bytes, level.witness);
    end
end

function items = sortById(items)
    if isempty(items)
        return
    end
    [~, order] = sort([items.id], 'ascend');
    items = items(order);
end

function bytes = pushWitness(bytes, witness)
    actions = uint8(witness.actions(:));
    bytes = pushU32(bytes, uint32(numel(actions)));
    bytes = [bytes; actions];    events = witness.events;
    bytes = pushU32(bytes, uint32(numel(events)));
    for index = 1:numel(events)
        bytes = pushI32(bytes, int32(events(index).tick));
        bytes = pushText(bytes, events(index).type);
    end
    bytes = pushI32(bytes, int32(witness.finalTick));
    bytes = pushDoubles(bytes, witness.clearance);
    bytes = pushText(bytes, witness.integratorId);
    bytes = pushText(bytes, witness.checksum);
end

function bytes = pushAnchors(bytes, anchors)
    bytes = pushU32(bytes, uint32(numel(anchors)));
    for index = 1:numel(anchors)
        body = anchors(index);
        bytes = pushI32(bytes, int32(body.id));
        bytes = pushDoubles(bytes, body.position);
        bytes = pushDoubles(bytes, body.radius);
        bytes = pushMotion(bytes, body.motion);
    end
end

function bytes = pushPlatforms(bytes, platforms)
    bytes = pushU32(bytes, uint32(numel(platforms)));
    for index = 1:numel(platforms)
        body = platforms(index);
        bytes = pushI32(bytes, int32(body.id));
        bytes = pushDoubles(bytes, body.rect);
        bytes = pushU8(bytes, uint8(body.canLand));
        bytes = pushMotion(bytes, body.motion);
    end
end

function bytes = pushHazards(bytes, hazards)
    bytes = pushU32(bytes, uint32(numel(hazards)));
    for index = 1:numel(hazards)
        body = hazards(index);
        bytes = pushI32(bytes, int32(body.id));
        bytes = pushText(bytes, body.kind);
        bytes = pushText(bytes, body.shape);
        bytes = pushDoubles(bytes, body.center);
        bytes = pushDoubles(bytes, body.radius);
        bytes = pushDoubles(bytes, body.rect);
        bytes = pushMotion(bytes, body.motion);
    end
end

function bytes = pushCollectibles(bytes, items)
    bytes = pushU32(bytes, uint32(numel(items)));
    for index = 1:numel(items)
        bytes = pushI32(bytes, int32(items(index).id));
        bytes = pushDoubles(bytes, items(index).position);
        bytes = pushDoubles(bytes, items(index).radius);
    end
end

function bytes = pushDecorations(bytes, items)
    bytes = pushU32(bytes, uint32(numel(items)));
    for index = 1:numel(items)
        bytes = pushI32(bytes, int32(items(index).id));
        bytes = pushText(bytes, items(index).kind);
        bytes = pushDoubles(bytes, items(index).position);
        bytes = pushDoubles(bytes, items(index).size);
        bytes = pushDoubles(bytes, items(index).depth);
    end
end

function bytes = pushMotion(bytes, motion)
    bytes = pushText(bytes, motion.type);
    bytes = pushDoubles(bytes, [motion.amplitude, motion.period, motion.phase]);
    bytes = pushText(bytes, motion.axis);
end

function bytes = pushText(bytes, value)
    encoded = uint8(unicode2native(char(string(value)), 'UTF-8'));
    bytes = pushU32(bytes, uint32(numel(encoded)));
    bytes = [bytes; encoded(:)];end

function bytes = pushDoubles(bytes, values)
    raw = typecast(double(values(:).'), 'uint8');
    if hostIsBigEndian()
        raw = reshape(raw, 8, []);
        raw = flipud(raw);
        raw = raw(:).';
    end
    bytes = [bytes; raw(:)];end

function bytes = pushU32(bytes, value)
    bytes = [bytes; typecastLittle(uint32(value))];end

function bytes = pushI32(bytes, value)
    bytes = [bytes; typecastLittle(int32(value))];end

function bytes = pushU8(bytes, value)
    bytes = [bytes; uint8(value)];end

function raw = typecastLittle(value)
    raw = typecast(value, 'uint8');
    if hostIsBigEndian()
        raw = flip(raw(:));
    else
        raw = raw(:);
    end
end

function yes = hostIsBigEndian()
    probe = typecast(uint16(1), 'uint8');
    yes = probe(1) == 0;
end
