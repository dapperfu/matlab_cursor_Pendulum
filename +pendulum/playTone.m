function playTone(kind, config)
%PLAYTONE Short tone from the renderer. Playback failure does not affect physics.
    if nargin < 2 || isempty(config) || ~isfield(config, 'enableAudio') || ~config.enableAudio
        return
    end
    try
        rate = 8192;
        count = floor(0.045 * rate);
        time = (0:count - 1) / rate;
        switch string(kind)
            case "attach"
                frequency = 880;
            case "release"
                frequency = 640;
            case "fail"
                frequency = 196;
            case "death"
                frequency = 130;
            case "success"
                frequency = 988;
            otherwise
                return
        end
        envelope = linspace(1, 0, count);
        wave = 0.07 * sin(2 * pi * frequency * time) .* envelope;
        sound(wave, rate);
    catch
    end
end
