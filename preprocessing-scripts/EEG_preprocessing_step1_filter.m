
%Script for the first step of EEG data preprocessing > filter frequencies

clear all
close all

%SETTINGS: 
%Set the input directory
cd 'C:\\MATLAB scripts and data\\Pilots\\Data\\raw data'
%Set the output directory
output_path = 'C:\\MATLAB scripts and data\\EEG\\data\\Paula_EEG_pilot01\\preprocessed data'
%Set the path for EEGLAB plugin that reads the channel locations that are within the eeg data
channels_path = 'C:\\Program Files\\MATLAB\\R2021a\\toolbox\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc'
%Set the values for the frequency filters
lowpass = 0.5;
highpass = 80;
lownotch = 49;
highnotch = 51;
%Set the output file name (just change the name of subject)
name_file = ['filtered_Paula_all_blocks_','bp_',num2str(sprintf('%.d',lowpass)),'_',num2str(highpass),'_','notch_',num2str(lownotch),'_',num2str(highnotch)]
%end of settings

%start running eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 

%Import the first block of data (with gui)
EEG = pop_read_gtec(ALLEEG) %pop up window to import the file, events data, etc
EEG.setname='Paula_block_1'; %to change the name of current dataset
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 1); %store specified EEG dataset(s) in the ALLEEG variable
%Import the other blocks 
EEG = pop_read_gtec(ALLEEG)
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','Paula_block_2','gui','off'); 
EEG = pop_read_gtec(ALLEEG)
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','Paula_block_3','gui','off'); 
EEG = pop_read_gtec(ALLEEG)
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','Paula_block_4','gui','off'); 

%Merge all blocks
for i=1:length(ALLEEG)
    if i==1
    EEG = pop_mergeset(ALLEEG(i), ALLEEG(i+1));
    else
    EEG = pop_mergeset(EEG, ALLEEG(i+1));
    end
end

%Channel locations
EEG = pop_chanedit(EEG, 'lookup', channels_path); 

%Re-reference data (average)
EEG = pop_reref( EEG, []);

%Band-pass and notch filters
EEG = pop_eegfiltnew(EEG, 'locutoff',lowpass,'hicutoff',highpass);
EEG = pop_eegfiltnew(EEG, 'locutoff',lownotch,'hicutoff',highnotch,'revfilt',1);

%Save file
EEG = pop_saveset (EEG,'filename',name_file,'filepath',output_path);

