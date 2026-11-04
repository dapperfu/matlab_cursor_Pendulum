function [actions, summary] = solveLevel(level, config)
%SOLVELEVEL Search press and hold ticks on a fixed level. Empty when none win.
    if nargin < 2 || isempty(config)
        config = pendulum.defaultConfig();
    end
    actions = zeros(0, 1, 'uint8');
    summary = struct('success', false, 'cause', "unsolved", 'finalTick', 0);
    probe = level;
    probe.goal.rect = [1e5, 0, 1e5 + 1, 1];
    previewActions = zeros(500, 1, 'uint8');
    previewActions(1) = 1;
    preview = pendulum.simulate(probe, previewActions, config);
    leave = find(preview.mode == "FREE", 1, 'first');
    if isempty(leave)
        leave = 2;
    end
    delays = [10 20 30 40 55 70 90];
    holds = [15 30 45 60 80 110];
    for delay = delays
        for hold = holds
            press = leave + delay;
            if press < 3
                continue
            end
            candidate = zeros(min(config.maxTicks, press + hold + 220), 1, 'uint8');
            candidate(1) = 1;
            lastHold = min(numel(candidate), press + hold - 1);
            if lastHold >= press
                candidate(press:lastHold) = 1;
            end
            [~, summary] = pendulum.simulate(level, candidate, config);
            if summary.success
                actions = candidate(1:summary.finalTick);
                return
            end
        end
    end
end
