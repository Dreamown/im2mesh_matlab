function [vert,tria,tnum,vert2,tria2] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit )
% poly2mesh: generate meshes of parts defined by polygons, 
%        	 adapted from the demo of mesh2d-master
%            (Darren Engwirda, https://github.com/dengwirda/mesh2d) 
% 
% input:
%   poly_node, poly_edge - cell array, nodes and edges of polygonal boundary
%   poly_node{i}, poly_edge{i} corresponds to polygons in the i-th phase.
%   poly_node{i} - N-by-2 array. x,y coordinates of vertices in polygon.
%                  Each row is one vertex.
%   poly_edge{i} - M-by-2 array. Node numbering of two connecting vertices
%                  in polygon. Each row is one edge.
%   
%   hmax - for poly2mesh, affact maximum mesh-size
%   
%   mesh_kind - meshing algorithm
%               value: 'delaunay' or 'delfront' 
%               "standard" Delaunay-refinement or "Frontal-Delaunay" technique
%   
%   grad_limit - scalar gradient-limit for mesh
%
% output:
%   vert, tria define linear elements. vert2, tria2 define 2nd order elements.
%
%     vert: Mesh nodes (for linear element). It’s a Nn-by-2 matrix, where 
%           Nn is the number of nodes in the mesh. Each row of vert 
%           contains the x, y coordinates for that mesh node.
%     
%     tria: Mesh elements (for linear element). For triangular elements, 
%           it s a Ne-by-3 matrix, where Ne is the number of elements in 
%           the mesh. Each row in eleL contains the indices of the nodes 
%           for that mesh element.
%     
%     tnum: Label of phase. Ne-by-1 array, where Ne is the number of 
%           elements
%       tnum(j,1) = k; means the j-th element belongs to the k-th phase.
%     
%     vert2: Mesh nodes (for quadratic element). It’s a Nn-by-2 matrix.
%     
%     tria2: Mesh elements (for quadratic element). For triangular 
%           elements, it s a Ne-by-6 matrix.
%
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % assemble triangulations for multi-part geometry definitions.
    %---------------------------------------------- create geom.
    % libpath();
    
    % Use function regroup to organize cell array poly_node, poly_edge into
    % array node, edge & part.
    [ node, edge, part ] = regroup( poly_node, poly_edge );
    
    % Note:
    % node, edge - array. Nodes and edges of all polygonal boundary
    % node, edge doesn't record phase info. Phase info is recorded by part.
    % node - V-by-2 array. x,y coordinates of vertices. 
    %        Each row is one vertex.
    % edge - E-by-2 array. Node numbering of two connecting vertices of
    %        edges. Each row is one edge.
    % part - cell array. Used to record phase info.
    %        part{i} is edge indexes of the i-th phase, indicating which 
    %        edges make up the boundary of the i-th phase.
	
    %---------------------------------------------- do size-fun.
 
    % meshing algorithm
    % "standard" Delaunay-refinement or "Frontal-Delaunay" technique
    option.kind = mesh_kind;    % 'delaunay' or 'delfront' 
                                % default value is 'delaunay'
    
    option.dhdx = grad_limit;   % dhdx is scalar gradient-limit
                                % default +0.2500
    
    % LFSHFN2 routine is used to create mesh-size functions 
    % based on an estimate of the "local-feature-size" 
    % associated with a polygonal domain. 
    [vlfs,tlfs, hlfs] = lfshfn2( node, edge, part, option ) ;
    
    hlfs = min(hmax,hlfs) ;
    
    [slfs] = idxtri2(vlfs,tlfs) ;
    
    %---------------------------------------------- do mesh-gen.
    hfun = @trihfn2;
    
    [vert,etri,tria,tnum] = refine2(node,edge,part,[],hfun, ...
                                    vlfs,tlfs,slfs,hlfs);
                         
    %---------------------------------------------- do mesh-opt.
    % SMOOTH2 routine provides iterative mesh "smoothing" capabilities, 
    % seeking to improve triangulation quality by adjusting the vertex 
    % positions and mesh topology.
    [vert,~,tria,tnum] = smooth2(vert,etri,tria,tnum);
    
    %---------------------------------------------- get 2nd order element
    [ vert2, tria2 ] = insertNode( vert, tria );

end