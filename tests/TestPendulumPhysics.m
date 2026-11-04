classdef TestPendulumPhysics < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function ballisticMatchesClosedForm(testCase)
            config = pendulum.defaultConfig();
            position = [0 10];
            velocity = [1.5 -0.25];
            steps = 50;
            for index = 1:steps
                [position, velocity] = pendulum.updateFreeFlight(position, velocity, config.dt, config.gravity);
            end
            time = steps * config.dt;
            expected = [0 10] + [1.5 -0.25] * time + 0.5 * [0 -config.gravity] * time ^ 2;
            testCase.verifyEqual(position, expected, 'AbsTol', 1e-9);
        end

        function ropeStaysAtItsLength(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            level.goal.rect = [1e5 0 1e5+1 1];
            state = pendulum.reset(level, config);
            actions = zeros(220, 1, 'uint8');
            actions(1) = 1;
            actions(140:190) = 1;
            for index = 1:numel(actions)
                [state, ~, ~, ~, ~, ~] = pendulum.step(state, actions(index), config);
            end
            testCase.verifyEqual(state.mode, "FREE");
            state = pendulum.reset(level, config);
            for index = 1:160
                [state, ~, ~, ~, ~, ~] = pendulum.step(state, actions(index), config);
            end
            testCase.verifyEqual(state.mode, "ATTACHED");
            anchor = level.anchors(1).position;
            gap = hypot(state.player.position(1) - anchor(1), state.player.position(2) - anchor(2));
            testCase.verifyEqual(gap, state.rope.length, 'AbsTol', 1e-8);
            testCase.verifyGreaterThanOrEqual(state.rope.length, config.minRopeLength - 1e-9);
            testCase.verifyTrue(all(isfinite([state.player.position, state.player.velocity, state.rope.omega])));
        end
    end
end
