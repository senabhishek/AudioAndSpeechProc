function mss_smpr(filename, outfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MSS-SMPR: Soft Masking using a PRiori SNR uncertainty on magnitude
%  squared spectrum
% 
%  Input: 
%
%   filename:   the input corrupted speech file  
%   outfile:    the output enhanced speech file
%
%
%  Example:
%
%  mss_smpr('sp28_babble_snr10.wav','out.wav');
%
%
%  Yang Lu 
%  The University of Texas at Dallas
%  Sept 2011
%
%   Reference:
%   Lu, Y. and Loizou, P. (2011). "Estimators of The Magnitude-Squared
%   Spectrum and Methods for Incorporating SNR Uncertainty," IEEE Trans. 
%   Audio, Speech, Language Processing,19(5), 1123-1137
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
   fprintf('Usage: smpr(''[filename]'' ''[outfile]'' \n\n');
   return;
end

method = 'mcra';

[x  Srate nbits] = wavread(filename);

%%
len = floor(20*Srate/1000); 
if rem(len,2)==1, len=len+1; end;
PERC    = 50; 
len1    = floor(len*PERC/100);
len2    = len-len1; 
win     = hanning(len); 
U       = norm(win);


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
Nframes    = floor(length(x)/len2)-1;
xfinal     = zeros(Nframes*len2,1);
x_old      = zeros(len1,1);


ksi         = 0;
ksi_old     = zeros(len,1);

%%
for n = 1:Nframes 
    insign  = win.*x(k:k+len-1);
    spec    = fft(insign,nFFT)/U;   
    sig     = abs(spec); 
    sig2    = sig.^2;
    sig2    = sig2(1:nFFT/2+1);
    noise_mu2 = noise_mu2(1:nFFT/2+1);

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

  
    if 1
        gammak  = min(sig2./noise_mu2,1000);  
        aa = 0.90;
        if n==1
            ksi = 0 + (1-aa)*max(gammak-1,0);
        else   
            ksi = max(aa*Xk_prev./noise_mu2_old + (1-aa)*(gammak-1), 0.0126);   
        end
        lambdaX = ksi.*noise_mu2;
    end
    
    noise_mu2_old   = noise_mu2;
    
    hw = zeros(size(ksi))+1;
    Gx = hw;
    vu = zeros(size(ksi));
    
    if 1
        ksi = max(ksi,0.0025);
            
        delta = 0.0002;
        theta = 3.162;
        P = ksi./(ksi+theta);
          
        hw = P + (1-P)*0.01;
           
        hw = min(hw, 1);
        hw = hw.^(0.5); 
    end
 
    hw = max(hw, sqrt(10^(-24/10)));
    
    
    if 1
        enh_sig = sig(1:nFFT/2+1).*hw;
    end
%%    
    if 1
        Xk_prev = enh_sig.^2;
    end
    
%%    
    hw = [hw(:);hw(end-1:-1:2)];
    
    Xk_prev = Xk_prev(1:nFFT/2+1);
      
    xi_w = ifft(hw .* spec); 
	xi_w = real(xi_w)*U;
	
    xfinal(k:k+ len2-1) = x_old + xi_w(1:len1);
	x_old = xi_w(len1+ 1: len);
    
    k = k + len2;
    
    
end


wavwrite(xfinal,Srate,16,outfile);