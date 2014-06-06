-------------------------
1. Reference:
-------------------------
Lu, Y. and Loizou, P. (2011). "Estimators of The Magnitude-Squared
Spectrum and Methods for Incorporating SNR Uncertainty," IEEE Trans. 
Audio, Speech, Language Processing,19(5), 1123-1137

-------------------------
2. Matlab file description:
-------------------------
(1).
mms_map.m

MSS-MAP: MSS-MAP: Maximum A Posterior Estimator of Magnitude-Squared 
Spectrum
Eq. (20-22), (33-39)

(2). 
mss_smpr.m
MSS-SMPR: Soft Masking using a PRiori SNR uncertainty on magnitude 
squared spectrum
Eq. (27-29)

(3).
mss_smpo.m
MSS-SMPO: Soft Masking using a POsterior SNR uncertainty on magnitude 
squared spectrum
Eq. (30-32)

(4).
mss_mmse_spzc.m
MSS-MMSE-SPZC: Minimum mean square error estimator magnitude-squared spectrum 
of incorporating SNR uncertainty
Eq. (19)

(5).
mss_mmse_spzc_snur.m
MSS-MMSE-SPZC-SNRU: Minimum mean square error estimator of magnitude squared 
spectrum using SNR uncertainty
Eq. (19) and (43)

(6).
test.m
Testing all the algorithms.

-------------------------
3. Usage:
-------------------------
(1). Run test.m
Or (2). In Matlab command window, change the current directory to where you unzip
the files, and type the following:
>> inputfile = 'sp28_babble_sn10.wav';
>> mss_map(inputfile, 'out_map.wav');
>> mss_mmse(inputfile, 'out_mmse.wav');
>> mss_smpr(inputfile, 'out_smpr.wav');
>> mss_smpo(inputfile, 'out_smpo.wav');
>> mss_mmse_snru(inputfile, 'out_mmse_snru.wav');


-------------------------
4. .p file?
-------------------------
Noise estimation routines are .p files that are compiled using the Matlab function 
"pcode". Matlab version is R2009a. Any version that is below R2009a may not be able 
to excute them.

-------------------------
5. Contact:
-------------------------
Dr. Yang Lu, luyang1980@gmail.com
Dr. Philip Loizou, loizou@utdallas.edu

Sept 2011





