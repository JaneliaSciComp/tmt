function draw_polygonal_roi(self,action)

switch(action)
  case 'down'
    if isempty(self.polygonal_roi)
      % if here, there is no in-progress polygonal ROI
      self.polygonal_roi=roving.Polygonal_roi(self);
    end
  case 'up'
    cp=get(self.image_axes_h,'CurrentPoint');
    point=cp(1,1:2)';
    if self.polygonal_roi.n_vertices==0 
      % if here, new vertex
      self.polygonal_roi.append(point);
    else
      distance_to_first_vertex= ...
        self.polygonal_roi.distance_to_first_vertex(point);    
      if (distance_to_first_vertex > 5)
        % if here, new vertex
        self.polygonal_roi.append(point);
      else
        % user has clicked on the initial vertex, which means they're done
        self.polygonal_roi.commit();
        self.polygonal_roi=[];
      end
    end              
end  % switch

end  % function
