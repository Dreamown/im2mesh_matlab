function bounds = addPnt2Bound( points, bounds, tolerance )
% addPnt2Bound: add points to polygonal boundaries.
% Check whether points are lying near polygon bounds{i}{j}.
% If it is, add point to polygon bounds{i}{j}
%
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain grayscale level in image.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    xv = points(:,1);
    yv = points(:,2);

    % Check whether points xv yv are lying near polygon bounds{i}{j}.
    % If it is, add point to polygon bounds{i}{j}
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})

            xp = bounds{i}{j}(:,1);
            yp = bounds{i}{j}(:,2);

            [new_xp, new_yp] = addPnt2Poly( xv, yv, xp, yp, tolerance );
            
            % update bounds{i}{j}
            bounds{i}{j} = [new_xp, new_yp];
        end
    end

    % rounding the vertex coordinates to n digits
    % purpose: avoid numeric error of very close vertex
    n_digit_decimal = 6;    % N digits to the right of the decimal point
    bounds = roundBounds( bounds, n_digit_decimal );

end


function bounds = roundBounds( bounds, n_digit_decimal )
% roundBounds: round the vertex coordinates in polygonal boundaries to 
% n digits
%
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


function [new_xp, new_yp] = addPnt2Poly( xv, yv, xp, yp, tolerance )
% addPnt2Poly: Check whether points [xv, yv] are lying near 
% polygon [xp, yp]. If it is, add point to the polygon.

    % use function p_poly_dist to find distances from points to a polyline
    [d_min, ~, ~, ~, idx_c] = p_poly_dist( xv, yv, xp, yp );

    % idx_c - vector (1 X np) of indices of segments that contain the closest
    % point. For instance,  idx_c(2) == 4 means that the polyline point closest
    % to point 2 belongs to segment 4

    % use function isvertex to check whether point prjection is vertex 
    nDigit = 6;     % rounding to avoid numeric error 
    tf_is_vertex = isvertex( round([xv, yv],nDigit), round([xp, yp],nDigit) );
    
    tf_onPoly = (d_min < tolerance) & ~tf_is_vertex;
    
    % check whether all false (not exist points lying near polygon)
    if sum(tf_onPoly) == 0
        new_xp = xp;
        new_yp = yp;
        return
    end

    % get points (for inserting)
    x_add = xv( tf_onPoly );
    y_add = yv( tf_onPoly );
    idx_seg = idx_c( tf_onPoly );
    
    % insert points into the polygon
    [new_xp, new_yp] = insertVertex( xp, yp, x_add, y_add, idx_seg );

end


function [x_new, y_new] = insertVertex(x, y, x_insert, y_insert, idx_seg)
% insertVertex Inserts new vertices into an existing 
% polyline, sorting the new points by their distance from the start 
% of the segment they're inserted into.
%
%   [X_NEW, Y_NEW] = insertVertex(X, Y, X_INSERT, 
%   Y_INSERT, IDX_SEG) inserts the points in (X_INSERT, Y_INSERT) into 
%   the polyline described by (X, Y). The line segment indices 
%   into which these points are inserted are provided by IDX_SEG. 
%   For each segment k, the points are sorted by their distance 
%   from (X(k), Y(k)).
%
%   INPUTS:
%       X, Y               : Original polyline vertices (column vectors).
%       X_INSERT, Y_INSERT : New vertices to be inserted (column vectors).
%       IDX_SEG            : Column vector of segment indices; 
%                            same length as X_INSERT/Y_INSERT.
%
%   OUTPUTS:
%       X_NEW, Y_NEW       : The updated polyline with newly inserted vertices,
%                            where the inserted points in each segment 
%                            are sorted by distance from that segment's start.
%
%   EXAMPLE:
%       x = [0; 1; 2; 3];
%       y = [0; 1; 1; 0];
%       x_insert = [1.5; 2.5; 1.2];
%       y_insert = [0.5; 0.5; 0.8];
%       idx_seg   = [2; 3; 2]; 
%
%       [x_new, y_new] = insertVertex(...
%                          x, y, x_insert, y_insert, idx_seg);
%       % This inserts points (1.5, 0.5) and (1.2, 0.8) between 
%       % vertices 2-3 (sorted by distance from (1,1)), 
%       % and (2.5, 0.5) between vertices 3-4.

    % Basic checks
    if length(x) ~= length(y)
        error('Length of x and y must be the same.');
    end
    if length(x_insert) ~= length(y_insert)
        error('Length of x_insert and y_insert must be the same.');
    end
    if length(x_insert) ~= length(idx_seg)
        error('Length of x_insert and idx_seg must be the same.');
    end
    
    % Number of original vertices
    N = length(x);
    
    % Prepare new arrays (use cell for dynamic building, then convert)
    x_new_cell = cell(N, 1);
    y_new_cell = cell(N, 1);
    
    % Go through each segment in the original polyline
    for k = 1 : (N - 1)
        
        % Place the current vertex into the new polyline
        x_new_cell{k} = x(k);
        y_new_cell{k} = y(k);
        
        % Find which new points belong to segment k
        idx_to_insert = find(idx_seg == k);
        
        % -- SORTING BY DISTANCE FROM THE SEGMENT'S START (x(k), y(k)) --
        if ~isempty(idx_to_insert)
            % Compute distances from the start vertex of the current segment
            seg_start_x = x(k);
            seg_start_y = y(k);
            dist_array  = sqrt((x_insert(idx_to_insert) - seg_start_x).^2 + ...
                               (y_insert(idx_to_insert) - seg_start_y).^2);
            
            % Sort indices in ascending order of distance
            [~, sort_order] = sort(dist_array, 'ascend');
            % Reorder the insertion indices so we insert in the correct order
            idx_to_insert = idx_to_insert(sort_order);
        end
        
        % Insert those points in this segment (in sorted order)
        for i_ins = 1:length(idx_to_insert)
            x_new_cell{k} = [x_new_cell{k}; x_insert(idx_to_insert(i_ins))]; 
            y_new_cell{k} = [y_new_cell{k}; y_insert(idx_to_insert(i_ins))];
        end
    end
    
    % Add the last original vertex
    x_new_cell{N} = x(N);
    y_new_cell{N} = y(N);
    
    % Concatenate results
    x_new = cell2mat(x_new_cell);
    y_new = cell2mat(y_new_cell);

end

