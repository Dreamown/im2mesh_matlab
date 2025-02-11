function nodecoor_list = getNodelist( unique_node_ind_v, num_col, num_row )
% getNodelist()
% get list of all nodes
% nodecoor_list(i,:) = [ node_number, x, y ]
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Nov 2019
% Cite As:
%   Jiexian Ma (2023). pixelMesh (pixel-based mesh) (https://www.mathworks.
%   com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh), MATL
%   AB Central File Exchange. Retrieved January 12, 2023.

    % generate x y coordinate of all nodes
    % can be accessed by X( row, col, sli ), Y( row, col, sli ), 
    xs = 0.5: num_col+0.5;
    ys = 0.5: num_row+0.5;
    [ X, Y ] = meshgrid( xs, ys );
    
    % reshape into vector
    % can be accessed by X(i), Y(i)
    X = X(:);
    Y = Y(:);
    
    % extract certain nodes
    X = X( unique_node_ind_v );
    Y = Y( unique_node_ind_v );
    
    num_node = length( unique_node_ind_v );
    % temporary list
    temp_list = zeros( num_node, 2 );
    
    for i = 1: num_node
        temp_list( i, : ) = [ X(i), Y(i) ];
    end
    
    % create point list, storing x y coordinate of all nodes
    % nodecoor_list(i,:) = [ node_number, x, y ]
    nodecoor_list = zeros( num_node, 3 );
    nodecoor_list( :, 1 ) = unique_node_ind_v;
    nodecoor_list( :, 2:3 ) = temp_list;

end





