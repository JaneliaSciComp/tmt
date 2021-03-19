function h = plot_graph(ax, A, xyz, varargin)
    % Returns i and j, lists of connected nodes
    [i,j] = find(A);

    % Extact 
    X = [ xyz(i,1) xyz(j,1)]';
    Y = [ xyz(i,2) xyz(j,2)]';
    Z = [ xyz(i,3) xyz(j,3)]';
    
    % Add NaN values to break between line segments
    X = [X; NaN(size(i))'];
    Y = [Y; NaN(size(i))'];
    Z = [Z; NaN(size(i))'];

    % Serialize the x and y data
    X = X(:);
    Y = Y(:);
    Z = Z(:);
    
    % If only two arguments, then plot as is
    extra_arg_count = length(varargin) ;
    if extra_arg_count == 0 ,
        h = line(ax, 'XData', X, 'YData', Y, 'ZData', Z);
    else
        if mod(extra_arg_count, 2) == 1
            h = line(ax, 'XData', X, 'YData', Y, 'ZData', Z, varargin{1});
            rest_of_args = varargin(2:end) ;
        else
            h = line(ax, 'XData', X, 'YData', Y, 'ZData', Z);
            rest_of_args = varargin ;
        end
        
        % Now apply the rest of the var string
        if ~isempty(rest_of_args)
            for i = 1:2:length(rest_of_args) ,
                set(h, rest_of_args{i}, rest_of_args{i+1});
            end
        end
        
    end
    
end
