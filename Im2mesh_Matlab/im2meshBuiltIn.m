function [ vert, tria, tnum, vert2, tria2 ] = im2meshBuiltIn( im, opt )
% im2meshBuiltIn: generate triangular mesh based on segmented image
%                 using matlab built-in function generateMesh
% usage:
%   [ vert, tria, tnum ] = im2meshBuiltIn( im );   % this use default setting
%   [ vert, tria, tnum ] = im2meshBuiltIn( im, opt );
%
%   [ vert, tria, tnum, vert2, tria2 ] = im2meshBuiltIn( im );   % this use default setting
%   [ vert, tria, tnum, vert2, tria2 ] = im2meshBuiltIn( im, opt );
%
% input
%   im        % grayscale segmented image
%
%   opt - a structure array. It is the options for im2meshBuiltIn.
%         It stores parameter settings for im2meshBuiltIn.
%
%   opt.tf_avoid_sharp_corner   % For function getCtrlPnts
%                               % Whether to avoid sharp corner when 
%                               % simplifying polygon.
%                               % Value: true or false
%                               % If true, two extra control points
%                               % will be added around one original 
%                               % control point to avoid sharp corner 
%                               % when simplifying polygon.
%                               % Sharp corner in some cases will make 
%                               % poly2mesh not able to converge.
%
%   opt.lambda      % Parameter for funtion smoothBounds (Taubin smoothing)
%   opt.mu          % Parameter for funtion smoothBounds (Taubin smoothing)
%   opt.iters       % Parameter for funtion smoothBounds (Taubin smoothing)
%
%   opt.threshold_num_turning   % For funtion smoothBounds
%                               % Threshold value for the number of turning
%                               % points in a polyline. 
%
%   opt.threshold_num_vert_Smo  % For funtion smoothBounds
%                               % Threshold value for the number of 
%                               % vertices in a polyline.
%     
%   opt.tolerance   % For funtion simplifyBounds
%                   % Tolerance for polygon simplification.
%                   % Check Douglas-Peucker algorithm.
%                   % If u don't need to simplify, try tolerance = eps.
%                   % If the value of tolerance is too large, some 
%                   % polygons will become line segment after 
%                   % simplification, and these polygons will be 
%                   % deleted by function delZeroAreaPoly.
%
%   opt.threshold_num_vert_Sim  % For funtion simplifyBounds
%                               % Threshold value for number of vertices in
%                               % a polyline. 
%     
%  Please check documentation of matlab built-in function generateMesh for 
%  parameter hgrad, hmax, and hmin. 
%  https://www.mathworks.com/help/pde/ug/pde.pdemodel.generatemesh.html
%
%   opt.hgrad       % For funtion poly2meshBuiltIn
%                   % Mesh growth rate
%     
%   opt.hmax        % For funtion poly2meshBuiltIn
%                   % Target maximum mesh edge length
% 
%   opt. hmin       % For funtion poly2meshBuiltIn
%                   % Target minimum mesh edge length
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
   
    % check the number of inputs
    if nargin == 1
        opt = [];
    elseif nargin == 2
        % normal case
    else
        error("check the number of inputs");
    end

    % verify field names and set values for opt
    opt = setOption( opt );
    
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
    
    % get nodes and edges of polygonal boundary
    [ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );
    % Convert boundaries to a cell array of polyshape object
    pcell = bound2polyshape( boundsClear );
    % generate mesh
    [vert,tria,tnum,vert2,tria2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, ...
                                        opt.hgrad, opt.hmax, opt.hmin );

end


function new_opt = setOption( opt )
% setOption: verify field names in opt and set values in new_opt according
% to opt

    % initialize new_opt with default field names & value 
    new_opt.tf_avoid_sharp_corner = false;
    new_opt.lambda = 0.5;
    new_opt.mu = -0.5;
    new_opt.iters = 100;
    new_opt.threshold_num_turning = 10;
    new_opt.threshold_num_vert_Smo = 10;
    new_opt.tolerance = 0.3;
    new_opt.threshold_num_vert_Sim = 10;
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