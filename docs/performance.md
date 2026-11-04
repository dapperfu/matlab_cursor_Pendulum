# Measured performance

Machine: MATLAB 25.2.0.2998904 (R2025b) on PCWIN64.

- Early gate: 500 / 500 seed-level pairs verified (seeds 1:100, levels 1:5).
- Early mean generate+verify: 0.492 s. Total early wall time is included in the script timer below.
- Late gate: 30 / 30 level-16 worlds verified (seeds 1:30).
- Late mean generate+verify: 0.658 s.
- Headless witness rollout: 2419 steps/s (0.093 s for 225 ticks).
- Offscreen renderFrame: 6.79 ms/frame over 60 frames (147.2 FPS if the machine keeps that pace).
- Script timer: 266.7 s.
