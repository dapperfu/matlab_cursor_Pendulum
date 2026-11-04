function motion = staticMotion()
%STATICMOTION Motion parameters for a body that does not move.
    motion = struct('type', "static", 'amplitude', 0, 'period', 240, 'phase', 0, 'axis', "x");
end
