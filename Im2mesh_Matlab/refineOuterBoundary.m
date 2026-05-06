function bounds = refineOuterBoundary( bounds, targetSpace )
% refineOuterBoundary: refine the outer boundary of multi-region polygons 
% by inserting equally spaced seeds to boundary edges.
%
% In the output, the spacing of the seeds does not exactly equal to 
% targetSpace. In each edge, the seeds are inserted according to the 
% following equation. 'len' is the length of an edge.
%    numSegment = round( len / targetSpace );
%    actualSpace = len / numSegment;
%
% usage:
%   bounds = refineOuterBoundary( bounds, targetSpace );
%
% input:
%   bounds - a nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%
% 	targetSpace - space between seeds
%
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % create geometry (planar straight-line graph)
    
    % get nodes and edges (cell array) of polygonal boundary
    [ poly_node, poly_edge ] = getPolyNodeEdge( bounds );
    
    % create planar straight-line graph
    [ node, edge, part ] = regroup( poly_node, poly_edge );
    
    [vert,conn,tria,tnum] = deltri1(node, edge, part);

    % ---------------------------------------------------------------------
    % find the outer boundary
    tnum = logical(tnum);
    phaseLoops = tria2Surface( vert,conn,tria,tnum );

    loop1 = phaseLoops{1}{1}{1};
    polyline = loop2poly(loop1, vert, conn);

    % ---------------------------------------------------------------------
    % refine boundary & update bounds
    polyline = insertEleSizeSeed( polyline, targetSpace );

    tol_dist = 1e-5;    % distance tolerance
    bounds = addPnt2Bound( polyline, bounds, tol_dist );
    
    % ---------------------------------------------------------------------
end

function polyline_coords = loop2poly(loop, vert, conn)
% loop2poly: convert a loop of edges to a closed polyline
%
% input:
%   loop: stores the edge/line indices within a loop of edges. It's an 
%         N-by-1 array. Edge/Line indices are storing in variable 'conn'. 
%         Note that the loop is 100% closed and does no have missing edge. 
%         If loop1{i} is negative, it means the orientation of an edge is 
%         reversed to achieve "head to tail" sequences. Walking through the
%         dges in 'loop1' will get a closed polyline.
%
%   vert: Mesh nodes. It%s a Nn-by-2 matrix, where Nn is the number of 
%         nodes in the mesh. Each row of vert contains the x, y coordinates
%         for that mesh node.
%
%   conn: C-by-2 array of constraining edges, where each row defines an edge. 
%

    num_edges = length(loop);
    
    % Preallocate an array for the node sequence.
    % A closed loop of N edges has N unique nodes, plus 1 to close the polyline visually.
    poly_nodes = zeros(num_edges + 1, 1);
    
    for i = 1:num_edges
        edge_idx = loop(i);
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




















