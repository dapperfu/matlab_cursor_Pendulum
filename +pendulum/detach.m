function state = detach(state)
%DETACH Drop the rope and keep the current Cartesian velocity.
    if state.mode ~= "ATTACHED"
        return
    end
    state.mode = "FREE";
    state.rope.anchorId = 0;
    state.stats.detachCount = state.stats.detachCount + 1;
    state.feedback.detachTick = state.tick;
end
