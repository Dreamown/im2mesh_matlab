function model3d = bounds2pde3d( bounds, height, scale_factor )
% bounds2pde3d: create Matlab 3d pde model object based on polygonal
% boundaries.
% What function bounds2pde3d does:
%     create a 2d pde mode object
%     extrude in the Z direction using 'height'
%     add correct phase label
%     scale node coordinates using 'scale_factor'
%     create a 3d pde mode object
%
% input:
%   bounds - A nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%            plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%            polygon. Use plotBounds( bounds ) to view all polygons.
%
%   height - Extrusion height in the Z direction
%
%   scale_factor - scale factor for the node coordinites
%
% output:
%   model3d - Matlab 3d pde model object
%
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % create initial 2d mesh
    
    % obtain PSLG
    [ poly_node, poly_edge ] = getPolyNodeEdge( bounds );
    [ node, edge, part ] = regroup( poly_node, poly_edge );

    % Extract the coordinates for each endpoint of every edge
    p1 = node(edge(:, 1), :);
    p2 = node(edge(:, 2), :);
    
    % Compute edge length
    edgeLengths = sqrt(sum((p1 - p2).^2, 2));
    min_len = min(edgeLengths);
    
    [vert,~,tria,tnum] = deltri1( node, edge, part );
    
    % ---------------------------------------------------------------------
    % create 2d pde model object and then extrude to create 3d model

    % Create matlab pde model object
    model_temp = createpde();  % qudratic model
    geometryFromMesh( model_temp, vert', tria', tnum' );
    
    g = model_temp.Geometry;
    extrude( g, height );
    
    generateMesh( model_temp, 'Hmax',500, 'Hmin', min_len );
    
    % ---------------------------------------------------------------------
    % add correct phase label to mesh and then scale node coordinates using
    % scale_factor

    vert3d = model_temp.Mesh.Nodes';
    tria3d = model_temp.Mesh.Elements';

    [vert3d,tria3d,tnum3d] = addPhaseLabel(vert3d,tria3d,node,edge,part);
    vert3d = vert3d * scale_factor;

    % Create matlab 3d pde model object
    model3d = createpde();
    
    geometryFromMesh( model3d, vert3d', tria3d', tnum3d' );

    model3d.Mesh = [];

    % ---------------------------------------------------------------------
end


function [vert3d,tria3d,tnum3d] = addPhaseLabel(vert3d,tria3d,node,edge,part)
% addPhaseLabel: add correct phase label (tnum3d) to the mesh (vert3d,tria3d)
% according to 2d PSLG (node,edge,part)

    tnum3d = zeros(size(tria3d,+1),+1);
    
    % tria midpoint
    tmid = vert3d( tria3d(:,1), : ) ...
         + vert3d( tria3d(:,2), : ) ...
         + vert3d( tria3d(:,3), : ) ...
         + vert3d( tria3d(:,4), : );
    tmid = tmid / +4.0;
    
    % calc. "inside" status
    PSLG = edge;
    for ppos = 1: length(part)
       [stat] = inpoly2( tmid(:,1:2), node, PSLG(part{ppos},:) );
       tnum3d(stat)  = ppos;
    end
    
    % keep "interior" tria's
    tria3d = tria3d( tnum3d>+0, : );
    tnum3d = tnum3d( tnum3d>+0, : );
end