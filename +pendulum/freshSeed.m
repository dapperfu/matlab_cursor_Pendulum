function [seed, source] = freshSeed()
%FRESHSEED Entropy-derived uint32. Explicit seeds never come from this helper.
    bytes = zeros(1, 4, 'uint8');
    source = "counter";
    if usejava('jvm')
        try
            generator = java.security.SecureRandom();
            raw = generator.generateSeed(4);
            bytes = uint8(mod(double(raw(:).'), 256));
            source = "java.security.SecureRandom";
        catch
            bytes = zeros(1, 4, 'uint8');
        end
    end
    if source == "counter"
        try
            generator = System.Security.Cryptography.RandomNumberGenerator.Create();
            raw = uint8(generator.GetBytes(4));
            bytes = reshape(raw, 1, 4);
            source = "dotnet.RandomNumberGenerator";
        catch
            bytes = zeros(1, 4, 'uint8');
        end
    end
    if all(bytes == 0) && source == "counter"
        source = "timer-counter";
        warning('pendulum:WeakEntropy', ...
            'OS entropy is unavailable. The seed mixes a timer with a local counter.');
        clockBytes = typecast(uint64(floor(posixtime(datetime('now')) * 1e6)), 'uint8');
        counter = readCounter();
        mixed = pendulum.sha256Bytes(uint8([clockBytes(:); typecast(uint32(counter), 'uint8')]));
        bytes = mixed(1:4).';
    end
    seed = uint32(bytes(1)) + bitshift(uint32(bytes(2)), 8) + ...
        bitshift(uint32(bytes(3)), 16) + bitshift(uint32(bytes(4)), 24);
end

function counter = readCounter()
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    filePath = fullfile(rootDir, '.pendulum_seed_counter');
    counter = 1;
    if isfile(filePath)
        loaded = readmatrix(filePath);
        if ~isempty(loaded) && isfinite(loaded(1))
            counter = loaded(1) + 1;
        end
    end
    writematrix(counter, filePath);
end
