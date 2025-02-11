function [ nodecoor_list, ele_cell ] = pixelMesh( im, intensity, num_col, num_row )
% Convert 2d multi-phase image to pixel-based finite element mesh (4-node quadrilateral element)
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, May 2020
% Cite As:
%   Jiexian Ma (2023). pixelMesh (pixel-based mesh) (https://www.mathworks.
%   com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh), MATL
%   AB Central File Exchange. Retrieved January 12, 2023.

    % get numbering of 4 nodes in each element, corresponding to intensity
    % ele_cell{i}(j,:) = [ element_number, phase_number, node_number_of_4_nodes ]
    ele_cell = getElement( im, intensity, num_col, num_row );

    % get unique index of nodes
    node_ind_cell = cellfun( @(A) unique(A(:,3:6)), ele_cell, 'UniformOutput', 0 ); % !
    unique_node_ind_v = unique( cell2mat( node_ind_cell ) );    % column vector

    % get list of node coordinates, corresponding to unique_node_ind_v
    % nodecoor_list(i,:) = [ node_number, x, y ]
    nodecoor_list = getNodelist( unique_node_ind_v, num_col, num_row );

end

