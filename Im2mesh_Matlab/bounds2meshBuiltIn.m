function [vert,tria,tnum,vert2,tria2,model1,model2] = bounds2meshBuiltIn( bounds, hgrad, hmax, hmin )
% bounds2meshBuiltIn: generate meshes of parts defined by polygonal boundary.
%        	          Mesh generator: generateMesh
% 
% input:
%   bounds - a nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%            plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%            polygon. Use plotBounds( bounds ) to view all polygons.
%
% (Please check documentation of matlab built-in function generateMesh.)
%     hgrad       % Mesh growth rate
%     
%     hmax        % Target maximum mesh edge length
% 
%     hmin        % Target minimum mesh edge length
%   
% output:
%   vert, tria define linear elements. vert2, tria2 define 2nd order elements.
%
%   vert: Mesh nodes (for linear element). It’s a Nn-by-2 matrix, where 
%           Nn is the number of nodes in the mesh. Each row of vert 
%           contains the x, y coordinates for that mesh node.
%     
%   tria: Mesh elements (for linear element). For triangular elements, 
%           it s a Ne-by-3 matrix, where Ne is the number of elements in 
%           the mesh. Each row in tria contains the indices of the nodes 
%           for that mesh element.
%     
%   tnum: Label of phase. Ne-by-1 array, where Ne is the number of 
%           elements
%       tnum(j,1) = k; means the j-th element belongs to the k-th phase.
%     
%   vert2: Mesh nodes (for quadratic element). It’s a Nn-by-2 matrix.
%     
%   tria2: Mesh elements (for quadratic element). For triangular 
%           elements, it s a Ne-by-6 matrix.
%
%   model1 - PDE model object with linear elements
%
%   model2 - PDE model object with 2nd order elements
%
%   FEMesh object: https://www.mathworks.com/help/pde/ug/pde.femesh.html
%   PDE model object: https://www.mathworks.com/help/pde/ug/pde.pdemodel.html
%
% You can use function plotMeshes( vert, tria, tnum ) to view mesh.
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % create geometry 
    [ poly_node, poly_edge ] = getPolyNodeEdge( bounds );
    pcell = bound2polyshape( bounds );

    % generate mesh
    [vert,tria,tnum,vert2,tria2,~,~,model1,model2] = poly2meshBuiltIn( ...
                        poly_node, poly_edge, pcell, hgrad, hmax, hmin );

end