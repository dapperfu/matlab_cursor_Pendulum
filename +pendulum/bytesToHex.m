function text = bytesToHex(bytes)
%BYTESTOHEX Lowercase hexadecimal for a uint8 vector.
    digits = '0123456789abcdef';
    values = double(uint8(bytes(:)));
    chars = repmat(' ', 1, 2 * numel(values));
    for index = 1:numel(values)
        chars(2 * index - 1) = digits(floor(values(index) / 16) + 1);
        chars(2 * index) = digits(mod(values(index), 16) + 1);
    end
    text = string(chars);
end
