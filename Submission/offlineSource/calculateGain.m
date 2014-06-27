function [gain, estimate] = calculateGain(estimatedNoisePower, noisyPSD, noisyDft)
    % Wiener smoother- gain calculation
    gain              = (1-((estimatedNoisePower.^0.1./(noisyPSD.^0.1))));

    % Application of the gain on spectral components
    estimate             = gain.*(noisyDft);
end

