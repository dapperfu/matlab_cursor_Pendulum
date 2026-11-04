function demoHumanPlay()
%DEMOHUMANPLAY Open the interactive game. Space begins, grapples, retries, and advances.
    addpath(fileparts(fileparts(mfilename('fullpath'))));
    pendulum.runGame();
end
