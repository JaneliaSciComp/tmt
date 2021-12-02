function [is_rule_done_from_rule_index, job_status_from_rule_index] = ...
    run_rules(rule_from_rule_index, maximum_running_slot_count, do_actually_submit, maximum_wait_time, do_show_progress_bar)
    % Possible job_statuses are {-1,0,+1,nan}.
    %    -1 means errored out
    %     0 means running or pending
    %    +1 means completed successfully
    %   nan means was never run
    if ~exist('maximum_running_slot_count', 'var') || isempty(maximum_running_slot_count) ,
        maximum_running_slot_count = inf ;
    end
    if ~exist('do_actually_submit', 'var') || isempty(do_actually_submit) ,
        do_actually_submit = true ;
    end
    if ~exist('maximum_wait_time', 'var') || isempty(maximum_wait_time) ,
        maximum_wait_time = inf ;
    end
    if ~exist('do_show_progress_bar', 'var') || isempty(do_show_progress_bar) ,
        do_show_progress_bar = true ;
    end

    is_time_up = false ;
    rule_count = length(rule_from_rule_index) ;
    are_targets_up_to_date_from_rule_index = compute_are_targets_up_to_date_from_rule_index(rule_from_rule_index) ;
    is_rule_done_from_rule_index = are_targets_up_to_date_from_rule_index ;
        % A rule is "done" if the job for it exited, or it did not need to be run
    is_runnable_from_rule_index = compute_is_runnable_from_rule_index(rule_from_rule_index) ;  % means inputs exist, and are done being written to
    done_rule_count = sum(is_rule_done_from_rule_index) ;
    job_id_from_rule_index = nan(rule_count,1) ;  % nan means not yet submitted
    job_status_from_rule_index = nan(rule_count,1) ;  % nan means the job_id is nan
    has_job_been_submitted_from_rule_index = false(rule_count, 1) ;
    is_job_in_progress_from_rule_index = false(rule_count, 1) ;
    slot_count_from_rule_index = [rule_from_rule_index.slot_count]' ;
    is_progress_still_possible = true ;
    if do_show_progress_bar ,
        progress_bar = progress_bar_object(rule_count) ;
    end
    ticId = tic() ;
    while done_rule_count<rule_count && ~is_time_up && is_progress_still_possible ,        
        % This is the central thing we do each iteration: Check how the submitted jobs
        % are doing, and act accordingly
        was_job_in_progress_from_rule_index = is_job_in_progress_from_rule_index ;
        job_id_from_was_in_progress_index = job_id_from_rule_index(was_job_in_progress_from_rule_index) ;
        job_status_from_was_in_progress_index = get_bsub_job_status(job_id_from_was_in_progress_index) ; 
        job_status_from_rule_index(was_job_in_progress_from_rule_index) = job_status_from_was_in_progress_index ;        
        is_job_in_progress_from_rule_index = has_job_been_submitted_from_rule_index & (job_status_from_rule_index==0) ;
        
        % Update is_runnable_from_rule_index
        did_job_just_exit_from_rule_index = was_job_in_progress_from_rule_index & ~is_job_in_progress_from_rule_index ;
        if any(did_job_just_exit_from_rule_index) ,
            is_rule_done_from_rule_index(did_job_just_exit_from_rule_index) = true ;
            does_need_submission_from_rule_index = ~is_rule_done_from_rule_index & ~is_job_in_progress_from_rule_index ;
            rule_from_needs_submission_index = rule_from_rule_index(does_need_submission_from_rule_index) ;
            is_runnable_from_needs_submission_index = compute_is_runnable_from_rule_index(rule_from_needs_submission_index) ;
            is_runnable_from_rule_index(does_need_submission_from_rule_index) = is_runnable_from_needs_submission_index ;
        end       
        done_rule_count = sum(is_rule_done_from_rule_index) ;
        if do_show_progress_bar ,
            progress_bar.update(done_rule_count) ;
        end

        % If no jobs are in progress, and no jobs have become runnable, no
        % further progress can be made
        
        % Compute how many slots are in use, and thus how many slots we can use for new
        % job submissions
        carryover_slot_count = sum(slot_count_from_rule_index(is_job_in_progress_from_rule_index)) ;
        maximum_new_slot_count = maximum_running_slot_count - carryover_slot_count ;
                
        % Submit new jobs, if appropriate
        is_submittable_from_rule_index = ~has_job_been_submitted_from_rule_index & is_runnable_from_rule_index ;
        rule_index_from_submittable_index = find(is_submittable_from_rule_index) ;
        slot_count_from_submittable_index = slot_count_from_rule_index(rule_index_from_submittable_index) ;
        will_submit_from_submittable_index = determine_which_jobs_to_submit(slot_count_from_submittable_index, maximum_new_slot_count) ;
        rule_index_from_submission_index = rule_index_from_submittable_index(will_submit_from_submittable_index) ;
        submission_count = length(rule_index_from_submission_index) ;
        for submission_index = 1 : submission_count ,
            rule_index = rule_index_from_submission_index(submission_index) ;
            rule = rule_from_rule_index(rule_index) ;
            function_handle = rule.function_handle ;
            other_arguments = rule.other_arguments ;
            slot_count = rule.slot_count ;
            stdouterr_file_name = rule.stdouterr_file_name ;
            bsub_option_string = rule.bsub_option_string ;
            do_use_xvfb = rule.do_use_xvfb ;
            job_id = ...
                bsub(do_actually_submit, ...
                     slot_count, ...
                     stdouterr_file_name, ...
                     bsub_option_string, ...
                     do_use_xvfb, ...
                     function_handle, ...
                     other_arguments{:}) ;
            job_id_from_rule_index(rule_index) = job_id ;
            has_job_been_submitted_from_rule_index(rule_index) = true ;
            is_job_in_progress_from_rule_index(rule_index) = true ;  % for local jobs, this is not exactly true, but it works.
        end        
        
        % If no jobs are in progress at this point, then no future
        % progress can happen
        is_progress_still_possible = any(is_job_in_progress_from_rule_index) ;

        % See if our time is up
        is_time_up = (toc(ticId) > maximum_wait_time) ;
        
        % If we're actually submitting to the cluster, pause here a bit so we
        % don't submit too too many bjobs commands
        if do_actually_submit ,
            pause(1) ;
        end        
    end
    if do_show_progress_bar ,
        progress_bar.finish_up() ;
    end
    job_status_from_rule_index = get_bsub_job_status(job_id_from_rule_index) ;
end
