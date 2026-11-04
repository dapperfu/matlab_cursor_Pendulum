function hash = levelHash(level, scope)
%LEVELHASH SHA-256 of the canonical level bytes.
    if nargin < 2
        scope = "full";
    end
    hash = pendulum.bytesToHex(pendulum.sha256Bytes(pendulum.canonicalizeLevel(level, scope)));
end
