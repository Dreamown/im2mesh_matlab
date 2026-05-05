%%
clear all
clc

%%
addpath(genpath('mesh2d-master'))

%%
% square
vertex = 10*[ 0 0; 1 0; 1 1; 0 1 ];
psSq1 = polyshape(vertex);

psSq2 = translate(psSq1,[10 0]);
psSq3 = translate(psSq1,[0 10]);

%%
plot( [psSq1; psSq2; psSq3] ); 
axis equal

%%
psCell = {psSq1; psSq2; psSq3};

bounds = polyshape2bound(psCell);
plotBounds(bounds,false,'ko-')

%%
% hmax = 5; 
% grad_limit = 0.25;
% opt = [];
% opt.disp = inf;     % silence verbosity
% [vert,tria,tnum] = bounds2mesh( bounds, hmax, grad_limit, opt );
% 
% plotMeshes(vert,tria,tnum,1);

%%
% create geometry (planar straight-line graph)

% get nodes and edges (cell array) of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( bounds );

% create planar straight-line graph
[ node, edge, part ] = regroup( poly_node, poly_edge );

[vert,conn,tria,tnum] = deltri1(node, edge, part);

%%
plotMeshes(vert,tria);

%%
% vert: Mesh nodes. It’s a Nn-by-2 matrix, where Nn is the number of nodes in the mesh. Each row of vert contains the x, y coordinates for that mesh node.
% ele: Mesh elements. It s a Ne-by-3 matrix. Ne is the number of elements in the mesh. Each row in ele contains the indices of the nodes for that mesh element.
% conn: C-by-2 array of constraining edges, where each row defines an edge. 

%%
tnum = logical(tnum);
[ phaseLoops, phaseTria ] = tria2Surface( vert,conn,tria,tnum );

% output:
%  phaseLoops = C
%  C is a nesting cell array for storing multiple loops. C is a 1-by-P cell 
%    array. C{i} means the i-th physical surface. C{i} is a 1-by-S cell 
%    array. C{i}{j} means the j-th plane surface within the i-th physical 
%    surface. C{i}{j} is 1-by-L cell array. C{i}{j}{k} means the k-th loop 
%    of the j-th plane surface within the i-th physical surface. C{i}{j}{k} 
%    stores the line indices within a loop. C{i}{j}{k} is an N-by-1 array.
%    line indices are storing in conn.
%
%  phaseTria is a nesting cell array for storing triangular mesh for each
%    surface. phaseTria{i}{j} means the j-th plane surface within the 
%    i-th physical surface. phaseTria{i}{j} is a p-by-3 array.

%%
%    C{i}{j}{k} means the k-th loop 
%    of the j-th plane surface within the i-th physical surface. C{i}{j}{k} 
%    stores the line indices within a loop. C{i}{j}{k} is an N-by-1 array.
%    line indices are storing in conn.

loop1 = phaseLoops{1}{1}{1};
% 2
%  7
% 11
% 12
% -10
% -5
% -3
% -1

%%
% conn
%      1     2
%      1     4
%      2     3
%      2     5
%      3     6
%      4     5
%      4     7
%      5     6
%      5     8
%      6     9
%      7     8
%      8     9

%%
% numP = length(loop1) +1;
% polyline = zeros( size(numP, 1), 2);
% polyline(1,:) = conn( loop1(1) );

%%
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

% If you need them as separate x and y coordinate arrays:
poly_x = polyline_coords(:, 1);
poly_y = polyline_coords(:, 2);

% Optional: Plot to verify the result
figure;
plot(poly_x, poly_y, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
title('Closed Polyline');
axis equal;






























