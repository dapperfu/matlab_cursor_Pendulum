function digest = sha256Bytes(message)
%SHA256BYTES SHA-256 digest of uint8 bytes, implemented in base MATLAB.
    if nargin < 1 || isempty(message)
        message = zeros(0, 1, 'uint8');
    end
    message = uint8(message(:));

    persistent roundKeys
    if isempty(roundKeys)
        roundKeys = sha256Constants();
    end

    hash = initialHash();
    padded = padMessage(message);
    for chunkStart = 1:64:numel(padded)
        hash = compress(hash, padded(chunkStart:chunkStart + 63), roundKeys);
    end
    digest = zeros(32, 1, 'uint8');
    for index = 1:8
        digest((index - 1) * 4 + (1:4)) = unpackBigEndian(hash(index));
    end
end

function padded = padMessage(message)
    count = numel(message);
    padZeros = mod(56 - mod(count + 1, 64), 64);
    total = count + 1 + padZeros + 8;
    padded = zeros(total, 1, 'uint8');
    if count > 0
        padded(1:count) = message;
    end
    padded(count + 1) = uint8(128);
    bitLength = uint64(count) * uint64(8);
    for index = 0:7
        padded(total - index) = uint8(bitand(bitLength, uint64(255)));
        bitLength = bitshift(bitLength, -8);
    end
end

function hash = compress(hash, block, roundKeys)
    schedule = zeros(64, 1, 'uint32');
    for index = 1:16
        schedule(index) = packBigEndian(block((index - 1) * 4 + (1:4)));
    end
    for index = 17:64
        small = bitxor(bitxor(rotate(schedule(index - 15), 7), rotate(schedule(index - 15), 18)), ...
            bitshift(schedule(index - 15), -3));
        large = bitxor(bitxor(rotate(schedule(index - 2), 17), rotate(schedule(index - 2), 19)), ...
            bitshift(schedule(index - 2), -10));
        schedule(index) = add32(schedule(index - 16), small, schedule(index - 7), large);
    end

    a = hash(1); b = hash(2); c = hash(3); d = hash(4);
    e = hash(5); f = hash(6); g = hash(7); h = hash(8);
    for index = 1:64
        upper = bitxor(bitxor(rotate(e, 6), rotate(e, 11)), rotate(e, 25));
        choose = bitxor(bitand(e, f), bitand(bitxor(e, uint32(4294967295)), g));
        temp1 = add32(h, upper, choose, roundKeys(index), schedule(index));
        lower = bitxor(bitxor(rotate(a, 2), rotate(a, 13)), rotate(a, 22));
        majority = bitxor(bitxor(bitand(a, b), bitand(a, c)), bitand(b, c));
        temp2 = add32(lower, majority);
        h = g;
        g = f;
        f = e;
        e = add32(d, temp1);
        d = c;
        c = b;
        b = a;
        a = add32(temp1, temp2);
    end
    hash = [add32(hash(1), a); add32(hash(2), b); add32(hash(3), c); add32(hash(4), d); ...
        add32(hash(5), e); add32(hash(6), f); add32(hash(7), g); add32(hash(8), h)];
end

function value = add32(varargin)
    total = 0;
    for index = 1:nargin
        total = total + double(varargin{index});
    end
    value = uint32(mod(total, 4294967296));
end

function rotated = rotate(value, bits)
    rotated = bitor(bitshift(value, -bits), bitshift(value, 32 - bits));
end

function word = packBigEndian(bytes)
    word = bitor(bitor(bitor(bitshift(uint32(bytes(1)), 24), bitshift(uint32(bytes(2)), 16)), ...
        bitshift(uint32(bytes(3)), 8)), uint32(bytes(4)));
end

function bytes = unpackBigEndian(word)
    bytes = zeros(4, 1, 'uint8');
    bytes(1) = uint8(bitshift(word, -24));
    bytes(2) = uint8(bitand(bitshift(word, -16), uint32(255)));
    bytes(3) = uint8(bitand(bitshift(word, -8), uint32(255)));
    bytes(4) = uint8(bitand(word, uint32(255)));
end

function hash = initialHash()
    hash = uint32([ ...
        hex32('6a09e667'); hex32('bb67ae85'); hex32('3c6ef372'); hex32('a54ff53a'); ...
        hex32('510e527f'); hex32('9b05688c'); hex32('1f83d9ab'); hex32('5be0cd19')]);
end

function keys = sha256Constants()
    texts = [ ...
        "428a2f98" "71374491" "b5c0fbcf" "e9b5dba5" "3956c25b" "59f111f1" "923f82a4" "ab1c5ed5" ...
        "d807aa98" "12835b01" "243185be" "550c7dc3" "72be5d74" "80deb1fe" "9bdc06a7" "c19bf174" ...
        "e49b69c1" "efbe4786" "0fc19dc6" "240ca1cc" "2de92c6f" "4a7484aa" "5cb0a9dc" "76f988da" ...
        "983e5152" "a831c66d" "b00327c8" "bf597fc7" "c6e00bf3" "d5a79147" "06ca6351" "14292967" ...
        "27b70a85" "2e1b2138" "4d2c6dfc" "53380d13" "650a7354" "766a0abb" "81c2c92e" "92722c85" ...
        "a2bfe8a1" "a81a664b" "c24b8b70" "c76c51a3" "d192e819" "d6990624" "f40e3585" "106aa070" ...
        "19a4c116" "1e376c08" "2748774c" "34b0bcb5" "391c0cb3" "4ed8aa4a" "5b9cca4f" "682e6ff3" ...
        "748f82ee" "78a5636f" "84c87814" "8cc70208" "90befffa" "a4506ceb" "bef9a3f7" "c67178f2"];
    keys = zeros(64, 1, 'uint32');
    for index = 1:64
        keys(index) = hex32(texts(index));
    end
end

function value = hex32(text)
    value = uint32(hex2dec(char(text)));
end
