function core_count = use_this_fraction_of_cores(fraction)
    physical_core_count = get_maximum_core_count() ;
    maximum_core_count_desired = round(fraction * physical_core_count) ;
    poolobj = gcp('nocreate');  % Get the current pool, if one exists, but don't create one.
    if isempty(poolobj) ,
        parpool([1 maximum_core_count_desired]) ;
    end
    poolobj = gcp('nocreate');    % Get the current pool, if one exists, but don't create one.
    core_count = poolobj.NumWorkers ;
    fprintf('Using %d cores.\n', core_count) ;
end
