function disable_interactions_bang(hg_handle)

% If the Interactions property exists, disable all interactions
if isprop(hg_handle, 'Interactions') ,
  set(hg_handle, 'Interactions', []) ;
end

end
