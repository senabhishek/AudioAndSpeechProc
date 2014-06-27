function [estNoisePow] = noiseEstSPP(noisy, Fs)
    % Initializations
    sppMean  = 0.5;
    alphaSppMean = 0.9999;
    alphaPow = 0.8;
    
    % A priori probability when speech is present
    aprProb = 0.5; 
    % Fixing 15dB as the a priori SNR (optimum value obtained heuristically)
    aprSNR      = 10.^(15./10);
    % Assuming a few initial frames are noise only
    initNoiseFrames = 3;
    % Frame size is take as 512
    frameSize   = 512;  
    % Number of frames
    numFrames = floor(size(noisy,1)/(frameSize/2))-1; 
    % Frequency bin size
    binSize = frameSize/2+1;
    % Estimated noise power
    estNoisePow = zeros(binSize,numFrames);
    % Window function in use
    hanWin  = Modhanning(frameSize);
    % Forced a priori SPP threshold
    probH1 = 0.99;
    
   % Initilization of estimated noise assuming only noise is there for 
   % initNoiseFrames initial frames
    initNoiseEst = zeros(frameSize,initNoiseFrames);
    
    for i=1:initNoiseFrames
        frame = hanWin.*noisy((i-1)*frameSize/2+1:(i-1)*frameSize/2+frameSize);
        initNoiseEst(:,i) = fft(frame,frameSize);
    end
    
    % Averaging initNoiseFrames noise frames
    estNoisePow(:,1) = mean(initNoiseEst(1:binSize,:).*conj(initNoiseEst(1:binSize,:)),2);
    [numFrames, frameSize, winDft] = windowAndFrame(noisy);

    for i=2:numFrames
        %finding the noise periodogram
        noisyPSD = winDft(:,i).*conj(winDft(:,i));
        % a posteriori SNR based on old noise power estimate
        aPostSNR = noisyPSD./(estNoisePow(:,i-1));

        % Noise power estimation
        GLR = (aprProb./(1-aprProb)).*exp(min(log(1./(1+aprSNR)) + aprSNR./(1+aprSNR).*aPostSNR,100));
        PH1 = GLR./(1+GLR);
        sppMean = alphaSppMean*sppMean + (1-alphaSppMean)*PH1;
        PH1(sppMean>probH1) = min(PH1(sppMean>probH1), probH1);                    
        estimate = PH1.*estNoisePow(:,i-1) + (1-PH1).*noisyPSD ;
        estNoisePow(:,i) = alphaPow*estNoisePow(:, i-1) + (1-alphaPow)*estimate;
    end