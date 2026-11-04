function [position, velocity] = polarState(anchor, theta, omega, ropeLength, lengthRate)
%POLARSTATE Cartesian pose from the pendulum coordinates.
    radial = [sin(theta), -cos(theta)];
    tangent = [cos(theta), sin(theta)];
    position = anchor + ropeLength * radial;
    velocity = lengthRate * radial + (ropeLength * omega) * tangent;
end
