function position = anchorPose(anchor, tick)
%ANCHORPOSE World position of an anchor at a tick.
    position = anchor.position + pendulum.motionDelta(anchor.motion, tick);
end
