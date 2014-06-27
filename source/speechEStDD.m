function [XlEst] = speechEStDD(numFrames, frameLength, noisyPSD)
    % Constants as per the reference paper
    frameLength = frameLength/2+1;
    epsilonMinDb = -25; % -25dB arbitrarily taken value as initial a priori SNR
    epsilonMin = 10.^(epsilonMinDb./10);
    epsilonEst = ones(frameLength, 1) * epsilonMin;
    alpha = 0.9;
    lambdaDlEst = ones(frameLength, 1);
    lambdaXlEst = ones(frameLength, 1);
    gammaL = ones(frameLength, 1);
    XlEst = zeros(frameLength, numFrames);
    A = zeros(frameLength, 1);
    lambdaMin = min(var(noisyPSD(:,:)));
    
    for i=2:numFrames        
        % Computing a priori SNR - epsilonEst
        epsilonEst(:,1) = max(((1 - alpha)*epsilonEst(:,1) + ...
                                alpha*(A(:,1).^2)./lambdaDlEst(:,1)), ...
                                epsilonMin);
        
        % Compute speech spectral variance - lambdaXlEst
        lambdaXlEst(:,1) = max(((1 - alpha)*lambdaXlEst(:,1)), epsilonMin);
        lambdaXlEst(:,1) = max(((1 - alpha)*lambdaXlEst(:,1) + ...
                                alpha*A(:,1).^2), ...
                                lambdaMin);        
        % Compute noise spectral variance - lambdaDlEst
        lambdaDlEst(:,1) = lambdaXlEst(:,1)./epsilonEst(:,1);
        
        % Compute the a posteriori SNR
        gammaL(:,1) = noisyPSD(:,i)./lambdaDlEst(:,1);
        
        % Compute speech frame estimate
        XlEst(:,i) = (gammaL(:,1)./(1 + gammaL(:,1)).*noisyPSD(:,i));
    end
end
