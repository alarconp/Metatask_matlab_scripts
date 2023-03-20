%% Skittles Agency ERP analysis
% A script for getting the ERPS
% You must first pre-process the EEG signal using the
% Skittles_Agency_preprocesss_EEG.m  and delete ICA components
% Written by: Angeliki Charalampaki October 2021

clearvars; close all;
%% Specify file location
% and get the name etc for each participant/block
user = 'paula_laptop';
save_everything  = 1;
plot_PDFs = 0;
% Specify the triggers and events you will use to create the epochs
triggers = {'26' '42' '6'};
events = {'T1_correct' 'T1_wrong' 'T2'}


if strcmp(user, 'paula_laptop')
    experiment_folder = [filesep 'MATLAB scripts and data' filesep 'EEG' filesep 'Pilots' filesep];
    data_path = [experiment_folder 'Pilots_analyze_data' filesep 'Pilots_data_raw_copy' filesep];
    eegl_path = 'C:\\Program Files\\MATLAB\\R2021a\\toolbox\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc';
    save_folder = [experiment_folder 'Pilots_analyze_data' filesep 'Pilots_data_preprocessed'];
    figure_path = [experiment_folder 'Pilots_analyze_data' filesep 'Pilots_figures'];
end


% get participants list of names
subject_list  = get_participant_name(data_path);
% subject_clean = subject_list(2); % in the future i might exclude some participants
subject_clean = subject_list; % in the future i might exclude some participants


for number_of_subj= 1:length(subject_clean) %To loop across participants
    
    fprintf('\n******\n\nProcessing Participant: %s\n\n******\n\n', subject_clean{number_of_subj});
    
    % Check if participants pre-processing data folder exists and if not
    % give error:
    save_path = [save_folder filesep subject_clean{number_of_subj}];
        if ~exist(save_path,'dir')
            fprintf('\n *** WARNING: %s do not exist *** \n', [subject_clean{number_of_subj} ' pre-processed data']);
        else
            cd(save_path)
        end
        
    %get the name of ICA file after manually checking/rejecting ICA components:
    files_e    = dir(save_path);
    names_e    = {files_e.name};
    name_ica_index = ~[files_e.isdir] & contains(names_e, 'pruned.set');
    ica_eeg = names_e(name_ica_index);      
        
    %open eeglab and load dataset 
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; %open eeglab
    EEG = pop_loadset('filename', ica_eeg ,'filepath', save_path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','prunedICA','gui','off');
    
    %Get the sequence of triggers in each trial, with a trial index in the first column (1 for mo trials, 0 for ml trials)
    %Get a logical vector specifying the trials that meet a given condition (mo or ml) 
    [all_triggers, trial_index_mo, trial_index_ml] = get_triggers_sequence_from_preprocessed_eeg_Paula(EEG);
                
    for i = 1:length(triggers) %Loop for epoching the continuous EEG data based on different events

        %Specify the triggers you want to use to epoch the data
        switch(i)
            case 1
                triggers(i) = '26'; %Trigger for T1 response correct
                events(i) = 'T1_correct';
            case 2
                triggers(i) = 42; %Trigger for T1 response wrong
                events(i) = 'T1_wrong';
            case 3
                triggers(i) = 6; %Trigger for T2 response
                events(i) = 'T2';
        end
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0);

    %Epoch data based on specified trigger
    EEG = pop_epoch( EEG, {  trigger  }, [-1  2], 'newname', 'epoched', 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','epoched','gui','off');
    EEG = eeg_checkset( EEG ); 
    EEG = pop_rmbase( EEG, [-1000 0] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','epoched_rbase','gui','off');

        for x = 1:2 %To create different datasets for each of the two conditions (mo and ml)
            switch(x)
                case 1
                    rejected_trials = trial_index_ml; %To select manipulated outcome trials only
                    condition = 'mo';
                case 2
                    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',CURRENTSET-1,'study',0);
                    rejected_trials = trial_index_ml; %To select manipulated lever trials only 
                    condition = 'ml';
            end
                
        %Create dataset of selected trials 
        EEG = pop_rejepoch( EEG, rejected_trials, 0);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','epoched_rbase_selected','gui','off');
            
            EEG.save_name= [subject_clean{number_of_subj} '_epoch_' event '_' condition];
                if (save_everything)
                    EEG = pop_saveset(EEG, 'filename', [EEG.save_name '.set'], 'filepath', save_path);
                end
        end %Ends looping across conditions (mo, ml)
    end %Ends epoching the signal based on trigger

end %Ends looping across participants