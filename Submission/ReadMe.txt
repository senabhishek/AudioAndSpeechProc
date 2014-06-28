Here is the folder structure for our submission directory.

1. Offline Processing
offlineSource folder contains all the source files for offline processing of input files. To invoke the algorithm please run "super.m" mat file. There are on-screen instructions to help guide you through the script. 

2. Real time processing
realtimeSource folder contains the realtime simulink model that performs noise power estimation based MS algorithm. To invoke the model simply run the "main.m" mat file.

3.Audio
audio folder contains the three input sound files used for offline processing.

4.Sample Output
sampleOutputWavFiles folder contains the sample output .wav files that were generated using MS (output1x.wav), SPP(output2x.wav) and DD(output3x.wav) algorithms.

x - 1(stationary), 2(non-stationary)

This folder also contains the PESQ executable that was used to evaluate the output .wav files. Please rename this file to PESQ.exe.

5.Models
models folder contains the offline processing simulink model. To invoke the model, please open the "matlab.mat" file from the workspace and run the "main.m" file.

6.Report
report folder contains the final report pdf.