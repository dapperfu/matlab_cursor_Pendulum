function rect = platformPose(platform, tick)
%PLATFORMPOSE World rectangle of a platform at a tick.
    delta = pendulum.motionDelta(platform.motion, tick);
    rect = platform.rect;
    rect([1 3]) = rect([1 3]) + delta(1);
    rect([2 4]) = rect([2 4]) + delta(2);
end
