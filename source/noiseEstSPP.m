function [estNoisePow] = noiseEstSPP(noisy)
%% 
frameSize   = 512;  % frame size is take as 512
numFrames = floor(size(noisy,1)/(frameSize/2))-1; % number of frames
binSize = frameSize/2+1;
hanWin  = hanning(frameSize,'periodic'); %analysis window

%% allocate some memory
estNoisePow = zeros(binSize,numFrames);

%% initialize
noisePow = init_noise_tracker_ideal_vad(noisy,frameSize,frameSize,frameSize/2, hanWin); % This function computes the initial noise PSD estimate. It is assumed that the first 5 time-frames are noise-only.
estNoisePow(:,1)=noisePow;

sppMean  = 0.5;
alphaSppMean = 0.9999;
alphaPow = 0.8;
aprProb = 0.5; % a priori probability when speech is present:
% Fixing 15dB as the a priori SNR (optimum value obtained heuristically)
aprSNR      = 10.^(15./10);

for i = 1:numFrames
    % windowing the given input signal
    windowedFrame   = hanWin.*noisy((i-1)*(frameSize/2)+1:(i-1)*(frameSize/2)+frameSize);
    % taking 512 point DFT
    winDft = fft(windowedFrame,frameSize); 
    % taking only 257 values since other side is a replica
    winDft = winDft(1:binSize); 
	%finding the noise periodogram
    noisyPer = winDft.*conj(winDft);
    
    aPostSNR =  noisyPer./(noisePow);% a posteriori SNR based on old noise power estimate


    %% noise power estimation
	GLR     = (aprProb./(1-aprProb)) .* exp(min(log(1./(1+aprSNR)) + aprSNR./(1+aprSNR).*aPostSNR,200));
	PH1     = GLR./(1+GLR); % a posteriori speech presence probability

	sppMean  = alphaSppMean * sppMean + (1-alphaSppMean) * PH1;
	phInd = sppMean > 0.99;                                  
	PH1(phInd) = min(PH1(phInd),0.99);                    
	estimate =  PH1 .* noisePow + (1-PH1) .* noisyPer ; % noisyPer is obtained from DFT of windowed data over frame length -> (1) EQN (22)
	noisePow = alphaPow *noisePow+(1-alphaPow)*estimate;                                                                        % EQN (7)
        
	estNoisePow(:,i) = noisePow;
end
return





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function   noise_psd_init =init_noise_tracker_ideal_vad(noisy,fr_size,fft_size,hop,sq_hann_window)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%This m-file computes an initial noise PSD estimate by means of a
%%%%Bartlett estimate.
%%%%Input parameters:   noisy:          noisy signal
%%%%                    fr_size:        frame size
%%%%                    fft_size:       fft size
%%%%                    hop:            hop size of frame
%%%%                    sq_hann_window: analysis window
%%%%Output parameters:  noise_psd_init: initial noise PSD estimate
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%Author: Richard C. Hendriks, 15/4/2010
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
 
for I=1:5
    noisy_frame=sq_hann_window.*noisy((I-1)*hop+1:(I-1)*hop+fr_size);
    noisy_dft_frame_matrix(:,I)=fft(noisy_frame,fft_size);
end
noise_psd_init=mean(abs(noisy_dft_frame_matrix(1:fr_size/2+1,1:end)).^2,2);%%%compute the initialisation of the noise tracking algorithms.
return


% EOF
