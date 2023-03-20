function [unequal_Target_Hit,comment] = get_targetHit_issues_Skittles_Agency_Paula(trial,targetHit,targetHit_alt,unequalTargethit,outcome,manip_throw,pilotData)
                    
         
         %Check if in outcome trials targetHit==targetHit_alt
         %This is because some time the due to the staircase we had to
         %select a vdiff that resulted in an alternative trajectory that
         %led to an incongruent outcome
         outcome_first  = find(outcome  & manip_throw==1); %get index of these trials
         outcome_second = find(outcome & manip_throw==2);  %get index of these trials
         
         target_outcome_f     = targetHit(outcome_first); 
         target_outcome_alt_f = targetHit_alt(outcome_first);
         
         target_outcome_s     = targetHit(outcome_second);
         target_outcome_alt_s = targetHit_alt(outcome_second);
         
         
         
         %Find when the outcome was manipulated in the first throw and
         %create an array to fill with target hit info:
         
         first_targetH       = NaN(1,length(outcome_first));
         first_targetH_alt   = NaN(1,length(outcome_first));
         second_targetH      = NaN(1,length(outcome_second));
         second_targetH_alt  = NaN(1,length(outcome_second));
         
         for tr_f = 1:length(outcome_first)
             first_targetH(tr_f)        = target_outcome_f(tr_f).throw(1);
             first_targetH_alt(tr_f)    = target_outcome_alt_f(tr_f).throw(1);
         end
         
         for tr_s = 1:length(outcome_second)
             second_targetH(tr_s)      = target_outcome_s(tr_s).throw(2);
             second_targetH_alt(tr_s)  = target_outcome_alt_s(tr_s).throw(2);
         end
         
         
         error_hit_first = find(first_targetH~=first_targetH_alt);       %find when the target hit was not the same in first throw
         error_hit_second = find(second_targetH~=second_targetH_alt);    %find when the target hit was not the same in second throw
         
         % Get the index of the trials to be excluded because the
         % outcome btw real and alternative was incongruent either in
         % first or second throw:
         
         
         excl_trial_first_hit = outcome_first(error_hit_first);
         excl_trial_second_hit = outcome_second(error_hit_second);
         exclude_hit = sort([excl_trial_first_hit excl_trial_second_hit]);
         
         if ~pilotData
             % Cross check with the variable saved during experiment:
             first_uneq          = NaN(1,length(unequalTargethit));
             second_uneq          = NaN(1,length(unequalTargethit));
             
             
             for tr_u = 1:length(unequalTargethit)
                 first_uneq(tr_u)     = unequalTargethit(tr_u).throw(1);
                 second_uneq(tr_u)    = unequalTargethit(tr_u).throw(2);
             end
             
             
             error_unequal_target = find(first_uneq | second_uneq);
             unequal_Target_Hit = trial;
             unequal_Target_Hit(error_unequal_target)=1;
             check_target = find(exclude_hit~=error_unequal_target);
             
             if ~isempty(check_target)
                 comment = 'there was an error with target hit trials' ;
             else
                 comment = 'Correct registered target hit information';
             end
         else
             unequal_Target_Hit = trial;
             unequal_Target_Hit(exclude_hit)=1; %Because in some pilot experiments i did not save this info
             comment = sprintf('%d  trials had unequal target hit', numel(find(unequal_Target_Hit==1))); %Changed by Paula
         end

end