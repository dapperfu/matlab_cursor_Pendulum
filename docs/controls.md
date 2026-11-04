# Controls

Space is the only gameplay key.

- A press from READY starts the level and does not grapple on that same tick. Motion begins on the next tick.
- While detached, a new press selects one eligible anchor or shows a failed grab. Holding after a miss does not attach later.
- While attached, holding reels the rope in at 1.4 m/s until 1.2 m. Releasing detaches and keeps the current velocity. There is no extra jump impulse.
- Released time is free flight under gravity. Waiting is a real control.
- After death or success, Space must be released and pressed again. A key that is already held does not repeat the menu action.
- Keyboard auto-repeat is ignored. Focus loss releases Space and pauses human play. Headless episodes have no focus handling.
- Human timestamps shorter than one physics tick are quantized by `pendulum.mapInputEvents` to a one-tick minimum hold.

The fixed order inside `pendulum.step` is: read the bit, derive edges, resolve READY or grapple or detach, integrate one `dt = 1/120` s step, then resolve contacts.

`config.presentationSpeed` changes how many physics ticks are consumed per displayed frame. It does not change `dt`.
