function input = blankKeys()
%BLANKKEYS Keyboard latch for the human client. Edges come from this latch, not auto-repeat.
    input = struct('spaceHeld', false, 'downCount', 0, 'upCount', 0, 'repeatIgnored', 0);
end
