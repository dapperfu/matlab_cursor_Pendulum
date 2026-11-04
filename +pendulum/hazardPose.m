function hazard = hazardPose(hazard, tick)
%HAZARDPOSE World pose of a hazard at a tick. The input record is not stored back.
    delta = pendulum.motionDelta(hazard.motion, tick);
    hazard.center = hazard.center + delta;
    hazard.rect([1 3]) = hazard.rect([1 3]) + delta(1);
    hazard.rect([2 4]) = hazard.rect([2 4]) + delta(2);
end
