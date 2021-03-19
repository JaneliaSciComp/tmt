function result = named_tree_from_tree_as_dA_struct(tree_as_dA_struct, name, color)
    % Process args
    if ~exist('color', 'var') || isempty(color) ,
        color_map_count = 256 ;
        color_map = jet(color_map_count) ;
        color_index = hashy(name) + 1 ;  
          % Want a "random" number that is nonetheless determined by the
          % inputs, so we use the world's dumbest hash function.
        color = color_map(color_index,:) ;
    end
    
    % Get data out of tree_as_struct
    dA_raw = tree_as_dA_struct.dA ;  % the directed adjacency matrix for the tree: dA_raw(i,j)==1 means an edge points from i to j
    xyz_raw = [tree_as_dA_struct.X,tree_as_dA_struct.Y,tree_as_dA_struct.Z] ;  % must be in um
    r_raw = tree_as_dA_struct.R;
    d_raw = tree_as_dA_struct.D;

    % This will be useful
    node_count = size(dA_raw,1) ;

    % Convert to an undirected adjacency matrix
    A_raw = max(dA_raw, dA_raw') ;
    
    % Traverse the graph in depth-first order from the root, allowing us to order
    % the nodes topologically.
    disc = graphtraverse(A_raw,1,'Method','DFS');
    
    % Reorder everything so things are in topological order 
    A = A_raw ;
    A(1:end,:) = A(disc,:) ;
    A(:,1:end) = A(:,disc) ;
    xyz = xyz_raw(disc,:) ;
    r = r_raw(disc,:) ;
    d = d_raw(disc,:) ;
        
    % Get the predecessor (parent) of each node
    %[~,~,pred_slow_as_row] = graphshortestpath(A,1,'DIRECTED',false);
    %pred_slow = pred_slow_as_row(:) ;
    dA = tril(A) ;  % the directed adjacency graph of A
    [is,js] = ind2sub(size(dA), find(dA)) ;
    pred = zeros(node_count, 1) ;
    pred(is) = js ;
    %assert(all(pred==pred_slow)) ;
    
    % Package things as a named tree struct
    parent = pred ;
    if node_count>=1 ,
        parent(1) = -1 ;  % the swc convention is that the root parent is -1
    end
    result = struct('name', name, ...
                    'color', color, ...
                    'xyz', xyz, ...
                    'r', r, ...
                    'parent', parent, ...
                    'tag_code', d) ;
end
