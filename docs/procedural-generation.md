# Procedural generation

A level is the tuple `(seed, levelIndex, generatorVersion, physicsVersion, difficultyVersion)`. `pendulum.deriveSeed` hashes

```text
level:master=<seed>:index=<index>:stream=<name>:v=<version>
```

with the project SHA-256 and takes the first four digest bytes as a little-endian `uint32` `RandStream` seed. Streams are `topology`, `hazards`, `decoration`, `collectibles`, and `solver`. Generation does not call the global `rand`.

`pendulum.generation.growWitnessRoute` previews the grounded run, then tries up to 64 `(delay, hold, dx, dy)` tuples. Each tuple places an anchor at the press-tick pose, simulates with `pendulum.step`, and puts the goal on a later coast point that is spatially clear of the attached arc. Hazards are placed only where their motion tube misses that path. The witness is accepted only when `pendulum.verifyWitness` replays it to SUCCESS. If the list fails, `fallbackTemplate` retries a conservative tuple. If that also fails, `generateLevel` throws `pendulum:GeneratorUnverified`.

Levels 1-5 are static. Levels 6-15 add gears, saws, or spikes. Levels 16-20 and the fallback family add tick-phased motion. Canonical hashes exclude `meta.hash` and `meta.worldHash`. `meta.hash` covers the world plus the witness. `meta.worldHash` covers the world only.

`pendulum.newRun` without a seed uses `java.security.SecureRandom` when the JVM is available, then .NET random bytes, then a timer plus `.pendulum_seed_counter` and a warning. An explicit seed is never replaced.
