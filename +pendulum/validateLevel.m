function [isValid, report] = validateLevel(level, config)
%VALIDATELEVEL Structural checks. Solvability is verifyWitness, not this function.
    if nargin < 2 || isempty(config)
        config = pendulum.defaultConfig();
    end
    config = pendulum.validateConfig(config);
    messages = {};
    if config.maxTicks < 1
        messages{end + 1} = 'episode length must be positive';
    end
    messages = requireField(messages, level, 'meta');
    messages = requireField(messages, level, 'physics');
    messages = requireField(messages, level, 'witness');
    if isfield(level, 'meta')
        if ~isa(level.meta.seed, 'uint32')
            messages{end + 1} = 'meta.seed must be uint32';        end
        if ~(level.meta.levelIndex >= 1)
            messages{end + 1} = 'levelIndex must be positive';        end
    end
    messages = requireSortedIds(messages, level.anchors, 'anchors');
    messages = requireSortedIds(messages, level.platforms, 'platforms');
    messages = requireSortedIds(messages, level.hazards, 'hazards');
    if ~isfield(level, 'witness') || isempty(level.witness.actions)
        messages{end + 1} = 'witness actions are empty';    else
        actions = level.witness.actions(:);
        if any(actions ~= 0 & actions ~= 1)
            messages{end + 1} = 'witness actions must be 0 or 1';        end
    end
    if isfield(level, 'start') && any(~isfinite(level.start.position))
        messages{end + 1} = 'start position is not finite';    end
    isValid = isempty(messages);
    report = struct('messages', {messages}, 'valid', isValid);
end

function messages = requireField(messages, value, name)
    if ~isfield(value, name)
        messages{end + 1} = "Missing " + name;    end
end

function messages = requireSortedIds(messages, items, name)
    if isempty(items)
        return
    end
    ids = [items.id];
    if any(diff(ids) <= 0)
        messages{end + 1} = name + " ids must be strictly increasing";    end
end
