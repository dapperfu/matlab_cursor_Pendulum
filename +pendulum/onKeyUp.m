function input = onKeyUp(input, keyName)
%ONKEYUP Clear the Space latch.
    if string(keyName) ~= "space" || ~input.spaceHeld
        return
    end
    input.spaceHeld = false;
    input.upCount = input.upCount + 1;
end
