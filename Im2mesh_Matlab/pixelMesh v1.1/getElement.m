function ele_cell = getElement( im, intensity, num_col, num_row )
% getElement()
% get 4-node number of each element
% ele_cell is a cell, size: num_phase by 1
% ele_cell{i} is a matrix, size: num_element by 6
% ele_cell{i}(j,:) = [ global_element_number, phase_number, node_number_of_4_nodes ]
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Nov 2019
% Cite As:
%   Jiexian Ma (2023). pixelMesh (pixel-based mesh) (https://www.mathworks.
%   com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh), MATL
%   AB Central File Exchange. Retrieved January 12, 2023.

    num_phase = length( intensity );
    
    % initialize ele_cell
    ele_cell = cell( num_phase, 1 );
    integer_type = getIntType( num_col, num_row );
    
    for i = 1: num_phase
        ele_ind_vector = find( im == intensity(i) );
        num_ele = size( ele_ind_vector, 1 );
        % allocate certain integer type, to save memory space
        ele_temp = zeros( num_ele, 6, integer_type );
        
        for j = 1: num_ele
            % subscript of element in im
            [ row, col ] = ind2sub( [num_row, num_col], ele_ind_vector(j) );
            
            % get linear index of 4 corner of voxel(row,col,sli) in 
            % nodecoor_list
            Lind_4corner = [ 
                             (col-1)*(num_row+1) + row, ...
                             col*(num_row+1) + row, ...
                             col*(num_row+1) + row + 1, ...
                             (col-1)*(num_row+1) + row + 1
                             ];

            % put Lind_4corner into
            ele_temp( j, : ) = [ ele_ind_vector(j), i, Lind_4corner ];
        end
        
        ele_cell{i} = ele_temp;
    end
    
end

function integer_type = getIntType( num_col, num_row )
% get the suitable integer type for storing node number

    total_num_node = (num_row+1)*(num_col+1);
    if total_num_node >0 && total_num_node < 2^64
        
        if total_num_node < 2^8
           integer_type = 'uint8';
        elseif total_num_node < 2^16
           integer_type = 'uint16';
        elseif total_num_node < 2^32
           integer_type = 'uint32';
        else
           integer_type = 'uint64';
        end
    else
        error('unexpected number of nodes');
    end
end
