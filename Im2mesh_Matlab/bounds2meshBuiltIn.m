function [vert,tria,tnum,vert2,tria2,model1,model2] = bounds2meshBuiltIn( bounds, hgrad, hmax, hmin, opt )
% bounds2meshBuiltIn: generate meshes of parts defined by polygonal boundary.
%        	          Mesh generator: generateMesh
% 
% usage:
%  [vert,tria,tnum] = bounds2meshBuiltIn( bounds, hgrad, hmax, hmin);
%  [vert,tria,tnum,vert2,tria2,model1,model2] = bounds2meshBuiltIn( bounds, hgrad, hmax, hmin);
%  [vert,tria,tnum,vert2,tria2,model1,model2] = bounds2meshBuiltIn( bounds, hgrad, hmax, hmin, opt );
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
%   (Please check documentation of matlab built-in function generateMesh.)
%   hgrad       % Mesh growth rate
%   hmax        % Target maximum mesh edge length
%   hmin        % Target minimum mesh edge length
%
%   opt - a structure array. It is the options for bounds2meshBuiltIn.
%         It stores extra parameter settings for bounds2meshBuiltIn.
%
%   opt.tf_padBG - Boolean. Whether to add padding to background to fix 
%                  crash issue.
%                  Default value: true
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

    % ---------------------------------------------------------------------
    % check the number of inputs
    if nargin == 4
        opt = [];
    elseif nargin == 5
        % use as input
    else
        error("Check the number of inputs");
    end
    
    % ---------------------------------------------------------------------
    % verify field names and set values for opt
    opt = setOption( opt );

    % ---------------------------------------------------------------------
    if opt.tf_padBG == 1
        % add padding to background to fix crash issue
        bounds = padBackground( bounds );
    end
    
    % ---------------------------------------------------------------------
    % create geometry (planar straight-line graph)
    [ poly_node, poly_edge ] = getPolyNodeEdge( bounds );
    [ node, edge, part ] = regroup( poly_node, poly_edge );
    
    % ---------------------------------------------------------------------
    % generate initial mesh using function deltri1
    [vert,~,tria,tnum] = deltri1( node, edge, part );
    
    % ---------------------------------------------------------------------
    % convert to matlab pde geometry and generate mesh
    model = createpde;
    geometryFromMesh( model, vert', tria', tnum' );
    % pdegplot(model,'FaceLabels','on')

    generateMesh( model, 'Hgrad', hgrad, 'Hmax', hmax, ... 
                            'Hmin', hmin, 'GeometricOrder', 'linear' );
    % pdemesh(model)
    
    % ---------------------------------------------------------------------
    % obtain variable tnum, which is labels for phase

    vert = model.Mesh.Nodes';
    tria = model.Mesh.Elements';
    [vert,tria,tnum] = addPhaseLabel(vert,tria,node,edge,part);

    % ---------------------------------------------------------------------
    % remove background padding
    if opt.tf_padBG == 1
        [vert,tria,tnum] = removeLastPhase(vert,tria,tnum);
    end

    % ---------------------------------------------------------------------
    % Get 2nd order elements
    [ vert2, tria2 ] = insertNode( vert, tria );

    % ---------------------------------------------------------------------
    % create pde model object for export
    model1 = createpde;     % linear
    geometryFromMesh( model1, vert', tria', tnum' );

    model2 = createpde;     % quadratic
    geometryFromMesh( model2, vert2', tria2', tnum' );

    % ---------------------------------------------------------------------
end

function new_opt = setOption( opt )
% setOption: verify field names in opt and set values in new_opt according
% to opt

    % initialize new_opt with default field names & value 
    new_opt.tf_padBG = 1;

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


function newB = padBackground( bounds )
% padBackground: add padding to background to fix crash issue

    % --------------------------------------------------------------------
    % create rectangle (psBG) at background
    [xmin,xmax,ymin,ymax] = xyRange( bounds );

    x_range = xmax - xmin;
    y_range = ymax - ymin;
    x_pad = x_range/2;
    y_pad = y_range/2;

    vertex = [ xmin-x_pad, ymin-y_pad;
               xmax+x_pad, ymin-y_pad;
               xmax+x_pad, ymax+y_pad;
               xmin-x_pad, ymax+y_pad;
               ];
    psBG = polyshape(vertex);

    % --------------------------------------------------------------------
    % boolean to remove overlaps
    psCell = bound2polyshape( bounds );
    
    for i = 1: length(psCell)
        psBG = subtract( psBG, psCell{i} );
    end
    
    % add to the end of psCell
    psCell{end+1} = psBG;

    % --------------------------------------------------------------------
    % export
    newB = polyshape2bound( psCell );

    tol = 1e-6;   % distance tolerance for intersect
    newB = addIntersectPnts( newB, tol );
    % --------------------------------------------------------------------
end

function [vert,tria,tnum] = addPhaseLabel(vert,tria,node,edge,part)
% add phase label to mesh according to node, edge, part

    tnum = zeros(size(tria,+1),+1);

    % tria midpoint
    tmid = vert(tria(:,1),:) ...
         + vert(tria(:,2),:) ...
         + vert(tria(:,3),:) ;
    tmid = tmid / +3.0;
    
    % calc. "inside" status
    PSLG = edge;
    for ppos = 1: length(part)
       [stat] = inpoly2( tmid, node, PSLG(part{ppos},:) );
       tnum(stat)  = ppos;
    end
    
    % keep "interior" tria's
    tria = tria(tnum>+0,:) ;
    tnum = tnum(tnum>+0,:) ;
end

function [vert,tria,tnum] = removeLastPhase(vert,tria,tnum)
% removeLastPhase: remove the last phase in the mesh

    tn_BG = max(tnum);     % phase number of background padding
    tf_BG = (tnum == tn_BG);
    
    tria( tf_BG, :) = [];
    tnum( tf_BG ) = [];

    % remove redundant vertex and update tria, tnum
    % 1. Find all node indices that the mesh actually uses
    keep = unique(tria(:));     % column vector of used node IDs
    
    % 2. Build a lookup table that maps old IDs -> new consecutive IDs
    map = zeros( size(vert,1), 1 );
    map(keep) = 1:numel(keep);  % assign new IDs only to kept nodes
    
    % 3. Update
    vert = vert( keep, :);
    tria = map(tria);
end


