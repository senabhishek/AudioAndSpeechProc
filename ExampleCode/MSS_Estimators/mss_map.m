function mss_map(filename, outfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  MSS-MAP: Maximum A Posterior Estimator of Magnitude-Squared Spectrum
% 
% Input: 
%
%   filename:   the input corrupted speech file  
%   outfile:    the output enhanced speech file
%
%
%   Example:
%
%   mss_map('sp28_babble_snr10.wav','out.wav');
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
   fprintf('Usage: map(''[filename]'' ''[outfile]'' \n\n');
   return;
end

method = 'mcra';

%% Open speech data
[x  Srate nbits] = wavread(filename);

%%
len = floor(20*Srate/1000); 
if rem(len,2)==1, len=len+1; end;
PERC = 50; 
len1 = floor(len*PERC/100);
len2 = len-len1; 
win = hanning(len); 
U = norm(win);

%
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
        gammak = min(sig2./noise_mu2,1000); 
        
        aa = 0.96;
        if n==1
            ksi = 0.0032 + (1-aa)*max(gammak-1,0);
            lambdaX = sig2;
            sm_gammak = gammak;
        else   
            if 1
                ttt = 10*ones(size(gammak));
                
                if 1 
                    idx = find(ksi>=0.2);
                    ttt(idx) = 5;
                    idx = find(ksi<0.2);
                    ttt(idx) = 14;
                end
                   
                if 1 
                    if 1
                        lambdaX = ones(size(ksi))*0.001;
                        aa = ones(size(ksi))*0.875;
                        ETA = 0.65;
                        lambdaX_ss = ETA*sig2_old + (1-ETA)*sig2 - noise_mu2;

                        idx = find(gammak>=ttt);
                        aa(idx) = 0.92;
                        idx = find(gammak<ttt);
                        aa(idx) = 0.96;
                        lambdaX = aa.*Xk_prev + (1-aa).*max(lambdaX_ss, 0);
                        ksi = lambdaX./noise_mu2;
                    end
                end
            end
        end
    end
    
    gammak_old = gammak;
    sig2_old = sig2;
    
    hw = zeros(size(ksi))+1;
    vu = zeros(size(ksi));
    
    if 1
        idx = find(ksi>=1);
        hw(idx) = 1;
        idx = find(ksi<1);
        hw(idx) = 0; 
        hw = hw(:);
    end


    hw_old = hw;
    hw = max(hw, sqrt(10^(-24/10)));

    

    
    
%%    
    vk=ksi.*gammak./(1+ksi);
	
%%    
    if 1
        if 1
            if 1
                if 1
                    if 1 
                        G = sqrt(ksi./(1+ksi).*(1./gammak + ksi./(1+ksi)));
                    end
                    if 1
                        Xk_prev = (G.*sig(1:nFFT/2+1)).^2;
                    end
                end
            end
        end
    end
    
%%    
    hw = [hw(:);hw(end-1:-1:2)];
    gain_ar(:,n) = hw(:);
    
    Xk_prev = Xk_prev(1:nFFT/2+1);
      
    xi_w = ifft(hw .* spec); 
	xi_w = real(xi_w)*U;
	
    xfinal(k:k+ len2-1) = x_old + xi_w(1:len1);
	x_old = xi_w(len1+ 1: len);
   
    k = k + len2;
end


%% ========================================================================================
wavwrite(xfinal,Srate,16,outfile);