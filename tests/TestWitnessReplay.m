classdef TestWitnessReplay < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function manualWitnessWins(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            [won, verification] = pendulum.verifyWitness(level, config);
            testCase.verifyTrue(won);
            testCase.verifyEqual(verification.outcome, "success");
            testCase.verifyGreaterThan(verification.finalTick, 1);
        end
    end
end
