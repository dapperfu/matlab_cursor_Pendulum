classdef TestGeneratorSolvability < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function earlyCampaignHasWinningWitnesses(testCase)
            for index = 1:5
                level = pendulum.generateLevel(uint32(1), index);
                [valid, report] = pendulum.validateLevel(level);
                [won, verification] = pendulum.verifyWitness(level);
                testCase.verifyTrue(valid, strjoin(string(report.messages), "; "));
                testCase.verifyTrue(won);
                testCase.verifyTrue(level.meta.verified);
                testCase.verifyNotEmpty(level.witness.actions);
                testCase.verifyGreaterThan(sum(level.witness.actions == 1), 1);
                testCase.verifyGreaterThan(sum(level.witness.actions == 0), 1);
                testCase.verifyEqual(verification.outcome, "success");
            end
        end

        function movingLevelReplays(testCase)
            level = pendulum.generateLevel(uint32(1), 16);
            [won, ~] = pendulum.verifyWitness(level);
            testCase.verifyTrue(won);
            testCase.verifyGreaterThan(level.anchors(1).motion.amplitude, 0);
            testCase.verifyGreaterThan(numel(level.hazards), 0);
        end
    end
end
