function position_in_center_of_primary_screen_and_fill_it_bang(fig, left_padding, right_padding, top_padding, bottom_padding)
    % What it says on the tin.  left_padding and top_padding should be in
    % pels.
    
    % get the screen size so we can position the figure window
    root_units=get(0,'Units');
    set(0,'Units','pixels');
    screen_dims=get(0,'ScreenSize');
    screen_size = screen_dims(3:4) ;
    set(0,'Units',root_units);

    % Make adjustments for platform
    if ismac() ,
        top_padding = top_padding + 22 ;  % Mac menu bar is 22 pels high
    end
    if ispc() ,
        bottom_padding = bottom_padding + 30 ;
    end
    
    % Set the outer position
    new_size = screen_size - [ left_padding+right_padding top_padding+bottom_padding ] ;
    new_offset = [ left_padding bottom_padding ] ;
    new_outer_position = [ new_offset new_size ] ;
    set(fig, 'OuterPosition', new_outer_position) ;    
end
