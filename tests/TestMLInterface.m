classdef TestMLInterface < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function observationHidesTheWitness(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            state = pendulum.reset(level, config);
            full = pendulum.observe(state, config);
            state.level.witness.actions(:) = uint8(0);
            hidden = pendulum.observe(state, config);
            testCase.verifyEqual(full, hidden);
            partialConfig = config;
            partialConfig.observationMode = "partial";
            partial = pendulum.observe(state, partialConfig);
            testCase.verifyLessThan(numel(partial), numel(full));
            state = pendulum.reset(level, config);
            [state, ~, ~, ~, ~, ~] = pendulum.step(state, uint8(0), config);
            later = pendulum.observe(state, config);
            testCase.verifyEqual(numel(later), numel(full));
        end

        function rewardComponentsAreSeparate(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            state = pendulum.reset(level, config);
            [~, ~, ~, ~, ~, info] = pendulum.step(state, uint8(0), config);
            testCase.verifyEqual(info.rewardComponents.step, -config.stepCost);
            testCase.verifyEqual(info.rewardComponents.goal, 0);
        end

        function batchRepeatsMatch(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            summaries = pendulum.simulateBatch(level, level.witness.actions, config, 2);
            testCase.verifyEqual(summaries{1}.success, summaries{2}.success);
            testCase.verifyEqual(summaries{1}.finalTick, summaries{2}.finalTick);
            testCase.verifyTrue(summaries{1}.success);
        end

        function macrosUseTheSameStepEngine(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            actions = pendulum.expandMacros([8 5], 20);
            testCase.verifyEqual(actions(1), uint8(1));
            testCase.verifyEqual(actions(2), uint8(0));
            testCase.verifyEqual(sum(actions(3:10)), 8);
            level = pendulum.fixtureSwing();
            [~, summary] = pendulum.simulate(level, actions, config);
            testCase.verifyNotEmpty(summary.outcome);
        end

        function replayRejectsADifferentWorld(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            [~, summary] = pendulum.simulate(level, level.witness.actions, config);
            replayData = pendulum.serializeReplay(level, level.witness.actions, summary);
            [trace, played] = pendulum.replay(level, replayData, config);
            testCase.verifyTrue(played.success);
            testCase.verifyEqual(size(trace.position, 1), played.finalTick);
            other = replayData;
            other.hash = "deadbeef";
            testCase.verifyError(@() pendulum.replay(level, other, config), 'pendulum:ReplayMismatch');
        end
    end
end
