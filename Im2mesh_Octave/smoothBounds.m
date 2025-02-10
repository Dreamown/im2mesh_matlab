function new_bounds = smoothBounds( bounds, lambda, mu, iters, threshold_num_turning, threshold_num_vert )
% smooth each bounds{i}{j} using 2d Taubin Smoothing (taubinSmooth.m)
%
% GNU Octave
%
% input:
%   bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.
%   bounds{i} is boundary polygons for one phase.
%   bounds{i}{j} is a polygon boundary with (NaN,NaN). (NaN,NaN) is the 
%   label for control point.
%
%   lambda, mu, iters - parameters for Taubin Smoothing (taubinSmooth.m)
%
%   lambda: How far each node is moved toward the average position of its
%           neighbours during every second iteration. 0<lambda<1
%
%   mu: How far each node is moved opposite the direction of the average 
%       position of its neighbours during every second iteration. -1<mu<0
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
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%
    
    % check the number of inputs
    if nargin == 4
        threshold_num_turning = 0;
        threshold_num_vert = 0;
    elseif nargin == 5
        threshold_num_vert = 0;
    elseif nargin == 6
        % normal case
    else
        error('check the number of inputs');
    end

    new_bounds = bounds;

    if iters == 0
        % no smoothing
        return
    end

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
                    % smooth polyline using taubinSmooth function
                    poly_temp = taubinSmooth( poly_O, lambda, mu, iters );
                    
                    % update
                    x{k} = poly_temp(:,1);
                    y{k} = poly_temp(:,2);
                end
            end
            
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
            factor = 10^n_digit_decimal;
            btemp{i}{j} = round( factor*btemp{i}{j} ) / factor;
        end
    end
    
    bounds = btemp;

end









