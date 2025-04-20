function [ vert, tria, tnum, vert2, tria2, conn, bounds ] = im2mesh( im, opt )
% im2mesh: generate triangular mesh based on grayscale segmented image
%          Mesh generator: MESH2D (https://github.com/dengwirda/mesh2d)
%
% usage:
%   [ vert, tria, tnum ] = im2mesh( im );   % default opt setting
%   [ vert, tria, tnum ] = im2mesh( im, opt );
%
%   [ vert, tria, tnum, vert2, tria2 ] = im2mesh( im );  % default opt setting
%   [ vert, tria, tnum, vert2, tria2 ] = im2mesh( im, opt );
%     
%   [ vert, tria, tnum, vert2, tria2, conn, bounds ] = im2mesh( im );
%   [ vert, tria, tnum, vert2, tria2, conn, bounds ] = im2mesh( im, opt );
%     
%   % If we do not need to generate mesh 
%   % but we want to check the simplified polygonal boundary
%   opt.tf_mesh = false;
%   bounds = im2mesh( im, opt );
%
% input:
%   im - grayscale segmented image
%   
%   opt - a structure array. It is the options for im2mesh.
%         It stores parameter settings for im2mesh.
%
%   opt.tf_avoid_sharp_corner - For function getCtrlPnts
%                               Whether to avoid sharp corner when 
%                               simplifying polygon.
%                               Value: true or false
%                               Sharp corner in some cases will make MESH2D
%                               not able to converge.
%                               Default value: false
%
%   opt.lambda - Taubin smoothing. Default value: 0.5
%   opt.mu     - Taubin smoothing. Default value: -0.5
%   opt.iters  - Taubin smoothing. Default value: 100
%
%   opt.threshold_num_turning - For funtion smoothBounds
%                               Threshold value for the number of turning
%                               points in a polyline. 
%                               Default value: 0
%
%   opt.threshold_num_vert_Smo - For funtion smoothBounds
%                                Threshold value for the number of 
%                                vertices in a polyline.
%                                Default value: 0
%     
%   opt.tolerance - For funtion simplifyBounds
%                   Tolerance for polygon simplification.
%                   Check Douglas-Peucker algorithm.
%                   If u don't need to simplify, try tolerance = eps.
%                   If the value of tolerance is too large, some polygons
%                   will become line segment after simplification, and 
%                   these polygons will be deleted by function 
%                   delZeroAreaPoly.
%                   Default value: 0.3
%
%   opt.threshold_num_vert_Sim - For funtion simplifyBounds
%                                Threshold value for number of vertices in
%                                a polyline. 
%                                Default value: 0
%
%   opt.hmax - Maximum mesh-size. Default value: 500
%     
%   opt.mesh_kind - Method used to create mesh-size functions based on 
%                   an estimate of the "local-feature-size".
%                   Value: 'delaunay' or 'delfront' 
%                   Delaunay-refinement or "Frontal-Delaunay" technique
%                   Default value: 'delaunay'
% 
%   opt.grad_limit - Scalar gradient-limit for mesh. Default value: 0.25
%                  
%   opt.select_phase - Select phase for meshing
%                      Parameter type: vector
%                      If 'select_phase' is [], all the phases will be
%                      chosen to perform meshing
%                      'select_phase' is an index vector for sorted 
%                      grayscales (ascending order) in an image.
%                      For example, an image with grayscales of 40, 90,
%                      200, 240, 255. If u're interested in 40, 200, and
%                      240, then set 'select_phase' as [1 3 4]. Those 
%                      phases corresponding to grayscales of 40, 200, 
%                      and 240 will be chosen to perform meshing.
%                      Default value: []
%
%   opt.tf_mesh - Whether to mesh. Boolean.
%                 If true, meshing, else, no meshing & return boundsClear
%                 Default value: true
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
%           the mesh. Each row in tria contains the indices of the nodes 
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
%     conn: C-by-2 array of constraining edges. Each row defines an edge.
%
%     bounds: Nesting cell array of simplified polygonal boundaries.
%         bounds{i}{j} is one of the polygonal boundaries,  
%         corresponding to region with certain gray level in image im.
%         Polygons in bounds{i} have the same grayscale level.
%         bounds{i}{j}(:,1) is x coordinate (column direction).
%         bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%         plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%         polygon. Use plotBounds( bounds ) to view all polygons.
%
%
% You can use function plotMeshes( vert, tria, tnum ) to view mesh.
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % --------------------------------------------------------------------
    % check the number of inputs
    if nargin == 1
        opt = [];
    elseif nargin == 2
        % normal case
    else
        error("check the number of inputs");
    end

    % --------------------------------------------------------------------
    % verify field names and set values for opt
    opt = setOption( opt );
    
    % --------------------------------------------------------------------
    % image to polygon boundary
    boundsRaw = im2Bounds( im );
    boundsCtrlP = getCtrlPnts( boundsRaw, opt.tf_avoid_sharp_corner, size(im) );
    
    % smooth boundary
    boundsSmooth = smoothBounds( boundsCtrlP, opt.lambda, opt.mu, opt.iters, ...
                    opt.threshold_num_turning, opt.threshold_num_vert_Smo );

    % simplify polygon boundary
    boundsSimplified = simplifyBounds( boundsSmooth, opt.tolerance, ...
                                            opt.threshold_num_vert_Sim );
    boundsSimplified = delZeroAreaPoly( boundsSimplified );

    % clear up redundant vertices
    % only control points and turning points will remain
    boundsClear = getCtrlPnts( boundsSimplified );
    boundsClear = simplifyBounds( boundsClear, 0.5*opt.tolerance, ...
                                            opt.threshold_num_vert_Sim );
    
    % --------------------------------------------------------------------
    % select phase
    if isempty(opt.select_phase)
        % = do nothing = all phases will be chosen
    elseif ~isvector(opt.select_phase)
        error("select_phase is not a vector")
    elseif length(opt.select_phase) > length(boundsClear)
        error("length of select_phase is larger than the number of phases")
    else
        boundsClear = boundsClear( opt.select_phase );
    end
    
    % --------------------------------------------------------------------
    bounds = boundsClear;
    
    if opt.tf_mesh == 1     % generate mesh
        optB2M.mesh_kind = opt.mesh_kind;
        [ vert,tria,tnum,vert2,tria2,conn ] = bounds2mesh( bounds, opt.hmax, opt.grad_limit, optB2M );
    
    else
        % no meshing
        % return bounds as output parameter
        if nargout ~= 1
            error('In this case, function im2mesh returns only one output parameter.');
        else
            vert = bounds;
            return
        end
    end
    
    % --------------------------------------------------------------------
end


function new_opt = setOption( opt )
% setOption: verify field names in opt and set values in new_opt according
% to opt

    % initialize new_opt with default field names & value 
    new_opt.tf_avoid_sharp_corner = false;
    new_opt.lambda = 0.5;
    new_opt.mu = -0.5;
    new_opt.iters = 100;
    new_opt.threshold_num_turning = 0;
    new_opt.threshold_num_vert_Smo = 0;
    new_opt.tolerance = 0.3;
    new_opt.threshold_num_vert_Sim = 0;
    new_opt.select_phase = [];
    new_opt.grad_limit = 0.25;
    new_opt.hmax = 500;
    new_opt.mesh_kind = 'delaunay';
    new_opt.tf_mesh = true;

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


