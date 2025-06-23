function [yl_min, yl_max] = ylim_all_same_helper(raw_raw_yl_min, raw_raw_yl_max, do_force_symmetric, do_include_zero)
  % Adjust the raw axis limits (tpyically computed from data) to make then
  % symmetric and/or to include zero.

  % Swap the args if out of order
  if raw_raw_yl_min > raw_raw_yl_max
    raw_yl_min = raw_raw_yl_max ;
    raw_yl_max = raw_raw_yl_min ;
  else
    raw_yl_min = raw_raw_yl_min ;
    raw_yl_max = raw_raw_yl_max ;
  end

  % Handle the various cases
  if do_force_symmetric
    yl_max = max(abs(raw_yl_min),abs(raw_yl_max)) ;
    yl_min = -yl_max ;
    % Note that symmetric bounds include zero.
    assert(yl_min<=yl_max) ;
    assert(-yl_min==yl_max) ;
  elseif do_include_zero
    if raw_yl_min<=0 && 0<=raw_yl_max
      % No need to adjust, zero already included
      yl_min = raw_yl_min ;
      yl_max = raw_yl_max ;
    else
      yl_max = max(0,raw_yl_max) ;
      yl_min = min(0,raw_yl_min) ;
    end
    assert(yl_min<=0 && 0<=yl_max) ;    
  else
    % No need to adjust raw values
    yl_min = raw_yl_min ;
    yl_max = raw_yl_max ;
    assert(yl_min<=yl_max) ;
  end
end  % function
