function [all_triggers] = get_triggers_sequence_from_sessions_of_eeg (block_eeg)

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
    
end



