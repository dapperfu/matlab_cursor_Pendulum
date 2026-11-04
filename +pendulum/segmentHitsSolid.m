function hit = segmentHitsSolid(p0, p1, rects)
%SEGMENTHITSOLID True when the segment intersects any solid rectangle.
    hit = false;
    if isempty(rects)
        return
    end
    for index = 1:size(rects, 1)
        if segmentHitsRect(p0, p1, rects(index, :))
            hit = true;
            return
        end
    end
end

function hit = segmentHitsRect(p0, p1, rect)
    delta = p1 - p0;
    tMin = 0;
    tMax = 1;
    bounds = [rect(1) rect(3); rect(2) rect(4)];
    for axis = 1:2
        if abs(delta(axis)) < 1e-12
            if p0(axis) < bounds(axis, 1) || p0(axis) > bounds(axis, 2)
                hit = false;
                return
            end
        else
            t1 = (bounds(axis, 1) - p0(axis)) / delta(axis);
            t2 = (bounds(axis, 2) - p0(axis)) / delta(axis);
            tNear = min(t1, t2);
            tFar = max(t1, t2);
            tMin = max(tMin, tNear);
            tMax = min(tMax, tFar);
            if tMin > tMax
                hit = false;
                return
            end
        end
    end
    hit = true;
end
