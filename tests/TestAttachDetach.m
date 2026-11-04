classdef TestAttachDetach < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function holdChangesLengthAndReleaseChangesPlace(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = openGoal(config);
            shortHold = coast(level, config, 12);
            longHold = coast(level, config, 40);
            testCase.verifyLessThan(longHold.length, shortHold.length - 0.05);
            testCase.verifyGreaterThan(norm(longHold.position - shortHold.position), 0.05);
        end

        function tieBreakUsesLowestId(testCase)
            config = pendulum.defaultConfig();
            positions = [3 4; 3 4];
            ids = [2; 1];
            [chosen, ~] = pendulum.selectAnchor([0 0], [1 0], positions, ids, zeros(0, 4), config);
            testCase.verifyEqual(chosen, 1);
        end

        function wallBlocksTheHook(testCase)
            config = pendulum.defaultConfig();
            [chosen, ~] = pendulum.selectAnchor([0 0], [1 0], [5 0], 1, [2 -1 3 1], config);
            testCase.verifyEqual(chosen, 0);
        end

        function captureDropsRadialSpeed(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = openGoal(config);
            state = pendulum.reset(level, config);
            actions = zeros(150, 1, 'uint8');
            actions(1) = 1;
            actions(140:150) = 1;
            for index = 1:150
                previous = state;
                [state, ~, ~, ~, ~, ~] = pendulum.step(state, actions(index), config);
                if state.mode == "ATTACHED" && previous.mode ~= "ATTACHED"
                    anchor = level.anchors(1).position;
                    radial = state.player.position - anchor;
                    radial = radial / norm(radial);
                    radialSpeed = state.player.velocity * radial.';
                    testCase.verifyLessThan(abs(radialSpeed), config.winchSpeed + 0.05);
                    return
                end
            end
            testCase.verifyFail('The fixture did not attach.');
        end
    end
end

function level = openGoal(config)
    level = pendulum.fixtureSwing();
    level.goal.rect = [1e5 0 1e5+1 1];
    level.physics = pendulum.physicsBlock(config);
end

function sample = coast(level, config, holdTicks)
    state = pendulum.reset(level, config);
    actions = zeros(210, 1, 'uint8');
    actions(1) = 1;
    actions(140:140 + holdTicks - 1) = 1;
    lengths = zeros(210, 1);
    for index = 1:210
        [state, ~, ~, ~, ~, ~] = pendulum.step(state, actions(index), config);
        lengths(index) = state.rope.length;
    end
    sample.position = state.player.position;
    sample.length = min(lengths(lengths > 0));
end
