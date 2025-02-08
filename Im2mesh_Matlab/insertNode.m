function [ vertU, triaU ] = insertNode( vert, tria )
% insertNode: insert a midpoint in each edges
%     convert linear element to quadratic element (like CPS6M in abaqus)
% input:
%   vert - Node data. N-by-2 array.
%       vert(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   tria - Node numbering for each triangle. M-by-3 array.
%       tria(j,1:3) = [node_numbering_of_3_nodes] of the j-th element
%
% output:
%   vertU - Node data. P-by-2 array. 
%       Due to new vertices, the length of vertU is much longer than vert.
%       vertU(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   triaU - Node numbering for each triangle. M-by-6 array.
%       triaU(j,1:6) = [node_numbering_of_6_nodes] of the j-th element
%

    % ---------------------------------------------------------------------
    % step 1. insert

    num_node = size(vert,1);
    num_ele = size(tria,1);
    
    % append first index to the end
    tria_app = [ tria, tria(:,1) ];     % this constant array is temporary
    
    for j = 1: num_ele
        for k=1:3
            % index of node numbering
            idx1 = tria_app(j,k);
            idx2 = tria_app(j,k+1);
            
            % get coor
            coor1 = vert( idx1, 1:2 );
            coor2 = vert( idx2, 1:2 );
            % get middle point
            coor3 = (coor1 + coor2)/2;
            
            num_node = num_node + 1;
            % add coordinates of new vertex into vert
            vert( num_node, 1:2 ) = [ coor3(1) coor3(2) ];
            % add node numbering of new vertex into tria
            tria( j, k+3 ) = num_node;
        end
    end
    
    % ---------------------------------------------------------------------
    % step 2. Remove repeated vertices, and update vertex numbering in tria

    % Remove repeated vertices in vert. indv is index of vertex
    % indv(k)=t means the vert(k) is repeated with vertU(t)
    [ vertU, ~, indv ] = unique( vert, 'stable', 'rows' );

    triaU = tria;

    % replace the vertex numbering in triangles
    for i = 1: size(indv,1)
        % search vertex one by one
        if indv(i) == i
            % don't need replacement
            continue
        end

        % find the vert location in tria, and replace with new index
        triaU(  triaU == i  ) = indv(i);
    end
    % ---------------------------------------------------------------------
end





