function mss_mmse_spzc_snru(filename, outfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  MSS-MMSE-SPZC-SNRU: Minimum mean square error estimator of magnitude squared 
%  spectrum using SNR uncertainty
% 
% Input: 
%
%   filename:   the input corrupted speech file  
%   outfile:    the output enhanced speech file
%
%   Example:
%
%   mss_mmse_snru('sp28_babble_snr10.wav','out.wav');
%
%
%   Yang Lu 
%   The University of Texas at Dallas
%   Sept 2011
%
%   Reference:
%   Lu, Y. and Loizou, P. (2011). "Estimators of The Magnitude-Squared
%   Spectrum and Methods for Incorporating SNR Uncertainty," IEEE Trans. 
%   Audio, Speech, Language Processing,19(5), 1123-1137
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
   fprintf('Usage: mmse_snru(''[filename]'' ''[outfile]'' \n\n');
   return;
end

method = 'mcra';


[x  Srate nbits] = wavread(filename);


%% 
len = floor(20*Srate/1000); 
if rem(len,2)==1, len=len+1; end;
PERC = 50; 
len1 = floor(len*PERC/100);
len2 = len-len1; 
win = hanning(len); 
U = norm(win);


nFFT       = len;
nFFT2      = len/2;
noise_mean = zeros(nFFT,1);
j          = 1;
NIS        = 8;
for k = 1:NIS
    noise_mean = noise_mean+abs(fft(win.*x(j:j+len-1),nFFT)/U);
    j = j+len;
end
noise_mu   = noise_mean/NIS;
noise_mu2  = noise_mu.^2;

  
k          = 1;
x_old      = zeros(len1,1);
Nframes    = floor(length(x)/len2)-1;
xfinal     = zeros(Nframes*len2,1);



ksi         = 0;
ksi_old     = zeros(len,1);

%%
for n = 1:Nframes 
    insign  = win.*x(k:k+len-1);
    spec    = fft(insign,nFFT)/U;   
    sig     = abs(spec); 
    sig2    = sig.^2;
   
    sig2 = sig2(1:nFFT/2+1);
    noise_mu2 = noise_mu2(1:nFFT/2+1);

%% 
    if 1
        noise_mu2 = [noise_mu2;noise_mu2(end-1:-1:2)];
        sig2 = [sig2;sig2(end-1:-1:2)];
        if n<NIS
            parameters = initialise_parameters_book(noise_mu2,Srate,method);
        else
            if 1
                parameters = noise_estimation_book(sig2, method, parameters);
                noise_mu2 = parameters.noise_ps;
            end
        end
        noise_mu2 = noise_mu2(1:nFFT/2+1);
        sig2 = sig2(1:nFFT/2+1);
    end  

  
%% 
    if 1
        gammak  = min(sig2./noise_mu2,1000); 
        aa = 0.97;
        if n==1
            ksi = 0 + (1-aa)*max(gammak-1,0);
        else   
            ksi = aa*Xk_prev./noise_mu2_old + (1-aa)*max(gammak-1,0);   
        end
        lambdaX = ksi.*noise_mu2;
    end
    
    gammak_old = gammak;
    sig2_old = sig2;
    noise_mu2_old = noise_mu2;
    
    hw = zeros(size(ksi))+1;
    
    vu = zeros(size(ksi));
    
    if 1
        ksi = max(ksi,0.0025);
        
        delta = 0.000002;
            
        idx = find(abs(ksi-1)>delta);
        vu(idx) = (1-ksi(idx))./ksi(idx).*gammak(idx);
        hw(idx) = 1./vu(idx) - 1./(exp(vu(idx))-1);
           
        idx = find(abs(ksi-1)<=delta);
        hw(idx) = 0.5;
            
        hw = max(hw, 10^(-35/10));
        hw = min(hw, 1);
            
        hw = hw.^(0.5); 
    end


    if 1 
       snru = ksi./(ksi+0.01);
    end
    
    hw = hw.*snru + 0.0398*(1-snru); % 0.0398: -28 dB
    
    hw = max(hw, sqrt(10^(-24/10)));
    
    enh_sig = sig(1:nFFT/2+1).*hw;
    
%%    
    
    if 1
        Xk_prev = enh_sig.^2;
    end
    
%%    
    hw = [hw(:);hw(end-1:-1:2)];
    
    Xk_prev = Xk_prev(1:nFFT/2+1);
      
    xi_w = ifft(hw .* spec); 
	xi_w = real(xi_w)*U;
	
    %
    xfinal(k:k+ len2-1) = x_old + xi_w(1:len1);
	x_old = xi_w(len1+ 1: len);
   

    k = k + len2;
    
    
end


%% ========================================================================================
wavwrite(xfinal,Srate,16,outfile);