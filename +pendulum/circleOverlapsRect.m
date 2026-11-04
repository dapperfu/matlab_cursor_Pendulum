function hit = circleOverlapsRect(position, radius, rect, skin)
%CIRCLEOVERLAPSRECT Strict overlap. Touching the boundary is not a hit.
    if nargin < 4
        skin = 0;
    end
    closestX = min(max(position(1), rect(1)), rect(3));
    closestY = min(max(position(2), rect(2)), rect(4));
    dx = position(1) - closestX;
    dy = position(2) - closestY;
    limit = radius - skin;
    hit = limit > 0 && (dx * dx + dy * dy) < limit * limit;
end
