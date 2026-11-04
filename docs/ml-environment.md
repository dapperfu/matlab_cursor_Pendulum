# Learning environment

`pendulum.reset` and `pendulum.step` do not open figures, play sound, or draw. The action is `uint8(0)` or `uint8(1)` for one physics tick. `{holdTicks, releaseTicks}` macros expand through `pendulum.expandMacros` and then use the same `step`.

Observations are fixed-length columns. `config.observationMode` is `"full"` or `"partial"`. Normalization constants live in `config.norm`. The witness action vector is not part of the observation. `pendulum.simulate(level, level.witness.actions)` is the privileged baseline.

Rewards are returned as one number and also as `info.rewardComponents`: goal `+100`, death `-100`, timeout `-20`, a step cost, and shaping clipped to `+/-1`. `terminated` is success or death. `truncated` is the 45 s limit. Stepping a finished episode throws `pendulum:TerminalState`.

Suggested splits, kept disjoint from each other:

- train seeds `1:1000`
- validation seeds `1001:1200`
- test seeds `1201:1400`

`examples/demoAgentTraining.m` builds an `rlFunctionEnv` and runs a three-episode DQN pass. That pass is a wiring check. A win is claimed only for the witness replay.

Replays store the level hash, versions, `dt`, and actions. `pendulum.replay` rejects a hash or version mismatch.
