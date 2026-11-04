function body = makeAnchor(id, position, motion)
%MAKEANCHOR A grapple ring. position is [x y] in meters.
    if nargin < 3
        motion = pendulum.staticMotion();
    end
    body = struct('id', double(id), 'position', reshape(double(position), 1, 2), ...
        'radius', 0.25, 'motion', motion);
end
