function [estimatedNoisePower] = estNoisePowerMS(numFrames, frameLength, noisyPSD)
    alpha = 0.75;
    windowLen = 10;    % Window length to compute Pmin over 10 frames i.e.
                       % 10 * frameLength = 10*512 = 5120 samples
                       % FsN = 16000
                       % Therefore, window every 320 ms
    
    P = zeros(frameLength/2+1, numFrames);    
    Bmin = zeros(frameLength/2+1, numFrames);
    
    % Compute Recursive Smoothed Periodograjjkm
    for i=2:numFrames
       P(:,i) = alpha*P(:,i-1) + (1-alpha)*noisyPSD(:,i);
    end

    Pmin = P;    
    % Computing Pmin for across all frames for a window length of 5 frames
    % Compute Bias Error Correction per frame for window length
    for i=1:numFrames-windowLen
        for j=1:frameLength/2+1
            Pmin(j,i) = min(P(j,i:i+windowLen-1));
            Bmin(j,i) = 1/mean(Pmin(j,i:i+windowLen-1));
        end 
    end
       
    % Compute Unbiased Noise Estimate
    estimatedNoisePower = Pmin./Bmin;
end

