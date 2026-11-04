function config = bindConfig(level, config)
%BINDCONFIG Reject a config whose physics constants differ from the level.
    config = pendulum.validateConfig(config);
    names = ["dt", "gravity", "playerRadius", "acquireRange", "minRopeLength", ...
        "winchSpeed", "landingSpeed", "runSpeed"];
    for index = 1:numel(names)
        name = names(index);
        if abs(double(level.physics.(name)) - double(config.(name))) > 1e-9
            error('pendulum:ConfigMismatch', 'Config field %s does not match the level.', name);
        end
    end
    if string(level.physics.integratorId) ~= config.integratorId
        error('pendulum:ConfigMismatch', 'Integrator id does not match the level.');
    end
end
