function new_bounds = smoothBoundsCCMA( bounds, w_ma, w_cc, threshold_num_turning, threshold_num_vert )
% smoothBoundsCCMA: smooth polygonal boundaries using CCMA smoothing 
% algorithm (CCMA.m)
%
% usage:
%   new_bounds = smoothBoundsCCMA( bounds, w_ma, w_cc, threshold_num_turning, threshold_num_vert );
%   new_bounds = smoothBoundsCCMA( bounds, w_ma, w_cc, threshold_num_turning );
%   new_bounds = smoothBoundsCCMA( bounds, w_ma, w_cc );
%
% input:
%   bounds - a nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%            plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%            polygon. Use plotBounds( bounds ) to view all polygons.
%   bounds{i}{j} is a polygon boundary with (NaN,NaN). (NaN,NaN) is the 
%   label for control point.
%
%   w_ma, w_cc - parameters for Curvature Corrected Moving Average (CCMA)
%                smoothing algorithm (https://github.com/UniBwTAS/ccma)
%
%   w_ma (float): Width parameter for the moving average.
%   w_cc (float): Width parameter for the curvature correction.
%   It seems w_ma has major impact. Larger w_ma, smoother curve.
%   w_cc has little impact.
%
%   iters: Number of smoothing steps. Non negative interger
%          If iters == 0, no smooth.
%
%   threshold_num_turning:  Threshlod for the number of knick-point 
%                           vertices or turning points. 
%                           If the number of knick-point vertices or 
%                           turning points in a polyline is smaller than 
%                           this threshold, do not perform smoothing. 
%
%   threshold_num_vert: Threshlod for the number of vertices. 
%                       If the number of vertices in a polyline is smaller
%                       than this threshold, do not perform smoothing.
%
% output:
%   new_bounds - cell array. new_bounds{i}{j} is a polygon boundary with 
%               (NaN,NaN). (NaN,NaN) is the label for control point.
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%
    
    % check the number of inputs
    if nargin == 3
        threshold_num_turning = 0;
        threshold_num_vert = 0;
    elseif nargin == 4
        threshold_num_vert = 0;
    elseif nargin == 5
        % normal case
    else
        error('check the number of inputs');
    end

    new_bounds = bounds;

    % smooth each polygonal boundary
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            % bounds{i}{j} is a N-by-2 coordinate array of a polygon boundary with (NaN,NaN)

            % convert a polygon to cell array that consists of polylines
            % x, y are N-by-1 cell arrays with one polygon segment per cell
            [x, y] = polysplit( bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
            % smooth polyline in the polygon
            for k = 1: numel(x)
                % poly_O is the k-th polyline in the polygon
                poly_O = [ x{k}, y{k} ];  % N-by-2
                
                % use function dpsimplify() to remove non-knick/non-turning points
                poly_turn_pnt = dpsimplify( poly_O, eps );

                % check the number of turning points in a polyline
                if length(poly_turn_pnt)-1 <= threshold_num_turning || ...
                        length(poly_O)-1 <= threshold_num_vert
                    % If the number of turning-point vertices in a polyline
                    % is smaller than threshold_num_turning, don't smooth.
                    % If the number of vertices in a polyline is smaller 
                    % than threshold_num_vert, don't smooth.
                    continue
                else
                    % smooth polyline using CCMA filter
                    % create a ccma class instance
                    ccma_instance = CCMA( w_ma, w_cc, 'pascal', [], [], 0.95, 0.95 );
                    
                    if poly_O(1,:) == poly_O(end,:) 
                        % if poly_temp is a polygon
                        poly_temp = ccma_instance.filter( poly_O, 'wrapping');
                        % pad
                        poly_temp(end+1,:) = poly_temp(1,:);    
                    else
                        % if poly_temp is a polyline
                        poly_temp = ccma_instance.filter( poly_O, 'padding');
                        % pad
                        poly_temp = [
                                    poly_O(1,:);
                                    poly_temp;
                                    poly_O(end,:);
                                    ];
                    end
                    
                    % update
                    x{k} = poly_temp(:,1);
                    y{k} = poly_temp(:,2);
                end
            end
            
            new_bounds{i}{j} = [];
            [ new_bounds{i}{j}(:,1), new_bounds{i}{j}(:,2) ] = polyjoin(x, y);
        end
    end

    % rounding the vertex coordinates to n digits
    % purpose: avoid numeric error of taubinSmooth
    n_digit_decimal = 2;    % N digits to the right of the decimal point
    new_bounds = roundBounds( new_bounds, n_digit_decimal );

end


function bounds = roundBounds( bounds, n_digit_decimal )
% round the vertex coordinates in polygonal boundaries to n digits
% input:
%   n_digit_decimal: N digits to the right of the decimal point

    btemp = bounds;

    for i = 1: length(btemp)
        for j = 1: length(btemp{i})
             btemp{i}{j} = round( btemp{i}{j}, n_digit_decimal );
        end
    end
    
    bounds = btemp;

end


