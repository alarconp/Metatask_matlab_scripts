% function [all_latencies] = triggers_latencies_and_other_info
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
    % give error:
    save_path = [save_folder filesep subject_clean{number_of_subj}];
        if ~exist(save_path,'dir')
            fprintf('\n *** WARNING: %s do not exist *** \n', [subject_clean{number_of_subj} ' pre-processed data']);
        else
            cd(save_path)
        end
    %open eeglab and load dataset after manually checking the ICA components
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % open eeglab
    %     EEG = pop_loadset('filename','pilot_angeliki_eeg_lowpass_notch_ICA_prunedICA_epochType1.set','filepath','/Users/Angeliki/Seafile/My Library/Angeliki/Skittles_Agency/Skittles_Agency_Analyze_Data/Skittles_Agency_Data_preprocessed/');
    %EEG = pop_loadset('filename',[subject_clean{number_of_subj} '_eeg_rav_HPfilt_BP_ICA.set'] ,'filepath',save_path);
    %EEG = pop_loadset('filename',[subject_clean{number_of_subj} '_eeg_rav_HPfilt_BP.set'] ,'filepath',save_path);

    all_latencies=[];
    allEvents      = {EEG.event.type}';
     [all_triggers] = get_triggers_sequence_from_preprocessed_eeg(EEG);
    %% get the index for spliting the continuous data in trials
    latencies     = [EEG.event.latency]'; % Obtain all event types
    
    end_of_trial =find(strcmp(allEvents,'6')); % find the end of each trial (meaning after type2 response)
   
    first_lt= latencies(1:end_of_trial(1))'; %due to the loop i get the first trial and then loop among the rest
    trial = numel(end_of_trial);
    next_lt = cell(trial-1, 1);
    
    for i = 1:(length(end_of_trial)-1)
        next_lt{i} =latencies(end_of_trial(i)+1:end_of_trial(i+1))';
    end
    
    %add the first trial:
    trial_tr= [first_lt;next_lt];
    
    
    %now checkk the max number of elements in each of the cell and use this
    %value to concatenate the trials (in current case is 14)
    trigger_tr=[];
    
    for n=1:length(trial_tr)
        
        sn=length(trial_tr{n});
        sf=14;
        if length(trial_tr{n})~=sf
            trigger_tr(n,:) = [trial_tr{n} zeros(1,abs(sf-sn))];
        else
            trigger_tr(n,:)= [trial_tr{n}];
        end
    end
    all_latencies = [all_latencies; trigger_tr];
    all_latencies(all_latencies<0)=0;
% end

temp_trial =all_latencies
triggers_t = bsxfun(@minus,temp_trial,temp_trial(:,1)) % a function that subtracts the first element from each row, to get the timing of each trigger within a trial
triggers_t(triggers_t<0)=0


%load behavioral data to get the trials the second throw was 
load([data_path  subject_clean{number_of_subj} filesep 'Agency' filesep 'SkittlesResult_' subject_clean{number_of_subj} '_Agency_block_4.mat' ])
condition        =[];
firstThrow = [];
%seconThrow = [];


for b = 1: length(resultDataAgency.type1(:))
    condition=[condition resultDataAgency.block(b).condition_trial];
    firstThrow = [firstThrow resultDataAgency.block(b).sequence.firstThrow]
    %seconThrow = [seconThrow resultDataAgency.block(b).sequence.secondThrow]
   
end

lever_second = firstThrow=='r' & condition=='l';
lever_first  = firstThrow=='m' & condition=='l';
outco_second = firstThrow=='r' & condition=='o';
outco_first  = firstThrow=='m' & condition=='o';



%% IGNORE FOR NOW:
% Get the time each event takes place
% Type 2 response
type2_t=triggers_t(all_triggers==6)
m_type2 = mean(type2_t)
s_type2 = std(type2_t)
type2_cue=triggers_t(all_triggers==58)
mean(type2_cue)
% Type 1 response
type1_t_correct=triggers_t(all_triggers==26);
m_type1_t_correct = mean(type1_t_correct)
s_type1_t_correct = std(type1_t_correct)

type1_t_wrong=triggers_t(all_triggers==42);
m_type1_t_wrong = mean(type1_t_wrong)
s_type1_t_wrong = std(type1_t_wrong)
mean([type1_t_correct; type1_t_wrong])


%get trials lever was manipulated first
triggers_lever_first= all_triggers(lever_first,:)
triggers_lever_latency_first= triggers_t(lever_first,:)

% get the trials lever was manipulated second:
triggers_lever_second= all_triggers(lever_second,:)
triggers_lever_latency_second= triggers_t(lever_second,:)

%LEVER
time_grab_l_2nd = triggers_lever_latency_second(triggers_lever_second==56)
mean(time_grab_l_2nd(1:end-1))

time_grab_l_1st = triggers_lever_latency_first(triggers_lever_first==56)
mean(time_grab_l_1st(1:end-1))
time_release_l_1st = triggers_lever_latency_first(triggers_lever_first==36)
mean(time_release_l_1st(1:end-1))


%OUTCOME:
triggers_outcome_first= all_triggers(outco_first,:)
triggers_outco_latency_first= triggers_t(outco_first,:)
time_grab_o_1st = triggers_outco_latency_first(triggers_outcome_first==40)
mean(time_grab_o_1st(1:end-1))
time_release_o_1st = triggers_outco_latency_first(triggers_outcome_first==20)
mean(time_release_o_1st(1:end-1))


triggers_outcome_second= all_triggers(outco_second,:)
triggers_outco_latency_2nd= triggers_t(outco_second,:)



%REAL trials triggers_lever_second triggers_lever_latency_second
% when the real was the first
real_grab_1st_lever = triggers_lever_latency_second(triggers_lever_second==24)
mean(real_grab_1st_lever(1:end-1))

real_releas_1st_lever = triggers_lever_latency_second(triggers_lever_second==4)
mean(real_releas_1st_lever(1:end-1))

real_target_1st_lever = triggers_lever_latency_second(triggers_lever_second==18)
mean(real_target_1st_lever(1:end-1))

% when the real was the second
real_start_2nd_lever = triggers_lever_latency_first(triggers_lever_first==22)
mean(real_start_2nd_lever(1:end-1))

real_grab_2nd_lever = triggers_lever_latency_first(triggers_lever_first==24)
mean(real_grab_2nd_lever(1:end-1))

real_releas_2nd_lever = triggers_lever_latency_first(triggers_lever_first==4)
mean(real_releas_2nd_lever(1:end-1))


%Type 1 cue
type1_cue_1st_lever = triggers_lever_latency_first(triggers_lever_first==10)
mean(type1_cue_1st_lever(1:end-1))

%type 1 response
type1__1st_lever_right = triggers_lever_latency_first(triggers_lever_first==26)
mean(type1__1st_lever_right(1:end-1))

type1__1st_lever_wrong = triggers_lever_latency_first(triggers_lever_first==42)
mean(type1__1st_lever_wrong(1:end-1))

%type 2 cue
type2_cue_1st_lever = triggers_lever_latency_first(triggers_lever_first==58)
mean(type2_cue_1st_lever(1:end-1))

type2_1st_lever_wrong = triggers_lever_latency_first(triggers_lever_first==6)
mean(type2_1st_lever_wrong(1:end-1))


% %target was hit and was seen only when trial real
% real_o_target_1st= triggers_outco_latency_2nd(triggers_outcome_second==18)
% mean(real_o_target_1st(1:end-1))
% 
% real_o_target_2nd= triggers_outco_latency_first(triggers_outcome_first==18)
% mean(real_o_target_2nd(1:end-1))
% 
% 
% time_grab_o_2nd = triggers_outco_latency_2nd(triggers_outcome_second==40)
% mean(time_grab_o_2nd(1:end-1))
% time_release_o_2nd = triggers_outco_latency_2nd(triggers_outcome_second==20)
% mean(time_release_o_2nd(1:end-1))

