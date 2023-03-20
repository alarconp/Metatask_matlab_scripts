
%Script for the second step of EEG data preprocessing > ICA analysis

clear all
close all

%SETTINGS: 
%Set the input and output directory (in this case, the same)
path = 'C:\\MATLAB scripts and data\\EEG\\data\\Paula_EEG_pilot01\\preprocessed data'
%Set the input file (filtered data)
input_file = 'filtered_Paula_all_blocks_bp_5e-01_80_notch_49_51.set'
%Set the output file name (just change the name of subject)
output_file = 'ica_Paula_all_blocks'
%end of settings

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',input_file,'filepath',path)

EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 1);

EEG = pop_saveset( EEG,'filename',output_file,'filepath',path);

