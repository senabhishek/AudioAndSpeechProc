function [numFrames, frameLength, noisyDft, noisyFrames, xsize] = windowAndFrame(noisy, FsN)
    % Fixed values
    frameLength = 32e-3 * FsN;      % frame length
    frameStart = frameLength / 2;   % frame start
    numFrames = floor(length(noisy)/frameStart) - 1; % total number of frames
    modHanWin = Modhanning(frameLength);  % Modified Hanning Window
    xsize = size(zeros(frameLength/2+1, numFrames), 1);
    noisyFrames = zeros(xsize, numFrames);
    noisyDft = zeros(xsize, numFrames);

    % Finding out the PSD of noisy input signal
    for i=1:numFrames
        indices       =  (i-1)*frameStart+1:(i-1)*frameStart+frameLength;
        noisy_frame   =  modHanWin.*noisy(indices);
        noisyDftFrame =  fft(noisy_frame,frameLength);
        noisyDftFrame =  noisyDftFrame(1:xsize);
        noisyDft(:,i) =  noisyDftFrame;
        noisyFrames(:,i) =  transpose(noisyDftFrame.*conj(noisyDftFrame));    
    end
end

