function [ vert, tria, tnum, vert2, tria2, model1, model2 ] = im2meshBuiltIn( im, opt )
% im2meshBuiltIn: generate triangular mesh based on segmented image
%                 using matlab built-in function generateMesh
%
% usage:
%   [ vert, tria, tnum ] = im2meshBuiltIn( im );   % this use default setting
%   [ vert, tria, tnum ] = im2meshBuiltIn( im, opt );
%
%   [ vert, tria, tnum, vert2, tria2 ] = im2meshBuiltIn( im );   % this use default setting
%   [ vert, tria, tnum, vert2, tria2 ] = im2meshBuiltIn( im, opt );
%
% input
%   im - grayscale segmented image
%
%   opt - a structure array. It is the options for im2meshBuiltIn.
%         It stores parameter settings for im2meshBuiltIn.
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
%   opt.select_phase - Default value: []
%     
%  Please check documentation of matlab built-in function generateMesh for 
%  parameter hgrad, hmax, and hmin. 
%  https://www.mathworks.com/help/pde/ug/pde.pdemodel.generatemesh.html
%
%   opt.hgrad       % For funtion poly2meshBuiltIn
%                   % Mesh growth rate. Default value: 1.25
%     
%   opt.hmax        % For funtion poly2meshBuiltIn
%                   % Target maximum mesh edge length. Default value: 500
% 
%   opt.hmin        % For funtion poly2meshBuiltIn
%                   % Target minimum mesh edge length. Default value: 1
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
%     model1 - PDE model object with linear elements
%     
%     model2 - PDE model object with 2nd order elements
%     
%     PDE model object: https://www.mathworks.com/help/pde/ug/pde.pdemodel.html
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
    boundsClear = getCtrlPnts( boundsSimplified, false );
    boundsClear = simplifyBounds( boundsClear, 0 );
    
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
    % get nodes and edges of polygonal boundary
    [ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );
    % Convert boundaries to a cell array of polyshape object
    pcell = bound2polyshape( boundsClear );
    % generate mesh
    [vert,tria,tnum,vert2,tria2,~,~,model1,model2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, ...
                                        opt.hgrad, opt.hmax, opt.hmin );

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
    new_opt.hgrad = 1.25;
    new_opt.hmax = 500;
    new_opt.hmin = 1;

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