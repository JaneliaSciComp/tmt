function result = get_bjobs_lines(job_ids)
    job_id_count = length(job_ids) ;
    job_id_count_per_call = 10000 ;
    batch_count = ceil(job_id_count / job_id_count_per_call) ;
    bjobs_lines_from_batch_index = cell(batch_count, 1) ;
    for batch_index = 1 : batch_count ,
        first_job_index = job_id_count_per_call * (batch_index-1) + 1 ;
        last_job_index = min(job_id_count_per_call * batch_index, job_id_count) ;
        job_ids_this_batch = job_ids(first_job_index:last_job_index) ;
        job_ids_as_string = sprintf('%d ', job_ids_this_batch) ;
        command_line = ['bjobs ' job_ids_as_string] ;
        [status, stdout] = system(command_line) ;
        if status ~= 0 ,
            error('There was a problem running the command %s.  The return code was %d', command_line, status) ;
        end
        lines = strsplit(stdout, '\n')' ;  % Want a col vector of lines
        if length(lines)<1 ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output.  Output was: %s', bsub_command, stdout) ;
        end
        job_ids_this_batch_count = length(job_ids_this_batch) ;
        bjobs_lines = lines(2:(job_ids_this_batch_count+1)) ;  % drop the header
        bjobs_lines_from_batch_index{batch_index} = bjobs_lines ;
    end
    result = vertcat(bjobs_lines_from_batch_index{:}) ;    
end
