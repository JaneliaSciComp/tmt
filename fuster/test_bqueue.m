do_actually_submit = true ;
max_running_slot_count = 5 ;
bsub_option_string = '-P scicompsoft -W 59 -J test-bqueue' ;
slots_per_job = 1 ;
stdouterr_file_path = '' ;  % will go to /dev/null
bqueue = bqueue_type(do_actually_submit, max_running_slot_count) ;

job_count = 10 ;
for job_index = 1 : job_count ,
    bqueue.enqueue(slots_per_job, stdouterr_file_path, bsub_option_string, @pause, 20) ;  % the 20 is an arg to pause()
end

maximum_wait_time = 200 ;
do_show_progress_bar = true ;
tic_id = tic() ;
job_statuses = bqueue.run(maximum_wait_time, do_show_progress_bar) 
toc(tic_id)
