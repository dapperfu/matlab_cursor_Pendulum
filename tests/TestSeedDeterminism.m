classdef TestSeedDeterminism < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function seedOneLevelsRepeat(testCase)
            first = strings(1, 5);
            second = strings(1, 5);
            for index = 1:5
                first(index) = pendulum.generateLevel(uint32(1), index).meta.hash;
            end
            order = [5 2 4 1 3];
            for index = order
                second(index) = pendulum.generateLevel(uint32(1), index).meta.hash;
            end
            testCase.verifyEqual(first, second);
            testCase.verifyEqual(numel(unique(first)), 5);
            fixture = fullfile(fileparts(mfilename('fullpath')), 'fixtures', 'seed1_level_hashes.txt');
            expected = splitlines(string(fileread(fixture)));
            expected = expected(strlength(expected) > 0);
            testCase.verifyEqual(first(:), expected(:));
        end

        function globalRngDoesNotChangeTheHash(testCase)
            rng(12345);
            first = pendulum.generateLevel(uint32(1), 2);
            rng(98765);
            second = pendulum.generateLevel(uint32(1), 2);
            testCase.verifyEqual(first.meta.hash, second.meta.hash);
            testCase.verifyTrue(isequaln(first, second));
        end

        function directLevelDoesNotNeedEarlierLevels(testCase)
            late = pendulum.generateLevel(uint32(1), 5);
            early = pendulum.generateLevel(uint32(1), 2);
            lateAgain = pendulum.generateLevel(uint32(1), 5);
            testCase.verifyTrue(isequaln(late, lateAgain));
            testCase.verifyNotEqual(late.meta.hash, early.meta.hash);
        end

        function freshSeedIsRecordedAndReusable(testCase)
            seeds = strings(1, 4);
            values = zeros(1, 4, 'uint32');
            for index = 1:4
                run = pendulum.newRun();
                values(index) = run.seed;
                seeds(index) = run.entropy;
            end
            testCase.verifyGreaterThan(numel(unique(values)), 1);
            level = pendulum.generateLevel(values(1), 1);
            again = pendulum.generateLevel(values(1), 1);
            testCase.verifyTrue(isequaln(level, again));
            testCase.verifyEqual(level.meta.seed, values(1));
        end
    end
end
