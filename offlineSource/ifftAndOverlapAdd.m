function [finalOutputEstimate] = ifftAndOverlapAdd(numFrames, estimate, frameLength, xsize, noisyPerSize)
    finalOutputEstimate = zeros(noisyPerSize);
    
    for i=1:numFrames
       temp = ifft(estimate(:,i), frameLength);
       finalOutputEstimate(:,i) = finalOutputEstimate(:,i) + temp(1:xsize);
       if(i ~= numFrames)
           finalOutputEstimate(:,i+1) = temp(xsize-1:end); 
       end
    end
    
    finalOutputEstimate = real(finalOutputEstimate(:));
end

