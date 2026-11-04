function startup()
%STARTUP Add the Pendulum project root to the MATLAB path.
    rootDir = fileparts(mfilename('fullpath'));
    addpath(rootDir);
end
