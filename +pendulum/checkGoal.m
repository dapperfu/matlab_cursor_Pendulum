function hit = checkGoal(position, radius, velocity, goalRect, direction)
%CHECKGOAL True when the explorer circle is inside the goal from an allowed side.
    if isempty(goalRect) || numel(goalRect) ~= 4 || any(~isfinite(goalRect))
        hit = false;
        return
    end
    hit = pendulum.circleOverlapsRect(position, radius, goalRect, 0);
    if hit && string(direction) == "right" && velocity(1) < -0.1
        hit = false;
    end
end
