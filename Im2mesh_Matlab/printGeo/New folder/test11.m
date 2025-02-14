% ---------------------------------------------------------------------
% Use function regroup to organize cell array poly_node, poly_edge into
% array node, edge.
[ node, edge, part ] = regroup( poly_node, poly_edge );

% Note:
% node, edge - array. Nodes and edges of all polygonal boundary
% node, edge doesn't record phase info.
% node - V-by-2 array. x,y coordinates of vertices. 
%        Each row is one vertex.
% edge - E-by-2 array. Node numbering of two connecting vertices of
%        edges. Each row is one edge.
% part - cell array. Used to record phase info.
%          part{i} is edge indexes of the i-th phase, indicating which 
%          edges make up the boundary of the i-th phase.

% ---------------------------------------------------------------------
% Delaunay triangulation in 2D using subfunction deltri1
[vert,~,tria,tnum] = deltri1( vert, edge, node, edge, part );