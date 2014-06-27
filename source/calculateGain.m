function [gain, estimate] = calculateGain(noisePowMat, noisyPer, noisyDft)
    % Wiener smoother- gain calculation
    gain              = (1-((noisePowMat.^0.1./(noisyPer.^0.1))));
    % %gain              = (1-((noisePowMat./(noisyPer))));

    % Application of the gain on spectral components
    estimate             = gain.*(noisyDft);
end

