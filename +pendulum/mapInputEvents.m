function actions = mapInputEvents(downTimes, upTimes, dt, maxTicks)
%MAPINPUTEVENTS Quantize second-timestamps onto ticks. Holds shorter than dt become one tick.
    actions = zeros(maxTicks, 1, 'uint8');
    for index = 1:numel(downTimes)
        downTick = min(maxTicks, max(1, floor(double(downTimes(index)) / dt) + 1));
        if index <= numel(upTimes)
            upTick = floor(double(upTimes(index)) / dt) + 1;
        else
            upTick = maxTicks + 1;
        end
        upTick = max(upTick, downTick + 1);
        last = min(maxTicks, upTick - 1);
        if last >= downTick
            actions(downTick:last) = 1;
        end
    end
end
