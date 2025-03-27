function percent_polyarea = getPolyShapePercent( bounds )
% getPolyPercent: calculate the area perccentage of each phase in
% polygonal boundaries
% 
% This method cosider holes but require polyshape
%
% % Example:
%     im = imread("Shape.tif");
%     boundsRaw = im2Bounds( im );
%     
%     tf_avoid_sharp_corner = false;
%     boundsCtrlP = getCtrlPnts( boundsRaw, tf_avoid_sharp_corner, size(im) );
%     
%     lambda = 0.7;
%     mu = -0.4;
%     iters = 10;
%     threshold_num_turning = 0;
%     threshold_num_vert_Smo = 0;
%     boundsSmooth = smoothBounds( boundsCtrlP, lambda, mu, iters, ...
%                     threshold_num_turning, threshold_num_vert_Smo );
% 				    
%     tolerance = 0.5;
%     threshold_num_vert_Sim = 0;
%     boundsSimplified = simplifyBounds( boundsSmooth, tolerance, ...
%                                             threshold_num_vert_Sim );
%     
%     % column vector for intensity
%     intensity = unique( im ); 
%     
%     % calculate the area perccentage of grayscale in image
%     percent_pixel = getPixelPercent( im );
%     
%     % calculate the area perccentage in polygonal boundaries
%     percent_polyareaRaw = getPolyShapePercent( boundsRaw );
%     percent_polyareaSmooth = getPolyShapePercent( boundsSmooth );
%     percent_polyareaSimplify = getPolyShapePercent( boundsSimplified );
%     
%     % create table
%     T = table( intensity, percent_pixel, ...
%      percent_polyareaRaw, percent_polyareaSmooth, percent_polyareaSimplify );
%      
%     % show table
%     T
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    num_phase = length( bounds );
    area_vec = zeros( num_phase, 1);           % vector
    percent_polyarea = zeros( num_phase, 1);       % ratio of area

    % p_cell is a cell vector for polyshape
    % p_cell{i} is the polyshape object of the i-th phase
    p_cell = bound2polyshape(bounds);

    % area_vec(i) - area of the i-th phase
    for i = 1: num_phase
            area_vec(i) = area( p_cell{i} );
    end
    
    % percent_poly(i) - percent of polygonal area for the i-th phase
    for i = 1: num_phase
        percent_polyarea(i) = 100* area_vec(i) / sum(area_vec);
    end

end












