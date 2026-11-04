# Pendulum Clockwork Ruins execution plan

Product contract: [PLAN.md](../PLAN.md). This file is the Cursor execution plan. Check off a TODO only in the commit that completes it.

## TODOs

- [x] save-plans: Write this plan and root PLAN.md.
- [x] m0-skeleton: startup, defaultConfig, validateConfig, pure SHA-256, TestSha256, MATLAB MCP.
- [x] m1-simulator: reset, step, free flight, edges, terminals, identical action replay.
- [x] m2-rope: anchor selection, attach impulse, RK4 pendulum, detach velocity.
- [x] m3-collisions: swept collisions, hard-stop solids, lethal hazards, grounded auto-run, goal priority, hand-built witness.
- [ ] m4-generator: seeded streams, witness-first generation, fallbacks, canonical hash, seed 1 levels 1-5.
- [ ] m5-uifigure: Space-only uifigure client, cached art, optional tones, render-independent physics.
- [ ] m6-stages: Stage II-III templates and tick-phased moving bodies through level 20 plus fallbacks.
- [ ] m7-ml: observations, rewards, replay, headless rollout, witness baseline, bounded RL Toolbox demo.
- [ ] m8-stress-docs: stress script, measured performance, hash fixtures, README and docs.

## Decisions

- Package `+pendulum` lives at the repository root. Subpackages are `+pendulum/+generation` and `+pendulum/+solver`.
- Campaign levels 1-20, then a terminating fallback family. Stage I is 1-5, Stage II is 6-15, Stage III is 16-20.
- Free flight is exact constant-gravity ballistic motion. Attached motion is fixed-step RK4 on `(theta, omega, L)`.
- Walls and undersides hard-stop. A slow top landing becomes grounded auto-run. Spikes, gear disks, saws, crushing pistons, and the death plane kill.
- Contact priority: lethal, solid, collectible, goal.
- Canonical hash is pure MATLAB SHA-256. Stream seeds are the first four digest bytes, little-endian uint32.
- Search budget is 64 candidates per segment, then a fallback. Fallback failure raises `pendulum:GeneratorUnverified`.
- Default tests cover determinism and seed 1 levels 1-5. `examples/stressGenerate.m` runs the large seed matrix.
- Observations never include the witness. RL Toolbox training is extra; witness playback is the success gate.
- Client is a uifigure. Space starts, grapples, retries, and advances. Audio failure is ignored. Physics never waits on audio.
- Integrator id: `ballistic-rk4-wallstop-1.0.0`.

## Step order

Read the binary action, derive edges, let READY consume a press, select or detach, winch or fly, integrate one `dt`, resolve contacts, then return observation, reward, and terminal flags.

## Generation

Derive independent `mt19937ar` streams (`topology`, `hazards`, `decoration`, `collectibles`, `solver`). Build a trajectory with the production step, place the goal on that trajectory, place hazards outside the swept envelope, and accept the level only after `pendulum.step` replays the witness to SUCCESS.

## Git

Repo-local author: `$env:USERNAME | Cursor.sh | Grok 4.7`. No upstream remote exists; fetch origin before committing. One new file per commit. TODO checkoff shares the commit that completes that TODO. No Requirements section until a StrictDoc file exists.
