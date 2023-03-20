function [all_triggers, trial_index_mo, trial_index_ml] = get_triggers_sequence_from_preprocessed_eeg_Paula(EEG)

    all_triggers=[];
    
    %% get the index for spliting the continuous data in trials
    allEvents      = {EEG.event.type}'; % Obtain all event types
    
    end_of_trial =find(strcmp(allEvents,'6')); % find the end of each trial (meaning after type2 response)
    triggers = str2double(allEvents);
    first= triggers(1:end_of_trial(1))'; %due to the loop i get the first trial and then loop among the rest
    trial = numel(end_of_trial);
    next_tr = cell(trial-1, 1);
    
    for i = 1:(length(end_of_trial)-1)
        next_tr{i} =triggers(end_of_trial(i)+1:end_of_trial(i+1))';
    end
    
    %add the first trial:
    trial_tr= [first;next_tr];
    
    
    %now checkk the max number of elements in each of the cell and use this
    %value to concatenate the trials (in current case is 14)
    t_tr=[];
    
    for n=1:length(trial_tr)
        
        sn=length(trial_tr{n});
        sf=14;
        if length(trial_tr{n})~=sf
            t_tr(n,:) = [trial_tr{n} zeros(1,abs(sf-sn))];
        else
            t_tr(n,:)= [trial_tr{n}];
        end
    end
    all_triggers = [all_triggers; t_tr];
    
    %% Create a trial index vector
    trial_index_mo = [];
    mo = all_triggers(:,:) == 40; %to detect manipulated outcome (mo) trials, which should contain trigger 40: grab ball mo
    ml = all_triggers(:,:) == 56; %to detect manipulated lever (ml) trials, which should contain trigger 56: grab ball ml
    [mo_rows, ml_cols]= find(mo); 
    [ml_rows, ml_cols]= find(ml);     
    trial_index_mo(mo_rows) = [1]; %vector specifying mo trials (1), and ml trials (0)
    trial_index_mo(ml_rows) = [0];
    trial_index_ml = ~trial_index_mo; %logical vector specifying ml trials (1), and mo trials (0)

    %Add trial index column to the all_triggers array
    all_triggers = [trial_index_mo' all_triggers];
    
end



