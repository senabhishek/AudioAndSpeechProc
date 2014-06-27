clc;
clear all;
close all;

%% Read input noise/sound files and get user input

% Default Default Inputs
[clean, FsC, nbitsC, readinfoC] =  wavread('../audio/clean.wav');
%[noise, FsN, nbitsN, readinfoN] =  wavread('../audio/noise1.wav');
[noise, FsN, nbitsN, readinfoN] =  wavread('../audio/intersection_soundjay.wav');

noisy = clean+noise(1:size(clean,1));
PSDEstimation = 0;
noisePSDEstAlg = 1;
speechPSDEstAlg = 0;
playFinalOutputFile = 1;
saveOutputFile = 1;
outputFileName = 'output';

disp('=====================================================================');
%in = input('Use default settings? (No - 0, Yes - 1): ');
in=1;
if (in == 1) 
    % Print default info
    disp('Input Noise: White Noise');
    disp('Noise PSD Estimation Algorithm: MS');
    disp('=====================================================================');    
else
    % Load file info
    disp('=====================================================================');
    in = input('Pick an input noise .wav file (White Noise - 0, Intersection - 1): ');
    if (in == 0)
        [noise, FsN, nbitsN, readinfoN] =  audioread('../audio/intersection_soundjay.wav');
        noisy = clean+noise(1:size(clean,1));
    end

    % Input algorithms
    disp('=====================================================================');
    PSDEstimation = input('Noise or Speech PSD Estimation (Noise - 0, Speech - 1, Both - 2): ');
    disp('=====================================================================');
    switch PSDEstimation
        case 0
            disp('=====================================================================');
            noisePSDEstAlg = input('Pick a Noise PSD Estimation Algorithm (MS - 0, SPP - 1): ');
        case 1
            disp('=====================================================================');
            speechPSDEstAlg = input('Pick a Speech PSD Estimation Algorithm (Directed Decision - 0): ');
        case 2
            disp('=====================================================================');
            noisePSDEstAlg = input('Pick a Noise PSD Estimation Algorithm (MS - 0, SPP - 1): ');
            disp('=====================================================================');
            speechPSDEstAlg = input('Pick a Speech PSD Estimation Algorithm (Directed Decision - 0): ');
    end
    
    % Playback files
    disp('=====================================================================');                          
    playInputFile = input('Play Clean Audio File? (No - 0, Yes - 1): ');
    if (playInputFile == 1)
        sound(clean, FsC);
    end
    
    disp('=====================================================================');
    playInputFile = input('Play Noise Audio File? (No - 0, Yes - 1): ');
    if (playInputFile == 1)
        sound(noise, FsC);
    end
    
    disp('=====================================================================');
    playInputFile = input('Play Noisy Audio File? (No - 0, Yes - 1): ');
    if (playInputFile == 1)
        sound(noisy, FsC);
    end  
    
    disp('=====================================================================');
    playFinalOutputFile = input('Play Output File? (No - 0, Yes - 1): ');
    disp('=====================================================================');    
    
    saveOutputFile = input('Save output as a .wav file? (No - 0, Yes - 1): ');
    if (saveOutputFile == 1)
        outputFileName = input('Please enter a valid output filename: ', 's');
        disp('=====================================================================');            
    end    
end


%% Window & Framing
disp('Performing windowing and framing of noisy input ...');
[numFrames, frameLength, noisyDft, noisyPSD, xsize] = windowAndFrame(noisy, FsN);

%% Noise PSD Estimation
if ((PSDEstimation == 0) || (PSDEstimation == 2))
    disp('Noise PSD Estimation ...');
    switch noisePSDEstAlg
        case 0
            % MS
            estimatedNoisePower = estNoisePowerMS(numFrames, frameLength, noisyPSD);
        case 1
            % SPP
            estimatedNoisePower = noiseEstSPP(noisy);
    end
end

%% Speech PSD Estimation
if ((PSDEstimation == 1) || (PSDEstimation == 2))
    disp('Speech PSD Estimation ...');
    switch speechPSDEstAlg
        case 1
            % Directed Decision
            estimatedSpeechPower = speechEStDD(numFrames, frameLength, noisyPSD);
            estimatedNoisePower = noisyPSD - estimatedSpeechPower;
    end
end

%% Gain Function & Application on Spectral Components
disp('Computing Gain & Applying to Spectral Components ...');
[gain, estimate] = calculateGain(estimatedNoisePower, noisyPSD, noisyDft);

%% IFFT and Overlap & Add
disp('IFFT & Reconstruction of Speech Frames ...');
finalOutputEstimate = ifftAndOverlapAdd(numFrames, estimate, frameLength, xsize, size(noisyPSD));

%% Play Output Sound
if (playFinalOutputFile == 1)
    disp('Playing reconstructed audio file ...');    
    sound(finalOutputEstimate, FsN);
end

%% Create .wav file from output
if (saveOutputFile == 1)
    disp('Saving file ...');    
    outputFileName = strcat(outputFileName, '.wav');
    audiowrite(outputFileName, finalOutputEstimate, FsN);
    outputFilePath = strcat(pwd, '/');
    outputFileName = strcat(outputFilePath, outputFileName);    
    disp('=====================================================================');
    disp('Output .wav file save to this location:');
    disp(outputFileName);
    disp('=====================================================================');
end
