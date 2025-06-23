function align_y_axis_labels_bang(axeses)
  if isempty(axeses)
    return
  end
  if ~isrow(axeses) 
    axeses = axeses' ;
  end
  assert(isrow(axeses)) ;
  labels = arrayfun(@(ax)(get(ax, 'YLabel')), axeses) ;
  % original_units = arrayfun(@(label)({label.Units}), labels) ;
  set(labels, 'Units', 'points') ;
  drawnow() ;
  positions_in_cell = arrayfun(@(label)({label.Position}), labels)' ;
  axes_count = numel(axeses) ;
  positions = reshape(cell2mat(positions_in_cell), [axes_count 3]) ;
  x_offsets = positions(:,1) ;
  min_x_offset = min(x_offsets)-2 ;  
    % The -2 is a fudge factor, and is only needed because Matlab ends up shifting
    % all the axes, even though one should stay put, which in practice can put the
    % label too close to the y tick labels.
  new_positions = positions ;
  new_positions(:,1) = min_x_offset ;
  for i = 1 : axes_count
    label = labels(i) ;
    label.Position = new_positions(i,:) ;
  end    
  drawnow() ;
  % % Set the label units back to their old values
  % for i = 1 : axes_count
  %   label = labels(i) ;
  %   label.Units = original_units{i} ;
  % end
end
