# Physics

Coordinates are meters. `x` increases to the right and `y` increases upward. Gravity is 9.81 m/s^2 downward. The integrator id is `ballistic-rk4-wallstop-1.0.0`.

Detached flight is the exact constant-acceleration update

```matlab
p = p + v*dt + 0.5*[0, -g]*dt^2;
v = v + [0, -g]*dt;
```

Attached motion uses

```matlab
p = A + L * [sin(theta), -cos(theta)];
```

with fixed-step RK4 on `(theta, omega, L)`. Holding sets `Ldot = -winch` until `Lmin`. The world velocity includes that radial term. Attachment removes the incoming radial speed, then the winch may start on the same tick. Release keeps the velocity already stored on the explorer.

The body is a circle of radius 0.22 m. Contacts are sampled along the segment from the pre-step position to the post-step position. Lethal bodies and the death plane win over solid contacts, pickups, and the goal. A wall or underside cancels only the inward velocity. A top hit from above at or under `landingSpeed` becomes grounded auto-run at `runSpeed` until the platform edge. A faster top hit is a hard stop and stays airborne.

Moving bodies are pure functions of the tick. Phase is zero at tick 0. Rendering never writes back into this state.
