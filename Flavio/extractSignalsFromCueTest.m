classdef extractSignalsFromCueTest < matlab.unittest.TestCase
    
    methods (Test)
        function testCUEH(testCase)
            
            signals = [[1:1000];[1:2:2000]]';
            
            CUEH = hex2dec('305');
            CUEF = hex2dec('303');
            
            bigM = [[50 50 300 300 50];[10 50 100 400 800];[0 0 CUEH 0 0]]';
            
            [actSolution1,actSolution2] = extractSignalsFromCue(signals,bigM,CUEH);
            expSolution1 = [[100:700];[199:2:1399]]';
            expSolution2 = 1;
            testCase.verifyEqual(actSolution1,expSolution1);
            testCase.verifyEqual(actSolution2,expSolution2);
        end
    end
    
end 