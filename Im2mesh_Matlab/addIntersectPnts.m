function bounds = addIntersectPnts( bounds, tolerance )
% addIntersectPnts: search and add intersect points (vertex)
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

    % check whether vertices in bounds{i}{j} are intersect points for 
    % polygon bounds{k}{l} 
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            for k = 1: length(bounds)
                for l = 1: length(bounds{k})
                    if i==k && j==l; continue; end   % skip itself
                    
                    xv = bounds{i}{j}(1:end-1,1);
                    yv = bounds{i}{j}(1:end-1,2);
                    xp = bounds{k}{l}(:,1);
                    yp = bounds{k}{l}(:,2);
                    
                    % pre-check using bounding box of polygon
                    if ~ isBBoxIntersect( [xv,yv], [xp,yp] )
                        continue
                    end 

                    [new_xp, new_yp] = addIntersectPnt2Poly( xv, yv, xp, yp, tolerance );
                    % update bounds{k}{l}
                    bounds{k}{l} = [new_xp, new_yp];
                end
            end
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


function [new_xp, new_yp] = addIntersectPnt2Poly( xv, yv, xp, yp, tolerance )
% addIntersectPnt2Poly: check whether the vertices [xv,yv] are intersect 
% points for a polygon [xp, yp]. If it is, insert those vertices into the 
% polygon.

    % use function p_poly_dist to find distances from points to a polyline
    [d_min, ~, ~, ~, idx_c] = p_poly_dist( xv, yv, xp, yp );

    % use function isvertex to check whether belonging
    nDigit = 8;     % rounding to avoid numeric error 
    tf_is_vertex = isvertex( round([xv, yv],nDigit), round([xp, yp],nDigit) );

    tf_intsecpnt = (d_min < tolerance) & ~tf_is_vertex;
    
    % check whether all false (not exist intersect points)
    if sum(tf_intsecpnt) == 0 
        new_xp = xp;
        new_yp = yp;
        return
    end

    % get intersect points 
    x_add = xv(tf_intsecpnt);
    y_add = yv(tf_intsecpnt);
    idx_seg = idx_c(tf_intsecpnt);
    
    % insert intersect points into the polygon
    [new_xp, new_yp] = insertVertex( xp, yp, x_add, y_add, idx_seg );

end


function tf = isBBoxIntersect( poly1, poly2 )
% whether the bounding box of two polygons intersect

    xmin_p1 = min(poly1(:,1));
    xmax_p1 = max(poly1(:,1));

    xmin_p2 = min(poly2(:,1));
    xmax_p2 = max(poly2(:,1));

    tf_x = isRangeIntersect( [xmin_p1 xmax_p1], [xmin_p2 xmax_p2] );

    ymin_p1 = min(poly1(:,2));
    ymax_p1 = max(poly1(:,2));

    ymin_p2 = min(poly2(:,2));
    ymax_p2 = max(poly2(:,2));

    tf_y = isRangeIntersect( [ymin_p1 ymax_p1], [ymin_p2 ymax_p2] );

    if tf_x && tf_y
        tf = true;
    else
        tf = false;
    end
end

function tf = isRangeIntersect(range1, range2)
% whether two intervals intersect

    lower = max(range1(1), range2(1));
    upper = min(range1(2), range2(2));
    
    if lower <= upper
        tf = true;
    else
        tf = false;
    end
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

