function delta = motionDelta(motion, tick)
%MOTIONDELTA Planar offset of a body at a simulation tick. Phase zero is tick 0.
    delta = [0 0];
    if motion.type == "static" || motion.amplitude == 0 || motion.period == 0
        return
    end
    distance = motion.amplitude * sin(2 * pi * (double(tick) + motion.phase) / motion.period);
    if motion.axis == "y"
        delta(2) = distance;
    else
        delta(1) = distance;
    end
end
