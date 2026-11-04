function body = makePlatform(id, rect, canLand, motion)
%MAKEPLATFORM Axis-aligned solid. rect is [xmin ymin xmax ymax].
    if nargin < 4
        motion = pendulum.staticMotion();
    end
    if nargin < 3
        canLand = true;
    end
    body = struct('id', double(id), 'rect', reshape(double(rect), 1, 4), ...
        'canLand', logical(canLand), 'motion', motion);
end
