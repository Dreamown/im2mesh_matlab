function [vert,tria,tnum,vert2,tria2,mesh1,mesh2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, hgrad, hmax, hmin )
% poly2meshBuiltIn: generate meshes of parts defined by polygons using 
%                   matlab built-in function generateMesh
% 
% input:
%   poly_node, poly_edge - cell array, nodes and edges of polygonal boundary
%   poly_node{i}, poly_edge{i} corresponds to polygons in the i-th phase.
%   poly_node{i} - N-by-2 array. x,y coordinates of vertices in polygon.
%                  Each row is one vertex.
%   poly_edge{i} - M-by-2 array. Node numbering of two connecting vertices
%                  in polygon. Each row is one edge.
%
%   p - cell array. p{i} is a polyshape object, which corresponds to 
%       polygons in the i-th phase
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
%   vert - Node data. N-by-2 array.
%       vert(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   tria - Node numbering for each triangle. M-by-3 array.
%       tria(j,1:3) = [node_numbering_of_3_nodes] of the j-th element
%
%   tnum - Label of material phase. P-by-1 array.
%       tnum(j,1) = k; means the j-th element is belong to the k-th phase
%
%   vert2 - Node data (2nd order element). P-by-2 array. 
%       Due to new vertices, the length of vert2 is much longer than vert.
%       vert2(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   tria2 - Node numbering for each triangle (2nd order element). M-by-6 array.
%       tria2(j,1:6) = [node_numbering_of_6_nodes] of the j-th element
%
%   mesh1, mesh2 - FEMesh objects, which is the output of function generateMesh
%          (https://www.mathworks.com/help/pde/ug/pde.femesh.html)
%                   You can use pdemesh(mesh1) to view mesh.
%
%   mesh1 - FEMesh object for linear elements
%
%   mesh2 - FEMesh object for 2nd order elements
%
%
% You can use function plotMeshes( vert, tria, tnum ) to view mesh.
%
% Author:
%   Jiexian Ma, mjx0799@gmail.com, Jan 2025
% Cite As
%   Jiexian Ma (2025). Im2mesh (2D image to triangular meshes) (https://ww
%   w.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-t
%   riangular-meshes), MATLAB Central File Exchange. Retrieved Jan 23, 202
%   5.
%   

    % ---------------------------------------------------------------------
    % Use function regroup to organize cell array poly_node, poly_edge into
    % array node, edge.
    [ node, edge, ~ ] = regroup( poly_node, poly_edge );

    % Note:
    % node, edge - array. Nodes and edges of all polygonal boundary
    % node, edge doesn't record phase info.
    % node - V-by-2 array. x,y coordinates of vertices. 
    %        Each row is one vertex.
    % edge - E-by-2 array. Node numbering of two connecting vertices of
    %        edges. Each row is one edge.

    % ---------------------------------------------------------------------
    % Delaunay triangulation in 2D
    DT = delaunayTriangulation(node,edge);
    % triplot(DT)

    tnodes = DT.Points';
    telements = DT.ConnectivityList';
    
    % ---------------------------------------------------------------------
    % label regionID
    regionID = zeros( size(DT.ConnectivityList,1), 1 );

    C = incenter(DT);
    for i = 1: size(C,1)
        for j = 1: length(pcell)
            if isinterior(pcell{j},C(i,1),C(i,2))   % need improve
                regionID( i ) = j;
                break;
            end
        end
    end

    regionID = regionID';
    
    % ---------------------------------------------------------------------
    % convert to geometry object in pde model
    model = createpde;
    geometryFromMesh(model,tnodes,telements,regionID);
    % pdegplot(model,'FaceLabels','on')
    
    % ---------------------------------------------------------------------
    % generate linear element
    % ---------------------------------------------------------------------
    % generate mesh using matlab built-in function
    % mesh1 is an FEMesh object
    mesh1 = generateMesh( model, 'Hgrad', hgrad, 'Hmax', hmax, ... 
                                'Hmin', hmin, 'GeometricOrder', 'linear' );
    % figure
    % pdemesh(model)
    
    % ---------------------------------------------------------------------
    % obtain variable tnum
    % tnum is marker for phase
    tnum = zeros( size(mesh1.Elements,2), 1 );
    count = 1;

    for i = 1: length(pcell)
        for j = 1: pcell{i}.NumRegions

            indEf = findElements(mesh1,'region','face',count);
            tnum(indEf) = i;
            count = count + 1;
        end
    end
    
    % ---------------------------------------------------------------------
    % obtain variable vert, tria
    vert = mesh1.Nodes';
    tria = mesh1.Elements';
    % plotMeshes( vert, tria, tnum );
    % ---------------------------------------------------------------------

    % ---------------------------------------------------------------------
    % generate quadratic element
    % ---------------------------------------------------------------------
    % generate mesh using matlab built-in function
    % mesh1 is an FEMesh object
    mesh2 = generateMesh( model, 'Hgrad', hgrad, 'Hmax', hmax, ... 
                                'Hmin', hmin, 'GeometricOrder', 'quadratic' );
    % figure
    % pdemesh(model)
    % ---------------------------------------------------------------------
    % obtain variable vert2, tria2
    vert2 = mesh2.Nodes';
    tria2 = mesh2.Elements';
    % plotMeshes( vert2, tria2, tnum );
    % ---------------------------------------------------------------------

end

