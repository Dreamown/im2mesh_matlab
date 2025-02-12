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
    PSLG = edge;
    vert = node; 
    conn = PSLG;

    [vert,~,tria,tnum] = deltri1( vert, conn, node, PSLG, part );
    tnodes = vert';
    telements = tria';
    regionID = tnum';
    
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

function [vert,conn,tria,tnum] = deltri1(varargin)
% deltri1 is the simpfied version of deltri2
%DELTRI2 compute a constrained 2-simplex Delaunay triangula-
%tion in the two-dimensional plane.
%   [VERT,CONN,TRIA,TNUM]=DELTRI2(VERT,CONN,NODE,PSLG,PART)
%   computes the Delaunay trianguation {VERT,TRIA}, the con-
%   straints CONN, and the "inside" status vector TNUM. VERT
%   is an V-by-2 array of XY coordinates to be triangulated,
%   TRIA is a T-by-3 array of vertex indexing, where each
%   row defines a triangle, such that VERT(TRIA(II,1),:),
%   VERT(TRIA(II,2),:) and VERT(TRIA(II,3),:) are the coord-
%   inates of the II-TH triangle. CONN is a C-by-2 array of
%   constraining edges, where each row defines an edge, as
%   per TRIA. The additional arguments NODE,PSLG and PART
%   define a (mutliply-connected) polygonal region, where
%   NODE is an N-by-2 array of vertices and PSLG is a P-by-2
%   array of edges (a piecewise-straight-line-graph), where
%   each row defines an edge as a pair of indices into NODE.
%   PART is a cell-array of polygonal "parts", where each
%   element PART{KK} is an array of edge indices defining a
%   polygonal region. PSLG(PART{KK},:) is the set of edges
%   in the KK-TH part. TNUM is a T-by-1 array of part index-
%   ing, such that TNUM(II) is the index of the part in whi-
%   ch the II-TH triangle resides.
%
%   See also DELAUNAYTRIANGULATION, DELAUNAYTRI, DELAUNAYN

%   Darren Engwirda : 2017 --
%   Email           : d.engwirda@gmail.com
%   Last updated    : 08/07/2018


    %---------------------------------------------- extract args
     vert = varargin{1};
     conn = varargin{2};
     node = varargin{3};
     PSLG = varargin{4};
     part = varargin{5};
    %------------------------------------ compute Delaunay tria.
    if (exist('delaunayTriangulation') == +2 )
        dtri = ...
        delaunayTriangulation(vert,conn) ;
        vert = dtri.Points;
        conn = dtri.Constraints;
        tria = dtri.ConnectivityList;
    else
        error('function delaunayTriangulation not exist')
    end

    %------------------------------------ calc. "inside" status!
    tnum = zeros(size(tria,+1),+1) ;

    tmid = vert(tria(:,1),:) ...
         + vert(tria(:,2),:) ...
         + vert(tria(:,3),:) ;
    tmid = tmid / +3.0;

    for ppos = 1 : length(part)
       [stat] = inpoly2( tmid, node, PSLG(part{ppos},:) );
       tnum(stat)  = ppos ;
    end
    %------------------------------------ keep "interior" tria's
    tria = tria(tnum>+0,:) ;
    tnum = tnum(tnum>+0,:) ;

    %------------------------------------ flip for correct signs
    area = triarea(vert,tria) ;

    tria(area<0.,:) = tria(area<0.,[1,3,2]) ;

end



