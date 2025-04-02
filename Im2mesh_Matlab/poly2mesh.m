function [vert,tria,tnum,vert2,tria2,etri] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit, opt )
% poly2mesh: generate meshes of parts defined by polygons, 
%        	 adapted from the demo of MESH2D
%            (Darren Engwirda, https://github.com/dengwirda/mesh2d) 
%
% usage:
%   [vert,tria,tnum,vert2,tria2] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit );
%   [vert,tria,tnum,vert2,tria2] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit, opt );
% 
% input:
%   poly_node, poly_edge - cell array, nodes and edges of polygonal boundary
%   poly_node{i}, poly_edge{i} corresponds to polygons in the i-th phase.
%   poly_node{i} - N-by-2 array. x,y coordinates of vertices in polygon.
%                  Each row is one vertex.
%   poly_edge{i} - M-by-2 array. Node numbering of two connecting vertices
%                  in polygon. Each row is one edge.
%   
%   hmax - maximum mesh-size
%   
%   mesh_kind - Method used to create mesh-size functions based on 
%               an estimate of the "local-feature-size".
%               value: 'delaunay' or 'delfront' 
%               "standard" Delaunay-refinement or "Frontal-Delaunay" technique
%   
%   grad_limit - scalar gradient-limit for mesh
%
%   opt - a structure array. It is the options for poly2mesh.
%         It stores extra parameter settings for poly2mesh.
%
%   opt.tf_smooth - Boolean. Value: 0 or 1. Whether improve triangulation 
%                   quality by adjusting the vertex positions and mesh 
%                   topology (hill-climbing type optimisation). 
%                   Default value: 1
%
%   opt.num_split - number of splitting for refining mesh.
%                   Each triangle is split into four new sub-triangles.
%                   Default value: 0
%
%   opt.local_max - n-by-2 array, used to specify max mesh size in a part.
%                   '[2, 0.5; 3, 0.15]' means that max mesh size in part 2
%                   is 0.5; max mesh size in part 3 is 0.15.
%                   When set as [], this parameter will be ignored.
%                   Default value: []
%
%   opt.disp - verbosity. Set as 'inf' to mute verbosity.
%              Default value: 10
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
%   etri: C-by-2 array of constraining edges, where each row defines an edge
%
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % check the number of inputs
    if nargin == 5          % default case. Smooth but no refine.
        opt = [];
    elseif nargin == 6
        % use as input
    else
        error("check the number of inputs");
    end

    % ---------------------------------------------------------------------
    % verify field names and set values for opt
    opt = setOption( opt );

    % ---------------------------------------------------------------------
    % create geometry
    
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
	
    % ---------------------------------------------------------------------
    % Create mesh size function
    % LFSHFN2 routine is used to create mesh-size functions 
    % based on an estimate of the "local-feature-size" 
    % associated with a polygonal domain. 
    
    optLfs.kind = mesh_kind;    % Method for mesh-size functions
                                % Value: 'delaunay' or 'delfront' 
                                % default value is 'delaunay'
    
    optLfs.dhdx = grad_limit;   % dhdx is scalar gradient-limit
                                % default +0.2500

    optLfs.disp = opt.disp;
    
    [vlfs,tlfs, hlfs] = lfshfn2( node, edge, part, optLfs );

    % modify mesh size field hlfs according to opt.local_max
    if ~isempty(opt.local_max)
        % create a vector for local max mesh size
        size_vec = hmax * ones( size(hlfs,1), 1 );
        
        numPart2Refine = size( opt.local_max, 1 );
        
        % set size_vec
        for i = 1: numPart2Refine
	        idx = opt.local_max(i,1);    % part index
	        lmax = opt.local_max(i,2);   % local max mesh size
            
	        tf_in = inpoly2( vlfs, node, edge(part{idx},:) );
	        size_vec(tf_in) = lmax;
        end
        
        hlfs = min( size_vec, hlfs );

        % push gradient limits
        hlfs = limhfn2(vlfs,tlfs,hlfs,grad_limit) ;
    end
    
    hlfs = min(hmax,hlfs);
    
    [slfs] = idxtri2(vlfs,tlfs);
    
    % ---------------------------------------------------------------------
    % Mesh genenration
    
    hfun = @trihfn2;
    
    optRef.disp = opt.disp;
    [vert,etri,tria,tnum] = refine2(node,edge,part,optRef,hfun, ...
                                    vlfs,tlfs,slfs,hlfs);
                         
    % ---------------------------------------------------------------------
    % Smooth mesh
    % SMOOTH2 routine provides iterative mesh "smoothing" capabilities, 
    % seeking to improve triangulation quality by adjusting the vertex 
    % positions and mesh topology.
    
    if opt.tf_smooth ~= 0
        optSmo.disp = opt.disp;
        [vert,etri,tria,tnum] = smooth2(vert,etri,tria,tnum,optSmo);
    end
    
    % ---------------------------------------------------------------------
    % Refine by splitting (quadtree-type mesh refinement)
    % TRIDIV2 routine is used to refine existing trangulations. 
    % Each triangle is split into four new sub-triangles, such that 
    % element shape is preserved.
    
    if opt.num_split > 0
        vnew = vert;
        enew = etri;
        tnew = tria;
        
        for i = 1: opt.num_split
            [vnew,enew,tnew,tnum] = tridiv2(vnew,enew,tnew,tnum);
        end
        
        if opt.tf_smooth ~= 0
            optSmo.disp = opt.disp;
            [vnew,enew,tnew,tnum] = smooth2(vnew,enew,tnew,tnum,optSmo);
        end
        
        vert = vnew;
        etri = enew;
        tria = tnew;
    end
    
    % ---------------------------------------------------------------------
    % Get 2nd order elements
    [ vert2, tria2 ] = insertNode( vert, tria );

    % ---------------------------------------------------------------------
end


function new_opt = setOption( opt )
% setOption: verify field names in opt and set values in new_opt according
% to opt

    % initialize new_opt with default field names & value 
    new_opt.tf_smooth = true;
    new_opt.num_split = 0;
    new_opt.local_max = [];
    new_opt.disp = 10;

    if isempty(opt)
        return
    end

    if ~isstruct(opt)
        error("opt is not a structure array. Not valid input.")
    end

    % get the field names of opt
    nameC = fieldnames(opt);

    % verify field names in opt and set values in new_opt
    % compare the field name of opt with new_opt using for loop
    % if a field name of opt exist in new_opt, assign the that field value 
    % in opt to new_opt
    % if a field name of opt not exist in new_opt, show error

    for i = 1: length(nameC)
        if isfield( new_opt, nameC{i} )
            value = getfield( opt, nameC{i} );
            new_opt = setfield( new_opt, nameC{i}, value );
        else
            error("Field name %s in opt is not correct.", nameC{i});
        end
    end

end





