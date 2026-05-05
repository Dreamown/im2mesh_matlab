function polyline_coords = loop2poly(loop1, vert, conn)
% loop2poly

    num_edges = length(loop1);
    
    % Preallocate an array for the node sequence.
    % A closed loop of N edges has N unique nodes, plus 1 to close the polyline visually.
    poly_nodes = zeros(num_edges + 1, 1);
    
    for i = 1:num_edges
        edge_idx = loop1(i);
        abs_edge_idx = abs(edge_idx);
        
        % Get the node indices for this edge from the connectivity array
        nodes = conn(abs_edge_idx, :);
        
        if edge_idx > 0
            % Positive index: Orientation is nodes(1) -> nodes(2)
            % The "head" of this segment is the first node
            poly_nodes(i) = nodes(1);
        else
            % Negative index: Orientation is nodes(2) -> nodes(1)
            % The "head" of this reversed segment is the second node
            poly_nodes(i) = nodes(2);
        end
    end
    
    % Close the polyline by appending the very first node to the end of the sequence
    poly_nodes(end) = poly_nodes(1);
    
    % Extract the x and y coordinates from the 'vert' array using the node sequence
    polyline_coords = vert(poly_nodes, :); 
    
end