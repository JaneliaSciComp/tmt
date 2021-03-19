function result = get_bsub_job_status_new(job_ids)
    % Possible results are {-1,0,+1}.
    %   -1 means errored out
    %    0 mean running or pending
    %   +1 means completed successfully
    
    result = nan(size(job_ids)) ;
    is_not_yet_submitted = isnan(job_ids) ;
    is_not_going_to_be_submitted = (job_ids<0) ;
    if all(is_not_yet_submitted | is_not_going_to_be_submitted) ,
        result(is_not_going_to_be_submitted) = +1 ;
    else
        command_line = sprintf('bjobs') ;
        [status, stdout] = system(command_line) ;
        if status ~= 0 ,
            error('There was a problem running the command %s.  The return code was %d', command_line, status) ;
        end
        lines = strsplit(stdout, '\n') ;
        if length(lines)<1 ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output.  Output was: %s', bsub_command, stdout) ;
        end        
        bjobs_lines = lines{2:end} ;  % drop the header
        running_bjob_count = length(bjobs_lines) ;
        for i = 1 : running_bjob_count ,
            bjobs_line = bjobs_lines{i} ;
            tokens = strsplit(bjobs_line) ;
            if length(tokens)<3 ,
                error('There was a problem submitting the bsub command %s.  Unable to parse output.  Output was: %s', bsub_command, stdout) ;
            end
            running_job_id_as_string = tokens{1} ;
            running_job_id = str2double(running_job_id_as_string) ;
            job_index = find(running_job_id==job_ids,1) ;
            if ~isempty(job_index) ,            
                lsf_status = tokens{3} ;  % Should be string like 'DONE', 'EXIT', 'RUN', 'PEND', etc.
                if isequal(lsf_status, 'DONE') ,
                    running_job_status_code = +1 ;
                elseif isequal(lsf_status, 'EXIT') ,
                    % This seems to indicate an exit with something other than a 0 return code
                    running_job_status_code = -1 ;
                elseif isequal(lsf_status, 'PEND') || isequal(lsf_status, 'RUN') ,
                    running_job_status_code = 0 ;
                else
                    error('Unknown bjobs status string: %s', lsf_status) ;
                end
                result(job_index) = running_job_status_code ;
            end
        end
    end
end
