function [vert,tria,tnum,vert2,tria2,mesh1,mesh2,model1,model2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, hgrad, hmax, hmin )
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
%   mesh1 - FEMesh object for linear elements
%
%   mesh2 - FEMesh object for 2nd order elements
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
    % Delaunay triangulation in 2D using function deltri1
    [vert,~,tria,tnum] = deltri1( node, edge, part );
    
    tnodes = vert';
    telements = tria';
    regionID = tnum';

    % ---------------------------------------------------------------------
    % generate linear element
    % ---------------------------------------------------------------------
    % convert to geometry object in pde model
    model1 = createpde;
    geometryFromMesh(model1,tnodes,telements,regionID);
    % pdegplot(model1,'FaceLabels','on')

    % generate mesh using matlab built-in function
    % mesh1 is an FEMesh object
    % model1 is a PDE model object
    mesh1 = generateMesh( model1, 'Hgrad', hgrad, 'Hmax', hmax, ... 
                                'Hmin', hmin, 'GeometricOrder', 'linear' );
    % pdemesh(model1)
    
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
    % convert to geometry object in pde model
    model2 = createpde;
    geometryFromMesh(model2,tnodes,telements,regionID);
    % pdegplot(model2,'FaceLabels','on')

    % generate mesh using matlab built-in function
    % mesh2 is an FEMesh object
    % model2 is a PDE model object
    mesh2 = generateMesh( model2, 'Hgrad', hgrad, 'Hmax', hmax, ... 
                                'Hmin', hmin, 'GeometricOrder', 'quadratic' );
    % pdemesh(model2)

    % ---------------------------------------------------------------------
    % obtain variable vert2, tria2
    vert2 = mesh2.Nodes';
    tria2 = mesh2.Elements';
    % plotMeshes( vert2, tria2, tnum );
    % ---------------------------------------------------------------------

end
