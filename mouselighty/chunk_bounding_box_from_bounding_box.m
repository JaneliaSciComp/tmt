function [substack_chunk_origin_ijk1, substack_shape_in_chunks_ijk] = ...
        chunk_bounding_box_from_bounding_box(substack_origin_ijk1, substack_shape_ijk, chunk_shape_ijk)
    % _ijk1 means the coords are in xyz order, but are integer indices, and
    % are one-based
    % On return, substack_chunk_origin_ijk1 is the origin on the grid of
    % *chunks*, using 1 based indexing
    substack_origin_ijk0 = substack_origin_ijk1 -1 ;
    substack_chunk_origin_ijk0 = floor(substack_origin_ijk0 ./ chunk_shape_ijk) ;
    substack_far_corner_ijk0 = substack_origin_ijk0 + substack_shape_ijk -1 ;
    substack_chunk_far_corner_ijk0 = floor(substack_far_corner_ijk0 ./ chunk_shape_ijk) ;
    substack_shape_in_chunks_ijk = substack_chunk_far_corner_ijk0 - substack_chunk_origin_ijk0 + 1 ;
    substack_chunk_origin_ijk1 = substack_chunk_origin_ijk0 + 1 ;
end
