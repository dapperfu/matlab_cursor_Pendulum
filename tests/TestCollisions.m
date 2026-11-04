classdef TestCollisions < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProject(~)
            addpath(fileparts(fileparts(mfilename('fullpath'))));
        end
    end

    methods (Test)
        function fastCircleStopsAtAWall(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            query = emptyQuery(config);
            query.solids = struct('id', 1, 'rect', [2.5 -1 2.7 4], 'canLand', false);
            result = pendulum.collisionSweep([0 1], [6 1], [100 0], query);
            testCase.verifyFalse(result.died);
            testCase.verifyLessThan(result.position(1), 2.5);
            testCase.verifyEqual(result.velocity(1), 0, 'AbsTol', 1e-9);
        end

        function softTopBecomesGrounded(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            query = emptyQuery(config);
            query.solids = struct('id', 1, 'rect', [0 -1 4 0], 'canLand', true);
            result = pendulum.collisionSweep([1 2], [1 0.2], [0.4 -3], query);
            testCase.verifyTrue(result.landed);
            testCase.verifyEqual(result.position(2), config.playerRadius, 'AbsTol', 1e-9);
        end

        function fastTopDoesNotCountAsLanding(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            query = emptyQuery(config);
            query.solids = struct('id', 1, 'rect', [0 -1 4 0], 'canLand', true);
            result = pendulum.collisionSweep([1 3], [1 0.1], [0.2 -30], query);
            testCase.verifyTrue(result.hitSolid);
            testCase.verifyFalse(result.landed);
        end

        function spikeBeatsTheGoal(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            query = emptyQuery(config);
            query.hazards = pendulum.makeHazard(1, "spike", "aabb", [3 1], 0, [2.6 0.4 3.4 1.6]);
            query.goalRect = [2.6 0.4 3.4 1.6];
            result = pendulum.collisionSweep([0 1], [4 1], [8 0], query);
            testCase.verifyTrue(result.died);
            testCase.verifyFalse(result.reachedGoal);
            testCase.verifyEqual(result.cause, "spike");
        end

        function deathPlaneEndsTheSweep(testCase)
            config = pendulum.validateConfig(pendulum.defaultConfig());
            query = emptyQuery(config);
            query.deathY = -8;
            result = pendulum.collisionSweep([0 0], [0 -12], [0 -20], query);
            testCase.verifyTrue(result.died);
            testCase.verifyEqual(result.cause, "death_plane");
        end
    end
end

function query = emptyQuery(config)
    query = struct();
    query.config = config;
    query.radius = config.playerRadius;
    query.solids = repmat(struct('id', 0, 'rect', [0 0 0 0], 'canLand', true), 0, 1);
    query.hazards = repmat(pendulum.makeHazard(0, "gear", "circle", [0 0], 0, [0 0 0 0]), 0, 1);
    query.collectibles = repmat(pendulum.makeCollectible(0, [0 0]), 0, 1);
    query.collected = false(0, 1);
    query.goalRect = [50 0 51 1];
    query.goalDirection = "any";
    query.deathY = -30;
end
