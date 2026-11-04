function summaries = simulateBatch(level, actions, config, count)
%SIMULATEBATCH Independent repeats of one action vector. Workers are not required.
    if nargin < 4
        count = 1;
    end
    if nargin < 3 || isempty(config)
        config = pendulum.defaultConfig();
    end
    summaries = cell(count, 1);
    for index = 1:count
        [~, summaries{index}] = pendulum.simulate(level, actions, config);
    end
end
