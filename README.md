# matlab_cursor_Pendulum

Pendulum: The Clockwork Ruins is a one-button MATLAB game and a headless control environment. Space grapples, reels, releases, and coasts. Every generated level carries a witness that wins through `pendulum.step`.

The product contract is [PLAN.md](PLAN.md). The execution plan is [plans/pendulum-clockwork-ruins.md](plans/pendulum-clockwork-ruins.md).

## Play

From this folder in MATLAB:

```matlab
startup
pendulum.runGame('Seed', uint32(1), 'Level', 1)
```

Omit the seed for a recorded entropy seed:

```matlab
run = pendulum.newRun();
fprintf('Replay seed: %u\n', run.seed);
pendulum.runGame('Seed', run.seed, 'Level', 1);
```

## Replay a seed

```matlab
startup
for k = 1:5
    level = pendulum.generateLevel(uint32(1), k);
    fprintf('seed=1 level=%d hash=%s verified=%d\n', ...
        k, level.meta.hash, level.meta.verified);
    assert(pendulum.verifyWitness(level));
end
rng(12345); first = pendulum.generateLevel(uint32(1), 2);
rng(98765); second = pendulum.generateLevel(uint32(1), 2);
assert(strcmp(first.meta.hash, second.meta.hash));
```

Headless witness playback:

```matlab
runHeadless
level = pendulum.generateLevel(uint32(1), 3);
[~, summary] = pendulum.simulate(level, level.witness.actions);
assert(summary.success);
```

## Learning

```matlab
examples/demoAgentTraining
```

See [docs/controls.md](docs/controls.md), [docs/physics.md](docs/physics.md), [docs/procedural-generation.md](docs/procedural-generation.md), and [docs/ml-environment.md](docs/ml-environment.md).

`examples/stressGenerate.m` measures the 100 by 5 and 30 late-level gates and writes [docs/performance.md](docs/performance.md).
