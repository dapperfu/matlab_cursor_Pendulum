function value = goalPotential(state, config)
%GOALPOTENTIAL Bounded-scale progress term. More negative means farther from the gate.
    rect = state.level.goal.rect;
    center = [(rect(1) + rect(3)) * 0.5, (rect(2) + rect(4)) * 0.5];
    distance = hypot(state.player.position(1) - center(1), state.player.position(2) - center(2));
    value = -distance / config.shapingScale;
end
