%% Skittles Agency ERP analysis
% A script for getting the ERPS
% You must first pre-process the EEG signal using the
% Skittles_Agency_preprocesss_EEG.m  and delete ICA components
% Written by: Angeliki Charalampaki October 2021

clearvars; close all;
%% Specify file location
% and get the name etc for each participant/block
user = 'angeliki_office';
save_everything  = 1;
plot_PDFs = 0;


if strcmp(user, 'angeliki_office')
    experiment_folder = [filesep 'Users' filesep 'Angeliki' filesep 'Seafile' filesep 'My Library' filesep 'Angeliki' filesep 'Skittles_Agency' filesep];
    data_path = [experiment_folder 'Skittles_Agency_Analyze_Data' filesep 'Skittles_Agency_Data_raw_copy' filesep];
    eegl_path =['/Users/Angeliki/Seafile/My Library/Angeliki/Matlab_scripts/eeglab2021.1/plugins/dipfit/standard_BEM/elec/standard_1005.elc'];
    save_folder = [experiment_folder 'Skittles_Agency_Analyze_data' filesep 'Skittles_Agency_Data_preprocessed'];
    figure_path = [experiment_folder 'Skittles_AgencyAnalyze_data' filesep 'Skittles_Agency_Figures'];
end


% get participants list of names
subject_list  = get_participant_name(data_path);
% subject_clean = subject_list(2); % in the future i might exclude some participants
subject_clean = subject_list; % in the future i might exclude some participants


for number_of_subj= 2 1:length(subject_clean)
    
    fprintf('\n******\n\nProcessing Participant: %s\n\n******\n\n', subject_clean{number_of_subj});
    
    % Check if participants pre-processing data folder exists and if not
    % give error:
    save_path = [save_folder filesep subject_clean{number_of_subj}];
        if ~exist(save_path,'dir')
            fprintf('\n *** WARNING: %s do not exist *** \n', [subject_clean{number_of_subj} ' pre-processed data']);
        else
            cd(save_path)
        end
    %open eeglab and load dataset after manually checking the ICA components
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % open eeglab
    EEG = pop_loadset('filename','pilot_angeliki_eeg_lowpass_notch_ICA_prunedICA_epochType1.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/');
    %EEG = pop_loadset('filename',[subject_clean{number_of_subj} '_eeg_rav_HPfilt_BP_ICA.set'] ,'filepath',save_path);
    %EEG = pop_loadset('filename',[subject_clean{number_of_subj} '_eeg_rav_HPfilt_BP.set'] ,'filepath',save_path);
    %Get the sequence of the triggers
    [all_triggers] = get_triggers_sequence_from_preprocessed_eeg_Paula(EEG);
    
    EEG.save_name= [subject_clean{number_of_subj} '_epoch_real'];
    if (save_everything)
        EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', save_path);
    end
    
    %Epoch data based on trigger: release_real
    EEG = pop_epoch( EEG,[-1  2], 'newname', [subject_clean{number_of_subj} '_epoched_release_real'], 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-1000 0] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','epoched_release_real_rbase','gui','off');

%% copied from eegh
% [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% EEG = pop_loadset('filename','angeliki_eeg_second_d_eeg_rav_HPfilt_BP_ICA.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/');
% [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
% EEG = eeg_checkset( EEG );
% pop_selectcomps(EEG, [1:62] );
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% EEG = eeg_checkset( EEG );
% EEG = pop_subcomp( EEG, [5   6   7   8   9  10  11  12  14  15  16  17  18  20  22  23  24  25  27  28  29  32  34  35  36  37  38  39  40  42  43  45  46  47  49  51  52  53  54  55  59  60  61  62], 0);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
% EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename','angeliki_eeg_second_d_eeg_rav_HPfilt _BP_ICA_pruned.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/');
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% EEG = eeg_checkset( EEG );
% EEG = pop_epoch( EEG, {  '4'  }, [-1  2], 'newname', 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs rel real', 'epochinfo', 'yes');
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
% EEG = eeg_checkset( EEG );
% EEG = pop_rmbase( EEG, [-1000 0] ,[]);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs rel real base','gui','off'); 
% EEG = eeg_checkset( EEG );
% pop_eegplot( EEG, 1, 1, 1);
% EEG = pop_rejepoch( EEG, [3:5 9 19 20 24 27 32 33 39 45 50 55 59 60 64 65 66 73 76 82 86 89 90 94 99 100 105 112 114 121 127 130 136 137 151 153 155 162 163 164 167 168 171 175 193 195 196:198 236 245 253 254 277 285 296 304 310] ,0);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs rel real base remove epoch','gui','off'); 
% EEG = eeg_checkset( EEG );
% figure; pop_timtopo(EEG, [-1000      1996.0938], [NaN], 'ERP data and scalp maps of Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs rel real base remove epoch');
% EEG = eeg_checkset( EEG );
% figure; pop_plottopo(EEG, [1:62] , 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs rel real base remove epoch', 0, 'ydir',1);
% EEG = eeg_checkset( EEG );
% figure; pop_plottopo(EEG, [1:62] , 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs rel real base remove epoch', 0, 'ydir',1);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'retrieve',2,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_epoch( EEG, {  '42'  }, [-1  2], 'newname', 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs t1 right', 'epochinfo', 'yes');
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
% EEG = eeg_checkset( EEG );
% EEG = pop_rmbase( EEG, [-1000 0] ,[]);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'gui','off'); 
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'retrieve',5,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename','angeliki_eeg_second_d_eeg_rav_HPfilt _BP_ICA_pruned_release_real.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/');
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'retrieve',7,'study',0); 
% EEG = eeg_checkset( EEG );
% pop_eegplot( EEG, 1, 1, 1);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'retrieve',7,'study',0); 
% EEG = eeg_checkset( EEG );
% pop_eegplot( EEG, 1, 1, 1);
% EEG = pop_rejepoch( EEG, 58,0);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'setname','Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs t1 right_reject trial','gui','off'); 
% EEG = eeg_checkset( EEG );
% figure; pop_timtopo(EEG, [-1000      1996.0938], [NaN], 'ERP data and scalp maps of Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs t1 right_reject trial');
% EEG = eeg_checkset( EEG );
% figure; pop_plottopo(EEG, [1:62] , 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs t1 right_reject trial', 0, 'ydir',1);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'retrieve',2,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_epoch( EEG, {  '42'  }, [-2  1], 'newname', 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs', 'epochinfo', 'yes');
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs T1 wrong','gui','off'); 
% EEG = eeg_checkset( EEG );
% EEG = pop_rmbase( EEG, [-2000 0] ,[]);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 9,'setname','Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs T1 wrong base','gui','off'); 
% EEG = eeg_checkset( EEG );
% pop_eegplot( EEG, 1, 1, 1);
% EEG = pop_rejepoch( EEG, [2 48 58 94] ,0);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 10,'gui','off'); 
% EEG = eeg_checkset( EEG );
% figure; pop_timtopo(EEG, [-2000       996.0938], [NaN], 'ERP data and scalp maps of Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs T1 wrong base');
% EEG = eeg_checkset( EEG );
% figure; pop_plottopo(EEG, [1:62] , 'Merged datasets all four eeg_rav_lowpass_notch pruned with ICA epochs T1 wrong base', 0, 'ydir',1);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 11,'retrieve',11,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename','T1wrong.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/');
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 11,'retrieve',8,'study',0); 
% EEG = eeg_checkset( EEG );
% EEG = pop_saveset( EEG, 'filename','T1right.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/');
% [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% [STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','T! right vs wrong','updatedat','off','commands',{{'index',2,'load','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/T1right.set','subject','S01','condition','T1 right'},{'index',3,'load','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/angeliki_eeg_second_d/T1wrong.set','subject','S01','condition','T1 wrong'}} );
% [STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, 'channels', 'interpolate', 'on', 'recompute','on','erp','on');
% tmpchanlocs = ALLEEG(1).chanlocs; STUDY = std_erpplot(STUDY, ALLEEG, 'channels', { tmpchanlocs.labels }, 'plotconditions', 'together');
% 
% STUDY = std_erpplot(STUDY,ALLEEG,'channels',{'FP1','FPz','FP2','AF7','AF3','AF4','AF8','F7','F5','F3','F1','Fz','F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8','T7','C5','C3','C1','Cz','C2','C4','C6','T8','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','P7','P5','P3','P1','Pz','P2','P4','P6','P8','PO7','PO3','POz','PO4','PO8','O1','Oz','O2','F9','F10'}, 'design', 1);
% STUDY = std_erpplot(STUDY,ALLEEG,'channels',{'FP1','FPz','FP2','AF7','AF3','AF4','AF8','F7','F5','F3','F1','Fz','F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8','T7','C5','C3','C1','Cz','C2','C4','C6','T8','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','P7','P5','P3','P1','Pz','P2','P4','P6','P8','PO7','PO3','POz','PO4','PO8','O1','Oz','O2','F9','F10'}, 'plotsubjects', 'on', 'design', 1 );
% STUDY = pop_erpparams(STUDY, 'plotconditions','together','topotime',[-1000 1000] );
% CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
