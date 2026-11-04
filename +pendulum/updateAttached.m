function state = updateAttached(state, anchorPosition, action, config)
%UPDATEATTACHED One RK4 step of the variable-length pendulum.
    held = action == 1;
    y0 = [state.rope.theta; state.rope.omega; state.rope.length];
    y1 = rk4(y0, config.dt, held, config);
    ropeLength = y1(3);
    lengthRate = 0;
    if held && ropeLength > config.minRopeLength
        lengthRate = -config.winchSpeed;
    end
    if ropeLength <= config.minRopeLength
        ropeLength = config.minRopeLength;
        lengthRate = 0;
    end
    [position, velocity] = pendulum.polarState(anchorPosition, y1(1), y1(2), ropeLength, lengthRate);
    state.rope.theta = y1(1);
    state.rope.omega = y1(2);
    state.rope.length = ropeLength;
    state.player.position = position;
    state.player.velocity = velocity;
end

function y1 = rk4(y0, dt, held, config)
    k1 = ropeRates(y0, held, config);
    k2 = ropeRates(y0 + 0.5 * dt * k1, held, config);
    k3 = ropeRates(y0 + 0.5 * dt * k2, held, config);
    k4 = ropeRates(y0 + dt * k3, held, config);
    y1 = y0 + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
end

function rates = ropeRates(y, held, config)
    theta = y(1);
    omega = y(2);
    ropeLength = max(y(3), config.minRopeLength);
    if held && y(3) > config.minRopeLength
        lengthRate = -config.winchSpeed;
    else
        lengthRate = 0;
    end
    angularAcc = -(config.gravity / ropeLength) * sin(theta) - 2 * (lengthRate / ropeLength) * omega;
    rates = [omega; angularAcc; lengthRate];
end
