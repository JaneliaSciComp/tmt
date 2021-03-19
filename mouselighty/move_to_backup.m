function move_to_backup(file_name)
    backup_file_name = horzcat(file_name, '.backup') ;
    if exist(backup_file_name, 'file') ,
        move_to_backup(backup_file_name) ;
    end
    movefile(file_name, backup_file_name) ;
end
