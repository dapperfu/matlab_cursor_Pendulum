function [isSolvable, verification] = verifyWitness(level, config)
%VERIFYWITNESS Replay the stored actions through pendulum.step.
    if nargin < 2 || isempty(config)
        config = pendulum.defaultConfig();
    end
    actions = uint8(level.witness.actions(:));
    [~, summary] = pendulum.simulate(level, actions, config);
    isSolvable = logical(summary.success) && ~isempty(actions);
    verification = summary;
    verification.actionCount = numel(actions);
end
