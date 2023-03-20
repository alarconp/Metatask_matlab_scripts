%% A script for pre-processing the EEG data from all participants. 
% EEG data were recorded using gtec and the scripts to load the signal
% (originally inclyded as eeglab plugin) have been modified to avoid
% openning windows..etc..and solve several problems that occured with the triggers info.
% for the script to run smoothly additional scripts needed are:
% 1)get_participant_name.m
% 2)all eeglab functions and plugins
% 3)pop_read_gtec_angeliki.m
% 4)read_gtec_hdf5events_Skittles_agency.m
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


for number_of_subj= 1:length(subject_clean)
    
    fprintf('\n******\n\nProcessing Participant: %s\n\n******\n\n', subject_clean{number_of_subj});
    
    % Check if participants pre-processing data folder exists and if not
    % make one: 
    save_path = [save_folder filesep subject_clean{number_of_subj}];
        if ~exist(save_path,'dir')
            mkdir([save_path])
        end
      
    % Define folder containing raw data for each participant:    
    eeg_raw = [data_path subject_clean{number_of_subj} filesep 'eeg'];
    cd(eeg_raw)
end    
    % get the name of the block data (just to make sure nothing changes if the naming changes):
    files_e    = dir(eeg_raw);
    names_e    = {files_e.name};
    name_index = ~[files_e.isdir];
    block_eeg = names_e(name_index);
    
    
    %% Load all the blocks with eeg data  and then concatenate them % eeglab redraw: to update the GUI
    %  fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % open eeglab
    
    %% Load all sessions/blocks
    for session = 1:length(block_eeg) % loop among the blocks to load all the files from each participant
        [EEG, ALLEEG, command] = pop_read_gtec_angeliki(ALLEEG,block_eeg{session},eeg_raw); % i modified the script used as plugin so the windows do not pop up
        [ALLEEG EEG CURRENTSET]= pop_newset(ALLEEG, EEG, session,'setname',block_eeg{session},'gui','off');
        EEG = eeg_checkset( EEG );
    end
    
    %% Merge the sessions:
    %     for files_index = 1:length(block_eeg)
    %         EEG = pop_mergeset( ALLEEG, files_index, 0); % merge all the blocks into one session
    %     end
    files_index = [1:length(block_eeg)];
    EEG = pop_mergeset( ALLEEG, files_index, 0); % merge all the blocks into one session
    

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, (session(end)+1),'setname',subject_list{2},'gui','off'); % I only use this now that i want to analyze specific participant
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, (subjIdx(end)+1),'setname',subject_list{X},'gui','off');
    
    %% Channel location after selecting only the EEG signal channels:
    EEG = pop_select( EEG, 'channel',{'FP1','FPz','FP2','AF7','AF3','AF4','AF8','F7','F5','F3','F1','Fz','F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8','T7','C5','C3','C1','Cz','C2','C4','C6','T8','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','P7','P5','P3','P1','Pz','P2','P4','P6','P8','PO7','PO3','POz','PO4','PO8','O1','Oz','O2','F9','F10'});
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'setname','Merged datasets all four eeg','gui','off');
    
    EEG=pop_chanedit(EEG, 'lookup',eegl_path);
    
    EEG.save_name= [subject_clean{number_of_subj} '_eeg']; 
    if save_everything
        EEG = pop_saveset(EEG, 'filename', [EEG.save_name '.set'],'filepath',save_path); % remember to save the dataset from each participant in the folder you will make each time
    end
    
    
    %% Re-reference (using average reference)
    EEG = pop_reref( EEG, []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8,'setname','Merged datasets all four eeg_rav','gui','off');
    
    EEG.save_name= [EEG.save_name '_rav']% for future: [subject_clean{number_of_subj}]
    if save_everything
        EEG = pop_saveset(EEG, 'filename', [EEG.save_name '.set'],'filepath',save_path); % remember to save the dataset from each participant in the folder you will make each time
    end
    
    %% Filter the data:
    %High pass
    EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 9,'setname','Merged datasets all four eeg_rav_lowpass','gui','off');
    
    EEG.save_name= [EEG.save_name '_HPfilt'];% for future: [subject_clean{number_of_subj}]
    if save_everything
        EEG = pop_saveset(EEG, 'filename', [EEG.save_name '.set'],'filepath',save_path); % remember to save the dataset from each participant in the folder you will make each time
    end
    
    %Notch
    EEG = pop_eegfiltnew(EEG, 'locutoff',49,'hicutoff',51,'revfilt',1,'plotfreqz',0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 10,'setname','Merged datasets all four eeg_rav_lowpass_notch','gui','off');
    
    %     EEG.save_name= [EEG.save_name '_BP'];
    EEG.save_name= [EEG.save_name '_notch'];

    if save_everything
        EEG = pop_saveset(EEG, 'filename', [EEG.save_name '.set'],'filepath',save_path); % remember to save the dataset from each participant in the folder you will make each time
    end
    
    
    %% Run ICA
    
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    EEG.save_name= [EEG.save_name '_ICA'];% for future: [subject_clean{number_of_subj}]
    if save_everything
        EEG = pop_saveset(EEG, 'filename', [EEG.save_name '.set'],'filepath',save_path); % remember to save the dataset from each participant in the folder you will make each time
    end

end