%%
clear all
clc

%%
addpath(genpath('mesh2d-master'))

%%
% square
vertex = 10*[ 0 0; 1 0; 1 1; 0 1 ];
psSq1 = polyshape(vertex);

vertex = [ 10 10; 40 10; 40 40; 10 40 ];
psSq2 = polyshape(vertex);

vertex = [ 0 10; 10 10; 10 40; 0 40 ];
psSq3 = polyshape(vertex);

vertex = [ 10 0; 40 0; 40 10; 10 10 ];
psSq4 = polyshape(vertex);

%%
plot( [psSq1; psSq2; psSq3; psSq4] ); 
axis equal

%%
psCell = {psSq1; psSq2; psSq3; psSq4};

bounds = polyshape2bound(psCell);
plotBounds(bounds,false,'ko-')

%%
% create geometry (planar straight-line graph)

% get nodes and edges (cell array) of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( bounds );

% create planar straight-line graph
[ node, edge, part ] = regroup( poly_node, poly_edge );

[vert,conn,tria,tnum] = deltri1(node, edge, part);

%%
tnum = logical(tnum);
phaseLoops = tria2Surface( vert,conn,tria,tnum );

% output:
%  phaseLoops = C
%  C is a nesting cell array for storing multiple loops. C is a 1-by-P cell 
%    array. C{i} means the i-th physical surface. C{i} is a 1-by-S cell 
%    array. C{i}{j} means the j-th plane surface within the i-th physical 
%    surface. C{i}{j} is 1-by-L cell array. C{i}{j}{k} means the k-th loop 
%    of the j-th plane surface within the i-th physical surface. C{i}{j}{k} 
%    stores the line indices within a loop. C{i}{j}{k} is an N-by-1 array.
%    line indices are storing in conn.

loop1 = phaseLoops{1}{1}{1};

% loop2 = phaseLoops{1}{2}{1};


%%
polyline = loop2poly(loop1, vert, conn);

targetLen = 16;
polyline_New = insertEleSizeSeed( polyline, targetLen );

%%
poly_x = polyline_New(:, 1);
poly_y = polyline_New(:, 2);

figure;
plot(poly_x, poly_y, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
axis equal;


















