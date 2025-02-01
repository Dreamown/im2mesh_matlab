function [ vert, tria, tnum ] = im2mesh( im, opt )
% im2mesh: generate triangular mesh based on grayscale segmented image
% usage:
%   [ vert, tria, tnum ] = im2mesh( im );   % this use default opt setting
%   [ vert, tria, tnum ] = im2mesh( im, opt );
%
% input
%   im        % grayscale segmented image
%   
%   opt - a structure array. It is the options for im2mesh.
%         It stores parameter settings for im2mesh.
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
%   opt.hmax      % For funtion poly2mesh
%                 % Maximum mesh-size
%     
%   opt.mesh_kind   % For funtion poly2mesh
%                   % Meshing algorithm
%                   % Value: 'delaunay' or 'delfront' 
%                   % "standard" Delaunay-refinement or
%                   % "Frontal-Delaunay" technique
% 
%   opt.grad_limit  % For funtion poly2mesh
%                   % Scalar gradient-limit for mesh
%                  
%   opt.select_phase  % select phase for meshing
%                   % Parameter type: vector
%                   % If 'select_phase' is [], all the phases will be
%                   % chosen to perform meshing
%                   % 'select_phase' is an index vector for sorted 
%                   % grayscales (ascending order) in an image.
%                   % For example, an image with grayscales of 40, 90,
%                   % 200, 240, 255. If u're interested in 40, 200, and
%                   % 240, then set 'select_phase' as [1 3 4]. Those 
%                   % phases corresponding to grayscales of 40, 200, 
%                   % and 240 will be chosen to perform meshing.   
%   
% output:
%   verrt - Node data. N-by-2 array.
%       vert(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   tria - Node numbering for each triangle. M-by-3 array.
%       tria(j,1:3) = [node_numbering_of_3_nodes] of the j-th element
%
%   tnum - Label of material phase. P-by-1 array.
%       tnum(j,1) = k; means the j-th element is belong to the k-th phase
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
    
    % get nodes and edges of polygonal boundary
    [ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );
    % generate triangular mesh
    [ vert,tria,tnum ] = poly2mesh( poly_node, poly_edge, ...
                                opt.hmax, opt.mesh_kind, opt.grad_limit );
    
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
    new_opt.select_phase = [];
    new_opt.grad_limit = 0.25;
    new_opt.hmax = 500;
    new_opt.mesh_kind = 'delaunay';

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


