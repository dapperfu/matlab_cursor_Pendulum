function input = onKeyDown(input, keyName)
%ONKEYDOWN Record Space without treating keyboard auto-repeat as a new edge.
    if string(keyName) ~= "space"
        return
    end
    if input.spaceHeld
        input.repeatIgnored = input.repeatIgnored + 1;
        return
    end
    input.spaceHeld = true;
    input.downCount = input.downCount + 1;
end
