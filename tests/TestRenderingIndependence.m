classdef TestRenderingIndependence < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function drawingDoesNotChangePhysics(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            config.enableAudio = false;
            config.showWitness = false;
            level = pendulum.generateLevel(uint32(1), 1, config);
            [before, ~] = pendulum.simulate(level, level.witness.actions, config);
            figureHandle = uifigure('Visible', 'off', 'Position', [0 0 640 360]);
            cleanup = onCleanup(@() closeIfOpen(figureHandle));
            axesHandle = uiaxes(figureHandle, 'Position', [0 0 640 360]);
            state = pendulum.reset(level, config);
            [state, ~, ~, ~, ~, ~] = pendulum.step(state, uint8(1), config);
            handles = pendulum.renderLevel(axesHandle, level, config);
            pendulum.renderFrame(handles, state, config);
            drawnow;
            [after, ~] = pendulum.simulate(level, level.witness.actions, config);
            testCase.verifyEqual(before.position, after.position);
            rng(3);
            whileOpen = pendulum.generateLevel(uint32(1), 1, config).meta.hash;
            testCase.verifyEqual(whileOpen, level.meta.hash);
        end

        function cameraDependsOnlyOnState(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            level = pendulum.fixtureSwing();
            state = pendulum.reset(level, config);
            first = pendulum.cameraState(state, config);
            second = pendulum.cameraState(state, config);
            testCase.verifyEqual(first.xlim, second.xlim);
            testCase.verifyEqual(first.ylim, second.ylim);
        end
    end
end

function closeIfOpen(figureHandle)
    if isvalid(figureHandle)
        close(figureHandle);
    end
end
