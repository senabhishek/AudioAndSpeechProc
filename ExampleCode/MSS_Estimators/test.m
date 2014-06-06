% test MSS-Estimators
clear, clc

inputfile = 'intersection_soundjay.wav';
mss_map(inputfile, 'out_map.wav');
mss_mmse_spzc(inputfile, 'out_mmse_spzc.wav');
mss_smpr(inputfile, 'out_smpr.wav');
mss_smpo(inputfile, 'out_smpo.wav');
mss_mmse_spzc_snru(inputfile, 'out_mmse_spzc_snru.wav');