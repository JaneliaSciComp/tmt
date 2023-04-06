function result = get_bjobs_lines(job_ids, submit_host_name)
    % Gets the LSF job status for each job_id.
    % Result is a cell array of strings, each string a job status.
    % Job statuses are things like 'DONE', 'EXIT', 'RUN', 'PEND', etc.   
    % In its current incarnation, a better name might be get_LSF_statuses().
    
    if ~exist('submit_host_name', 'var') || isempty(submit_host_name) ,
        submit_host_name = char(1,0) ;
    end    
    job_id_count = length(job_ids) ;
    job_id_count_per_call = 10000 ;
    batch_count = ceil(job_id_count / job_id_count_per_call) ;
    bjobs_lines_from_batch_index = cell(batch_count, 1) ;
    for batch_index = 1 : batch_count ,
        first_job_index = job_id_count_per_call * (batch_index-1) + 1 ;
        last_job_index = min(job_id_count_per_call * batch_index, job_id_count) ;
        job_ids_this_batch = job_ids(first_job_index:last_job_index) ;
        job_ids_as_string = sprintf(' %d', job_ids_this_batch) ;
        bjobs_command_line = ['bjobs -o stat -noheader' job_ids_as_string] ;
        if isempty(submit_host_name),
            command_line = bjobs_command_line ;
        else
            escaped_bjobs_command_line = escape_string_for_bash(bjobs_command_line) ;
            command_line = ...
                sprintf('ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=20 -q %s %s', ...
                        submit_host_name, ...
                        escaped_bjobs_command_line) ;
        end
        [return_code, stdout] = system(command_line) ;
%         fprintf('\n\nstdout:\n') ;
%         fprintf(stdout) ;
%         fprintf('\n\n') ;
        % [status, stdout] = system(command_line) ;
        % Ignore the return code.
        % As of this writing (2022-09-29), bsub returns a non-zero error code if
        % the given job IDs are a mix of known and unknown job IDs.  (But returns a
        % zero return code if they are *all* unknown.)  This seems like a bug, but
        % whatta ya gonna do?  So we just ignore the return code.  If something has
        % gone very wrong, the parsing of the stdout should fail, and an error will
        % be thrown.
        % if status ~= 0 ,
        %     error('There was a problem running the command %s.  The return code was %d', command_line, status) ;
        % end
        bjobs_lines = strtrim(strsplit(strtrim(stdout), '\n'))' ;  
            % Want a col vector of lines, with no leading or training whitespace on
            % each line.
        if length(bjobs_lines) ~= length(job_ids_this_batch) ,
            error('There was a problem submitting the bsub command %s.  Unable to parse output.  Output was: %s', command_line, stdout) ;
        end
        %job_ids_this_batch_count = length(job_ids_this_batch) ;
        %bjobs_lines = lines(2:(job_ids_this_batch_count+1)) ;  % drop the header
        bjobs_lines_from_batch_index{batch_index} = bjobs_lines ;
    end
    if isrow(job_ids) && ~isscalar(job_ids) ,
        % Make the shape of the output match the input
        result = vertcat(bjobs_lines_from_batch_index{:})' ;  % row
    else
        result = vertcat(bjobs_lines_from_batch_index{:}) ;  % col
    end
end
