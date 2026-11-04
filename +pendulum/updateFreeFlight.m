function [position, velocity] = updateFreeFlight(position, velocity, dt, gravity)
%UPDATEFREEFLIGHT Exact constant-gravity ballistic step.
    acceleration = [0, -gravity];
    position = position + velocity * dt + 0.5 * acceleration * dt ^ 2;
    velocity = velocity + acceleration * dt;
end
