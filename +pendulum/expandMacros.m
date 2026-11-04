function actions = expandMacros(macros, maxTicks)
%EXPANDMACROS Turn hold/release pairs into the same tick actions step() uses.
    actions = zeros(maxTicks, 1, 'uint8');
    if maxTicks < 1
        return
    end
    actions(1) = 1;
    index = 3;
    if maxTicks >= 2
        actions(2) = 0;
    end
    for row = 1:size(macros, 1)
        if index > maxTicks
            break
        end
        holdTicks = max(1, round(macros(row, 1)));
        releaseTicks = max(1, round(macros(row, 2)));
        lastHold = min(maxTicks, index + holdTicks - 1);
        actions(index:lastHold) = 1;
        index = lastHold + 1;
        if index > maxTicks
            break
        end
        lastRelease = min(maxTicks, index + releaseTicks - 1);
        actions(index:lastRelease) = 0;
        index = lastRelease + 1;
    end
end
