
%Script for the third step of EEG data preprocessing > Epochs 

clearvars
close all

%SETTINGS: 
%Set the input and output directory (in this case, the same)
path = 'C:\\MATLAB scripts and data\\EEG\\data\\Paula_EEG_pilot01\\preprocessed data';
%Set the input file (ica data)
input_file = 'ica_Paula_all_blocks.set';
%Set the epoch latency limits (in seconds)
epochLimits = [-0.8 0.2];
%Create conditions based on triggers
events = {'32', '40', '4', '44', '6', '10', '8', '34', '42', '36'};
%end of settings

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',input_file,'filepath',path);
eeglab redraw

%condition_32 = events(1)

    %EEG = pop_epoch( EEG, condition_32 , [epochLimits], 'newname', num2str(condition_32), 'epochinfo', 'yes');
    %EEG = eeg_checkset( EEG );
    %EEG = pop_rmbase( EEG, [-800.7812 0] ,[]);
    %EEG = eeg_checkset( EEG );
    %Save file
    %name_file = ['epoch_Paula_','condition_','32','_epochLimits_',num2str(epochLimits(1)*1000),'_',num2str(epochLimits(2)*1000)]
    %EEG = pop_saveset(EEG, 'filename', name_file, 'filepath', path );

 %Epoch data based on trigger: release_real
    EEG = pop_epoch( EEG,{  '4'  },[-1  2], 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-1000 0] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','epoched_release_real_rbase','gui','off');

    
    
    
    
    %% Create epochs based on triggers (I need to fix this loop):
for i = 1:length(events)
    
    condition = events(i) 
    EEG = pop_epoch( EEG, condition, [epochLimits], 'newname', num2str(condition), 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, i,'gui','off'); EEG = eeg_checkset( EEG );
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-800.7812 0] ,[]);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, i);
    %Save file
    name_file = ['epoch_Paula_','condition',num2str(i),'_epochLimits_',num2str(epochLimits(1)*1000),'_',num2str(epochLimits(2)*1000)]
    EEG = pop_saveset(EEG, 'filename', name_file, 'filepath', path );

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, i,'retrieve',0,'study',0); 
    EEG = eeg_checkset( EEG );
end
