function seed = deriveSeed(masterSeed, levelIndex, streamName, version)
%DERIVESEED Little-endian uint32 taken from the first four SHA-256 bytes.
    text = sprintf('level:master=%u:index=%d:stream=%s:v=%s', ...
        uint32(masterSeed), levelIndex, char(string(streamName)), char(string(version)));
    digest = pendulum.sha256Bytes(uint8(unicode2native(text, 'UTF-8')));
    seed = uint32(digest(1)) + bitshift(uint32(digest(2)), 8) + ...
        bitshift(uint32(digest(3)), 16) + bitshift(uint32(digest(4)), 24);
end
