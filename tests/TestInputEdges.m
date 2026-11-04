classdef TestInputEdges < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function onePressIsOneAttempt(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            state = pendulum.reset(level, config);
            actions = level.witness.actions;
            for index = 1:numel(actions)
                [state, ~, ~, ~, ~, info] = pendulum.step(state, actions(index), config);
                if state.finished
                    break
                end
            end
            testCase.verifyEqual(info.attachAttempts, 1);
            testCase.verifyGreaterThanOrEqual(state.stats.detachCount, 1);
        end

        function holdDoesNotCreateAnotherEdge(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            state = pendulum.reset(level, config);
            [state, ~, ~, ~, ~, ~] = pendulum.step(state, uint8(1), config);
            attempts = state.stats.attachAttempts;
            for index = 1:30
                [state, ~, ~, ~, ~, ~] = pendulum.step(state, uint8(1), config);
            end
            testCase.verifyEqual(state.stats.attachAttempts, attempts);
            testCase.verifyEqual(state.mode, "GROUNDED");
        end

        function replayMatches(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            [first, ~] = pendulum.simulate(level, level.witness.actions, config);
            [second, ~] = pendulum.simulate(level, level.witness.actions, config);
            testCase.verifyEqual(first.position, second.position);
        end

        function repeatKeyIsIgnored(testCase)
            input = pendulum.blankKeys();
            input = pendulum.onKeyDown(input, "space");
            input = pendulum.onKeyDown(input, "space");
            testCase.verifyEqual(input.downCount, 1);
            testCase.verifyEqual(input.repeatIgnored, 1);
            input = pendulum.onKeyUp(input, "space");
            testCase.verifyFalse(input.spaceHeld);
        end

        function shortTapQuantizesToOneTick(testCase)
            dt = 1/120;
            actions = pendulum.mapInputEvents(0, dt / 2, dt, 10);
            testCase.verifyEqual(sum(actions), 1);
        end

        function terminalStepErrors(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            state = pendulum.reset(level, config);
            for index = 1:numel(level.witness.actions)
                [state, ~, ~, ~, ~, ~] = pendulum.step(state, level.witness.actions(index), config);
                if state.finished
                    break
                end
            end
            testCase.verifyTrue(state.finished);
            testCase.verifyError(@() pendulum.step(state, uint8(0), config), 'pendulum:TerminalState');
        end
    end
end
