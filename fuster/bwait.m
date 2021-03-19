function job_statuses = bwait(job_ids, maximum_wait_time, do_show_progress_bar)
    if ~exist('maximum_wait_time', 'var') || isempty(maximum_wait_time) ,
        maximum_wait_time = inf ;
    end
    if ~exist('do_show_progress_bar', 'var') || isempty(do_show_progress_bar) ,
        do_show_progress_bar = true ;
    end
    
    have_all_exited = false ;
    is_time_up = false ;
    job_count = length(job_ids) ;
    if do_show_progress_bar ,
        progress_bar = progress_bar_object(job_count) ;
    end
    ticId = tic() ;
    while ~have_all_exited && ~is_time_up ,
        job_statuses = get_bsub_job_status(job_ids) ;
        has_job_exited = (job_statuses~=0) ;
        exited_job_count = sum(has_job_exited) ;
        if do_show_progress_bar ,
            progress_bar.update(exited_job_count) ;
        end
        have_all_exited = (exited_job_count==job_count) ;        
        if ~have_all_exited ,            
            pause(10) ;
            is_time_up = (toc(ticId) > maximum_wait_time) ;
        end
    end
    if do_show_progress_bar ,
        progress_bar.finish_up() ;
    end
%     if ~have_all_exited && is_time_up ,
%         error('Maximum wait time exceeded') ;
%     end
end
