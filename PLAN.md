# PENDULUM: THE CLOCKWORK RUINS

Specification version: 1.0

Target: base MATLAB, 2D arcade physics adventure, one gameplay key (Space).

Primary execution: Cursor with the MathWorks MATLAB MCP Server.

Primary product requirements: deterministic seeded levels, validated solvability, a headless machine-learning environment, an interactive playable game, and identical replay across runs.

## 1. Seed contract

With seed `n = 1`, levels 1, 2, 3, 4, and 5 are identical on repeated generation. Level 1 matches later level 1, level 2 matches later level 2, and so on. The five levels are different challenges. Each level is reproducible for the tuple `(seed, levelIndex, generatorVersion, physicsVersion, difficultyConfig)`.

```matlab
A = pendulum.generateLevel(uint32(1), 1);
B = pendulum.generateLevel(uint32(1), 1);
assert(isequaln(A, B));

L5 = pendulum.generateLevel(uint32(1), 5);
L2 = pendulum.generateLevel(uint32(1), 2);
L5again = pendulum.generateLevel(uint32(1), 5);
assert(isequaln(L5, L5again));

run = pendulum.newRun();
level = pendulum.generateLevel(run.seed, 1);
```

Level N is reconstructed without generating levels `1:N-1`. Layout, anchors, platforms, obstacles, exit, collectibles, decoration, default camera, initial conditions, difficulty parameters, and the witness are independent of call order, MATLAB's global RNG, and rendering. Gameplay physics has no stochastic forces.

The world is fixed by `(seed, levelIndex)`. Player actions change the trajectory. An omitted seed draws operating-system entropy when it is available, records `run.seed`, and can be replayed. An explicit seed is never replaced. Generator and physics versions are stored on levels and replays. Canonical content and its hash are stored beside the seed.

## 2. Premise and loop

The explorer moves through suspended clockwork ruins, mostly left to right, from a start platform to an exit. Space attaches, holding reels, release launches, and released time is free flight. Space is the only gameplay key. In play, Space also starts, confirms, restarts, and advances. The same fixed-step world is the human game and the learning environment.

## 3. Input

For each tick the action is one bit: `1` held, `0` released.

```matlab
pressedEdge  = (a_t == 1) && (a_prev == 0);
releasedEdge = (a_t == 0) && (a_prev == 1);
```

Order: read action, derive edge, grapple or detach, winch or fly, integrate `dt`, resolve contacts, return observation and reward. An edge occurs once per tick, not once per frame.

- Detached key-down selects one eligible anchor or fails visibly. Failure does not queue a later attach.
- Held while attached reels toward `Lmin`. Held while detached does not change flight.
- Key-up detaches and keeps the instantaneous velocity. Version 1 adds no release impulse.
- Released ticks are ballistic flight. There is no timer that grapples automatically.
- READY consumes the starting press and moves on the next tick.
- A held key across restart or level change does nothing until a fresh `0 -> 1` edge.
- Key auto-repeat is ignored. Focus loss synthesizes a release and pauses human play. Headless mode has no focus handling.
- Events shorter than `dt` cannot be represented. Human timestamps are quantized to ticks. ML mode has a one-tick minimum hold and release.
- A second press while attached is ignored.

## 4. Coordinates and physics

`x` increases right, `y` increases up, meters and seconds, `g = 9.81` downward. `dt = 1/120`. Render target is 60 FPS and does not feed physics. Defaults live in `pendulum.defaultConfig`:

| Parameter | Value |
| --- | ---: |
| Explorer radius | 0.22 m |
| Acquisition range | 8.0 m |
| Minimum rope | 1.2 m |
| Winch speed | 1.4 m/s |
| Episode limit | 45 s |
| Safety margin | 0.15 m |

Free flight:

```matlab
p = p + v*dt + 0.5*[0, -g]*dt^2;
v = v + [0, -g]*dt;
```

Attached pose, theta from downward toward `+x`:

```matlab
p = A + L * [sin(theta), -cos(theta)];
thetaDdot = -(g/L)*sin(theta) - 2*(Ldot/L)*omega;
v = Ldot*[sin(theta), -cos(theta)] + L*omega*[cos(theta), sin(theta)];
```

`Ldot = -winch` while held and `L > Lmin`, else `0`. Integration is fixed-step RK4. Attach removes radial velocity. Detach keeps tangential and winch radial velocity. Rope length stays finite and at least `Lmin`. Line of sight uses solid geometry. The rope does not wrap. Integrator id: `ballistic-rk4-wallstop-1.0.0`.

Anchor score:

```matlab
score = 2*forwardNormalized - 0.8*distanceNormalized + 0.5*alignment;
```

Equal scores keep the lowest `anchor.id`.

## 5. Collision, landing, death, victory

The explorer is a swept circle. Solids are rectangles. Lethal bodies are circles or rectangles. Sample spacing is fine enough that a fast circle cannot tunnel through a thin solid.

- Spikes, gear disks, saws, crushing pistons, and the death plane kill.
- Walls and undersides cancel only the inward velocity and leave the explorer alive.
- A top contact from above with downward speed at or under `landingSpeed` becomes GROUNDED. Auto-run uses `runSpeed` until the platform edge. Faster top hits hard-stop and stay airborne.
- Grappling from a platform is allowed. There is no jump key.
- Collectibles are optional and do not gate the goal.
- The goal is a rectangle. Lethal contact wins over the goal on the same sample.
- Death freezes the attempt. The next fresh press restarts from the initial state.

Attached solid contact is resolved in Cartesian coordinates, then the rope is rebuilt. An invalid rebuilt rope detaches with the corrected velocity.

## 6. Stages

- Levels 1-5: static anchors, open gaps, one or two grapples, no moving hazards.
- Levels 6-15: static gears and tighter gaps, hazards outside the witness envelope.
- Levels 16-20: moving anchors, platforms, or hazards whose pose is a pure function of tick. Phase is zero at level start.
- Level 21 and above: deterministic fallback family. Generation either returns a verified level or raises `pendulum:GeneratorUnverified`.

Optional later mechanics (fragile anchors, updrafts, switches, rope fatigue) are not part of this version.

## 7. Presentation

Widescreen uifigure and uiaxes. Cached patch and line handles. Deep teal abyss, distant arches, brass platforms, a small cloaked explorer, a pale-gold rope, bronze anchors, lethal gears and spikes, a cyan goal arch, and a short HUD. The camera keeps the explorer about 35 percent from the left edge and never writes into physics. Debug overlay is a config flag. High-contrast and reduced-motion palettes are config flags. Presentation speed may sleep between frames and does not change `dt`.

Short base-MATLAB tones may play on attach, release, failed grab, death, and success. If playback throws, audio is skipped.

## 8. Solvability

Every emitted level carries a `uint8` action witness. The witness is replayed through `pendulum.step` after the final geometry is in place. Search is an ordered list of at most 64 action candidates per segment. Hazards stay outside the player sweep plus radius plus safety margin. Moving bodies are simulated on the same tick clock. A missing witness, a failed replay, or an exhausted fallback is an error, not an unverified level.

## 9. Random streams

```text
level:master=<seed>:index=<index>:stream=<name>:v=<version>
```

SHA-256 of that UTF-8 string, first four bytes little-endian, is the `RandStream('mt19937ar')` seed. Names: `topology`, `hazards`, `decoration`, `collectibles`, `solver`. Generator code does not call bare `rand`. Omitted seeds use `java.security.SecureRandom` when the JVM is on, then .NET random bytes, then a timer plus a gitignored counter and a warning.

World hash and world-plus-witness hash are separate. Hash input is a versioned little-endian field layout. It excludes hash fields, timestamps, figure handles, and stream objects.

## 10. Public API

```matlab
config = pendulum.defaultConfig();
run = pendulum.newRun('Seed', uint32(1), 'Config', config);
level = pendulum.generateLevel(uint32(1), 1, config);
[isValid, report] = pendulum.validateLevel(level, config);
[isSolvable, verification] = pendulum.verifyWitness(level, config);
state = pendulum.reset(level, config);
[state, observation, reward, terminated, truncated, info] = pendulum.step(state, uint8(0), config);
[trace, summary] = pendulum.simulate(level, actions, config);
pendulum.runGame('Seed', uint32(1), 'Level', 1);
```

## 11. Data

Level meta stores seed, index, versions, hashes, and `verified`. Geometry stores bounds, start, goal, anchors, platforms, hazards, collectibles, decorations, and witness actions, events, final tick, clearance, integrator id, and checksum.

State stores tick, mode (`READY`, `GROUNDED`, `FREE`, `ATTACHED`, `DEAD`, `SUCCESS`), player, rope, input edges, collectible mask, and result. Modes and moving poses are functions of the tick and the action, not of wall-clock time.

## 12. Learning interface

Action `0` or `1` per tick. Macro `{holdTicks, releaseTicks}` expands to the same ticks. Full and partial observations are fixed length, normalized with versioned constants, and ordered deterministically. They omit the witness. Rewards record goal `+100`, death `-100`, timeout `-20`, a small step cost, and bounded shaping separately. `terminated` is success or death. `truncated` is the time limit. Stepping a finished episode errors. Headless rollout creates no figure. Training seeds `1:1000`, validation `1001:1200`, and test `1201:1400` stay disjoint. A Reinforcement Learning Toolbox demo calls the same `step`. Witness playback is the success baseline.

## 13. Replay

Replay stores seed, index, versions, hashes, actions, `dt`, and outcome. MAT is the native file and JSON is supplemental. Mismatched version or hash is rejected. `pendulum.replay` uses `step`.

## 14. Tests

MATLAB `matlab.unittest` plus `runHeadless.m`. The default suite covers hash vectors, edges, ballistic flight, rope constraint, attach and detach, swept collisions, goal-versus-lethal priority, seed 1 levels 1-5, order independence, global RNG independence, and observation hygiene. `examples/stressGenerate.m` measures 100 seeds by levels 1-5 and 30 late levels. Performance numbers are written only after a real run.

## 15. Acceptance

One gameplay button. Seed 1 levels 1-5 repeat, in any order. A fresh seed is recorded and can rebuild its levels. Every procedural level wins by replaying its witness through `pendulum.step`. The figure is a readable clockwork ruin. Headless `step` works without graphics. Tests that have not been run are not treated as passed.

## 16. Versions

- Generator `1.0.0`
- Physics `1.0.0`
- Difficulty `1`
- Integrator `ballistic-rk4-wallstop-1.0.0`
