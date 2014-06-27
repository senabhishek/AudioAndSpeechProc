function [numFrames, frameLength, noisyDft, noisyPSD, xsize] = windowAndFrame(noisy)
    % Fixed values
    frameLength = 512;
    frameStart = frameLength/2;
    numFrames = floor(length(noisy)/frameStart)-1;
    modHanWin = Modhanning(frameLength);
    xsize = size(zeros(frameLength/2+1, numFrames), 1);
    noisyPSD = zeros(xsize, numFrames);
    noisyDft = zeros(xsize, numFrames);

    % Finding out the PSD of noisy input signal
    for i=1:numFrames
        indices       =  (i-1)*frameStart+1:(i-1)*frameStart+frameLength;
        noisy_frame   =  modHanWin.*noisy(indices);
        noisyDftFrame =  fft(noisy_frame,frameLength);
        noisyDftFrame =  noisyDftFrame(1:xsize);
        noisyDft(:,i) =  noisyDftFrame;
        noisyPSD(:,i) =  transpose(noisyDftFrame.*conj(noisyDftFrame));    
    end
end

