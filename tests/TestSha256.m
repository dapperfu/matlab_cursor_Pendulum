classdef TestSha256 < matlab.unittest.TestCase
    %TESTSHA256 NIST vectors for the pure MATLAB SHA-256 used by level identity.

    methods (TestClassSetup)
        function addProject(~)
            rootDir = fileparts(fileparts(mfilename('fullpath')));
            addpath(rootDir);
        end
    end

    methods (Test)
        function emptyMessage(testCase)
            digest = pendulum.sha256Bytes(uint8.empty);
            testCase.verifyEqual(pendulum.bytesToHex(digest), ...
                "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
        end

        function abc(testCase)
            digest = pendulum.sha256Bytes(uint8('abc'));
            testCase.verifyEqual(pendulum.bytesToHex(digest), ...
                "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
        end

        function twoBlocks(testCase)
            text = 'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq';
            digest = pendulum.sha256Bytes(uint8(text));
            testCase.verifyEqual(pendulum.bytesToHex(digest), ...
                "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1");
        end
    end
end
