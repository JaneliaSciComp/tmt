function result = get_bsub_job_status(job_ids)
    % Possible results are {-1,0,+1}.
    %   -1 means errored out
    %    0 mean running or pending
    %   +1 means completed successfully
    
    job_count = length(job_ids) ;
    result = nan(size(job_ids)) ;
    is_not_yet_submitted = isnan(job_ids) ;
    was_run_locally = (job_ids<0) ;  % means the job was run locally
    was_run_locally_and_exited_cleanly = (job_ids==-1) ;
    was_run_locally_and_errored = (job_ids==-2) ;
    result(was_run_locally_and_exited_cleanly) = +1 ;
    result(was_run_locally_and_errored) = -1 ;
    if all(is_not_yet_submitted | was_run_locally) ,
        return
    end
    was_submitted = ~(was_run_locally | is_not_yet_submitted) ;
    submitted_job_ids = job_ids(was_submitted) ;
    bjobs_lines = get_bjobs_lines(submitted_job_ids) ;
    bjobs_line_index = 1 ;
    for job_index = 1 : job_count ,
        if ~was_submitted(job_index) ,
            continue ;
        end
        job_id = job_ids(job_index) ;
        bjobs_line = bjobs_lines{job_index} ;
        tokens = strsplit(bjobs_line) ;
        if length(tokens)<3 ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output.  Output was: %s', bsub_command, stdout) ;
        end
        running_job_id_as_string = tokens{1} ;
        running_job_id = str2double(running_job_id_as_string) ;
        if running_job_id ~= job_id ,
            error('The running job id (%d) doesn''t match the job id (%d)', running_job_id, job_id) ;
        end
        lsf_status = tokens{3} ;  % Should be string like 'DONE', 'EXIT', 'RUN', 'PEND', etc.
        if isequal(lsf_status, 'DONE') ,
            running_job_status_code = +1 ;
        elseif isequal(lsf_status, 'EXIT') ,
            % This seems to indicate an exit with something other than a 0 return code
            running_job_status_code = -1 ;
        elseif isequal(lsf_status, 'PEND') || isequal(lsf_status, 'RUN') || isequal(lsf_status, 'UNKWN') ,
            running_job_status_code = 0 ;
        else
            error('Unknown bjobs status string: %s', lsf_status) ;
        end
        result(job_index) = running_job_status_code ;
        bjobs_line_index = bjobs_line_index + 1 ;
    end
end


