function body = makeHazard(id, kind, shape, center, radius, rect, motion)
%MAKEHAZARD Lethal body. shape is "circle" or "aabb".
    if nargin < 7
        motion = pendulum.staticMotion();
    end
    body = struct('id', double(id), 'kind', string(kind), 'shape', string(shape), ...
        'center', reshape(double(center), 1, 2), 'radius', double(radius), ...
        'rect', reshape(double(rect), 1, 4), 'motion', motion);
end
