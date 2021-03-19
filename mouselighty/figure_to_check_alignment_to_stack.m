function [f, a] = figure_to_check_alignment_to_stack(sample_folder_path, ijk1s, desired_sample_count)
    % ijk1s is nx3, the one-based integer indices of n voxels.
    [sample_stacks, sample_radius] = sample_rendered_data(sample_folder_path, ijk1s, desired_sample_count) ;
    mean_sample_stack = mean(sample_stacks, 4) ;
    mean_sample_stack_xy_slice = mean_sample_stack(:,:,sample_radius(3)+1) ;
    f = figure('Color', 'w') ;
    a = axes(f, 'DataAspectRatio', [1 1 1]) ;
    imagesc(a, sample_radius(1)*[-1 +1], sample_radius(1)*[-1 +1], mean_sample_stack_xy_slice) ;
    axis equal
    axis tight
    line(a, 'XData', 0, 'YData', 0, 'Marker', '.', 'MarkerSize', 12) ;
end
