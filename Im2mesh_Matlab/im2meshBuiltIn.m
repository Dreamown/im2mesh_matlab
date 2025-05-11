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
%                               Boolean. Whether to avoid sharp corner when 
%                               simplifying polygon.
%                               Sharp corner in some cases will make MESH2D
%                               not able to converge.
%                               Default value: false
%
%   opt.lambda - Taubin smoothing. Default value: 0.5
%   opt.mu     - Taubin smoothing. Default value: -0.5
%   opt.iters  - Taubin smoothing. Default value: 100
%
%   opt.thresh_turn - For funtion smoothBounds
%                     Threshold value for the number of turning points in 
%                     a polyline during polyline smoothing.
%                     Default value: 0
%
%   opt.thresh_vert_smooth - For funtion smoothBounds
%                            Threshold value for the number of vertices in 
%                            a polyline during polyline smoothing.
%                            It can be set as an integer or an array with 
%                            two elements. See section 4 in Tutorial.pdf
%                            Default value: 0
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
%   opt.thresh_vert_simplify - For funtion simplifyBounds
%                              Threshold value for number of vertices in
%                              a polyline during polyline simplification.
%                              It can be set as an integer or an array with 
%                              two elements. See section 4 in Tutorial.pdf
%                              Default value: 0
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
    
    checkOutdatedArg( opt );

    % --------------------------------------------------------------------
    % verify field names and set values for opt
    opt = setOption( opt );
    
    % --------------------------------------------------------------------
    % image to polygon boundary
    boundsRaw = im2Bounds( im );
    boundsCtrlP = getCtrlPnts( boundsRaw, opt.tf_avoid_sharp_corner, size(im) );
    
    % smooth boundary
    boundsSmooth = smoothBounds( boundsCtrlP, opt.lambda, opt.mu, opt.iters, ...
                    opt.thresh_turn, opt.thresh_vert_smooth );

    % simplify polygon boundary
    boundsSimplified = simplifyBounds( boundsSmooth, opt.tolerance, ...
                                            opt.thresh_vert_simplify );
    boundsSimplified = delZeroAreaPoly( boundsSimplified );

    % clear up redundant vertices
    % only control points and turning points will remain
    boundsClear = getCtrlPnts( boundsSimplified );
    boundsClear = simplifyBounds( boundsClear, 0.5*opt.tolerance, ...
                                            opt.thresh_vert_simplify );
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
    % generate mesh
    [vert,tria,tnum,vert2,tria2,model1,model2] = bounds2meshBuiltIn( boundsClear, opt.hgrad, opt.hmax, opt.hmin );

    % --------------------------------------------------------------------
end

function checkOutdatedArg( opt )
% checkOutdatedArg: check oudated arguments

    if ~isempty(opt)
        if isfield( opt, 'threshold_num_turning' )
            error('Argument opt.threshold_num_turning is deprecated. Please use opt.thresh_turn instead.');
        end

        if isfield( opt, 'threshold_num_vert_Smo' )
            error('Argument opt.threshold_num_vert_Smo is deprecated. Please use opt.thresh_vert_smooth instead.');
        end

        if isfield( opt, 'threshold_num_vert_Sim' )
            error('Argument opt.threshold_num_vert_Sim is deprecated. Please use opt.thresh_vert_simplify instead.');
        end
    end
end

function new_opt = setOption( opt )
% setOption: verify field names in opt and set values in new_opt according
% to opt

    % initialize new_opt with default field names & value 
    new_opt.tf_avoid_sharp_corner = false;
    new_opt.lambda = 0.5;
    new_opt.mu = -0.5;
    new_opt.iters = 100;
    new_opt.thresh_turn = 0;
    new_opt.thresh_vert_smooth = 0;
    new_opt.tolerance = 0.3;
    new_opt.thresh_vert_simplify = 0;
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

    % Verify field names in opt and set values in new_opt.
    % Compare the field name of opt with new_opt using for loop.
    % If a field name of opt exist in new_opt, assign the that field value 
    % in opt to new_opt.
    % If a field name of opt not exist in new_opt, show error.
    
    for i = 1: length(nameC)
        if isfield( new_opt, nameC{i} )
            value = getfield( opt, nameC{i} );
            new_opt = setfield( new_opt, nameC{i}, value );
        else
            error("Field name %s in opt is not correct.", nameC{i});
        end
    end

end