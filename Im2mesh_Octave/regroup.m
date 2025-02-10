function [ nodeU, edgeU, part ] = regroup( poly_node, poly_edge )
% organize cell array poly_node, poly_edge into array nodeU, edgeU & part
%
% input:
%   poly_node, poly_edge - cell array, nodes and edges of polygonal boundary
%   poly_node{i}, poly_edge{i} corresponds to polygons in the i-th phase.
%   poly_node{i} - N-by-2 array. x,y coordinates of vertices in polygon.
%                  Each row is one vertex.
%   poly_edge{i} - M-by-2 array. Node numbering of two connecting vertices
%                  in polygon. Each row is one edge.
%
% output:
%   nodeU, edgeU - array. Nodes and edges of all polygonal boundary
%   nodeU, edgeU doesn't record phase info. Phase info is recorded by part.
%   nodeU - V-by-2 array. x,y coordinates of vertices. 
%           Each row is one vertex.
%   edgeU - E-by-2 array. Node numbering of two connecting vertices of
%           edges. Each row is one edge.
%   part - cell array. Used to record phase info.
%          part{i} is edge indexes of the i-th phase, indicating which 
%          edges make up the boundary of the i-th phase.
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % group poly_node, poly_edge into node, edge, part
    
    % poly_node and poly_edge have the same size
    num_phase = length( poly_node );
    
    % initialize edge and node
    % pre-allocated memory
    total_size = 0;
    for i = 1: num_phase
        total_size = total_size + size( poly_node{i}, 1 );
    end
    edge = zeros( total_size, 3 );
    node = zeros( total_size, 2 );
    
    accumu_size = 0;
    for i = 1: num_phase
        poly_edge{i}(:,3) = i;  % poly_edge{i}(:,3) as marker, show phase
        if i > 1
            poly_edge{i}(:,1:2) = poly_edge{i}(:,1:2) + accumu_size;
        end
        
        idx = (accumu_size + 1) : (accumu_size + size(poly_node{i}, 1));
        edge( idx, : ) = poly_edge{i};
        node( idx, : ) = poly_node{i};
        
        accumu_size = accumu_size + size( poly_node{i}, 1 );
    end

    % above code equal to:
    %     edg1(:,3) = 1;
    %     edg2(:,3) = 2;
    %     edg3(:,3) = 3;
    %     edg2(:,1:2) = edg2(:,1:2) + size(nod1,1);
    %     edg3(:,1:2) = edg3(:,1:2) + size(nod1,1) + size(nod2,1);
    %     edge = [edg1; edg2; edg3];
    %     node = [nod1; nod2; nod3];
	
    % The PART argument is a cell array that defines individual
    % polygonal "parts" of the overall geometry. Each element 
    % PART{I} is a list of edge indexes, indicating which edges
    % make up the boundary of each region.

    part = cell( 1, num_phase );
    for i = 1: num_phase
        part{i} = find( edge(:,3) == i );
    end
        
    edge = edge( :, 1:2 );
    
    % ---------------------------------------------------------------------
    % Numbering of some nodes and edges aren't unique.
    % Here, we do re-numbering so they would be unique.
    
    % unique node
    [nodeU,~,icn] = unique(node,'rows');    % nodeU = icn(node)
    
    % replace edge using new index
    for i = 1: size(edge,1)
        edge(i,1) = icn( edge(i,1) );
        edge(i,2) = icn( edge(i,2) );
    end
    
    % unique edge
    edge=sort(edge,2);
    [edgeU,~,ice] = unique(edge,'rows');    % edgeU = ice(edge)

    % replace part using new index
    % part is edge index
    for i = 1: length(part)
       for j = 1: length(part{i})
           part{i}(j) = ice( part{i}(j) );
       end
    end
    % ---------------------------------------------------------------------
end

