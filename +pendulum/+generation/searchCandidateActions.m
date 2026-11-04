function [tuples, order] = searchCandidateActions(stream, useStream)
%SEARCHCANDIDATEACTIONS Ordered grapple timings. The list is the search budget.
    delays = [15 30 45 60];
    holds = [25 45 70 55];
    offsets = [1.0 4.8; 1.8 6.0; 1.4 5.2; 2.2 4.4];
    tuples = zeros(64, 4);
    row = 0;
    for delay = delays
        for hold = holds
            for offsetIndex = 1:size(offsets, 1)
                row = row + 1;
                tuples(row, :) = [delay, hold, offsets(offsetIndex, 1), offsets(offsetIndex, 2)];
            end
        end
    end
    if nargin < 2 || useStream
        start = randi(stream, size(tuples, 1));
    else
        start = 1;
    end
    order = circshift((1:size(tuples, 1))', -(start - 1));
end
