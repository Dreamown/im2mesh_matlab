function new_bounds = getCtrlPnts( bounds, tf_avoid_sharp_corner, size_im )
% get control points in bounds{i}{j}. bounds{i}{j} is a polygon boundary.
%
% Control point is the intersecting vertex between two polygons.
% It will serve as fixed-point for polygon simplification and meshing.
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
%   bounds{i} is boundary polygons for one phase
%
%   tf_avoid_sharp_corner - boolean
%
%   size_im - Size of image. Type: 1-by-2 integer vector
%
% output:
%   new_bounds - cell array. new_bounds{i}{j} is a polygon boundary with 
%               (NaN,NaN). (NaN,NaN) is the label for control point.
%
% Steps:
%   1. find a control point in bounds{i}{j} according to bounds{k}{l}
%   2. change starting point of bounds{i}{j} to the control point (found in step 1)
%   3. find & label all control points in bounds{i}{j}
%   4. insert (NaN,NaN) for polygon simplify
%
% % example of control points (only illustrate the output)
%
%     poly1=[1 2; 1 1; 0 1; 0 0; 1 0; 1 -1; 0 -1; -1 -1;
%                             -1 0; -1 1; -1 2; -1 3; 0 3; 1 3; 1 2];
%     poly2=[2 3; 1 3; 1 2; 1 1; 1 0; 1 -1; 2 -1;2 3];
%
%     % control points would be
%     cp=[1 0;1 -1;1 1; 1 2; 1 3];
%     % plot together
%     plot( poly1(:,1),poly1(:,2),poly2(:,1),poly2(:,2) )
%     hold on
%     plot(cp(:,1),cp(:,2),'ro')
% 
%     % label of control points for poly1 would be
%     label_ctrlpnt_poly1 = [1  1  0  0  1  1  0  0  0  0  0  0  0  1  1]';
%     % label of control points for poly2 would be
%     label_ctrlpnt_poly2 = [0  1  0  0  0  1  0  0]';
% 
%     % insert (NaN,NaN) into poly1
%     new_poly1 = [ 1 2; 1 1; NaN NaN; 1 1; 0 1; 0 0; 1 0; NaN NaN; 1 0;
%                     1 -1; NaN NaN; 1 -1; 0 -1; -1 -1; -1 0; -1 1; -1 2;
%                     -1 3; 0 3; 1 3; NaN NaN; 1 3; 1 2 ];
%     % insert (NaN,NaN) into poly2
%     new_poly2 = [ 2 3; 1 3; NaN NaN; 1 3; 1 2; 1 1; 1 0;
%                     1 -1; NaN NaN; 1 -1; 2 -1; 2 3 ];
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%
    
    % check the number of inputs
    if nargin == 2
        size_im =[];
    elseif nargin == 3
        % normal case
    else
        error('check the number of inputs');
    end

    label_equal = findEqualPoly( bounds );
    % If exist coincident polygon, mark label_equal{i}{j} with the index of
    % that coincident polygon. label_equal{i}{j} is a 1-by-2 uint32 array.
    % We will not search control points between coincident polygons.
    
    new_bounds = bounds;
    
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            % -------------------------------------------------------
            % step 1
            % label control point
            % once find a control point, break loop
    
            % initialize
            label_ctrlpnt = false( length(bounds{i}{j}), 1 );
            k_last_time = 1;
            l_last_time = 1;
    
            % label vertex in bounds{i}{j} according to bounds{k}{l}
            for k = 1: length(bounds)
                for l = 1: length(bounds{k})
                    % skip itself
                    if k==i && l==j, continue; end    
                    
                    % skip coincident polygon
                    if isequal( label_equal{i}{j}, [k, l] ), continue; end
                    
                    label_ctrlpnt = updateLabel( bounds{i}{j}, ... 
                                            bounds{k}{l}, label_ctrlpnt );
                    
                    % if find a control point, break loop                     
                    if any( label_ctrlpnt( 1: end ) ), break; end
                end
                
                % if find a control point, break loop  
                if any( label_ctrlpnt( 1: end ) )
                    k_last_time = k;
                    l_last_time = l;
                    break;
                end
            end
            
            % if none of the vertices of bounds{i}{j} is on other polygons,
            % it means that polygon bounds{i}{j} has no contact with other 
            % polygons. bounds{i}{j} is an isolated polygonal area.
			% There are no control points on bounds{i}{j}.
            if all( ~label_ctrlpnt( 1: end ) )
                if ~isempty(size_im)
                    % check whether bounds{i}{j} is exactly the image border
                    % if it's border, add control point; else, do nothing
                    h = size_im(1);     % y-direction
                    w = size_im(2);     % x-direction
                    corners = 0.5 + [ 0, 0; w, 0; w, h; 0, h; 0, 0; ];
                    tf_vector = isvertex( corners, bounds{i}{j} );
                    
                    if all(tf_vector)
                        label = logical( [0 1 1 1 0]' );
                        new_bounds{i}{j} = [];
                        new_bounds{i}{j} = insertNaN( corners, label );
                    end
                end
                
                continue;       % go to next iteration bounds{i}{j+1}
            end

            % -------------------------------------------------------
            % step 2
            % change starting point of bounds{i}{j} to control point
    
            if label_ctrlpnt(1) == false
                % this means the starting point is not a control point
                % so we can change the starting point
                head_index = find( label_ctrlpnt( 2: end-1 ), 1 ) + 1;
                bounds{i}{j} = setNewHeadPt( bounds{i}{j}, head_index );
            else
                % label_ctrlpnt(1) == true
                if sum(label_ctrlpnt) > 2
                    % this also means the starting point is not a control point
                    % so we can change the starting point
                    head_index = find( label_ctrlpnt( 2: end-1 ), 1 ) + 1;
                    bounds{i}{j} = setNewHeadPt( bounds{i}{j}, head_index );
                else
                    % label_ctrlpnt(1) == true && sum(label_ctrlpnt) ==  2
                    % this means the starting point is a control point
                    % do nothing
                end
            end
            
            % -------------------------------------------------------
            % step 3
            % label control points, again
            
            % initialize
            label_ctrlpnt = false( length(bounds{i}{j}), 1 );
    
            % label vertex in bounds{i}{j} according to bounds{k}{l}
            % start from k_last_time and l_last_time
            for k = k_last_time: length(bounds)
                
                if k == k_last_time
                    l_start = l_last_time;
                else
                    l_start = 1;
                end
                    
                for l = l_start: length(bounds{k})
                    % skip itself
                    if k==i && l==j, continue; end    
    
                    % skip coincident polygon
                    if isequal( label_equal{i}{j}, [k, l] ), continue; end
                    
                    label_ctrlpnt = updateLabel( bounds{i}{j},  ... 
                                            bounds{k}{l}, label_ctrlpnt );
                end
            end
            
            % -------------------------------------------------------
            % step 4
            if tf_avoid_sharp_corner
                label_ctrlpnt = addExtraPnts( label_ctrlpnt );
            end

            % -------------------------------------------------------
            % step 5
            % check whether bounds{i}{j} pass corners of image
            [ tf_pass, ind ] = isPassCorner( bounds{i}{j}, size_im );

            if tf_pass
                label_ctrlpnt( ind ) = true;
            end

            % -------------------------------------------------------
            % step 6
            new_bounds{i}{j} = insertNaN( bounds{i}{j}, label_ctrlpnt );
    
        end
    end
end

function [ tf_pass, ind ] = isPassCorner( polyline, size_im )   
% isAtCorner: check whether the polyline pass the corners of image
%
% input
%   polyline:   x y coordinates of a polyline
%               N-by-2 array
%
%   size_im: Size of image
%            Type: 1-by-2 integer vector
%

    % initialize
    tf_pass = false;
    ind = 0;

    % check input size_im
    if isempty( size_im )
        % not pass
        return
    end

    % Create x y coordinates of 4 corners according to size_im.
    % For example, if size_im = [ 20, 10 ], 
    % 4 corners will be [ .5, .5; 10.5, .5; 10.5, 20.5; .5, 20.5 ];

    h = size_im(1);     % y-direction
    w = size_im(2);     % x-direction
    corners = 0.5 + [ 
                        0, 0;
                        w, 0;
                        w, h;
                        0, h;
                    ];

    % check whether the polyline pass corner
    tf_vector = isvertex( polyline, corners );
    
    if any(tf_vector)
        tf_pass = true;
        ind = find( tf_vector );
    else
        tf_pass = false;
    end
        
end

function label_equal = findEqualPoly( bounds )
% compare polygon in bounds, find equal polygon
% bounds{i}{j} - n+1 * 2 array
% label_equal{i}{j} - 1 * 2 uint32 array   % new
% label_equal{i}(j) - true or false        % old
    
    % intialize label_equal
    label_equal = cell( length(bounds), 1 );
    for i = 1: length(bounds)
        label_equal{i} = cell( length(bounds{i}), 1 );

        for j = 1: length(bounds{i})
            label_equal{i}{j} = uint32([0 0]);
        end
    end
    
    % labeling
    for i = 1: length(bounds)-1
        for j = 1: length(bounds{i})
            for k = i+1: length(bounds)
                for l = 1: length(bounds{k})
                    
                    if isequal( bounds{i}{j}, bounds{k}{l} )
                        label_equal{i}{j} = [ k, l ];
                        label_equal{k}{l} = [ i, j ];
                    end
                    
                end
            end
        end
    end

end

function label_ctrlpnt = updateLabel( poly1, poly2, label_ctrlpnt )
% Find control point in poly1, according to poly2, get updated label
%
% example
%     poly1=[1 2; 1 1; 0 1; 0 0; 1 0; 1 -1; 0 -1; -1 -1;
%                         -1 0; -1 1; -1 2; -1 3; 0 3; 1 3; 1 2];
%     poly2=[2 3; 1 3; 1 2; 1 1; 1 0; 1 -1; 2 -1;2 3];
%     plot( poly1(:,1),poly1(:,2),poly2(:,1),poly2(:,2) )
%     hold on
%     plot( poly1(1,1),poly1(1,2), 'ro' )
%     xlim([-1.5 3.5]);
%     ylim([-1.5 3.5]);
%     
%     numpnts = length( poly1 );      % number of points
%     label_ctrlpnt = false( numpnts, 1 );    % control point
%     label_ctrlpnt = updateLabel( poly1, poly2, label_ctrlpnt );
%

    % pre-check using bounding box of polygon
    if ~ isBBoxIntersect( poly1, poly2 )
        return
    end 

    % find vertices of poly1 that is the same as vertex of poly2
    tf_vector = isvertex( poly1, poly2 );
    % same as "tf_vector = ismember( poly1, poly2, 'rows' );", but faster

    if all(~tf_vector)	% none of the vertices of poly1 is on poly2
        return
    elseif all(tf_vector)   % all of the vertices of poly1 is on poly2
        return              % the case of hidden control point
    else                % some of the vertices of poly1 is on poly2
        for i = 1: length(tf_vector)
            if tf_vector(i)
                % first or last vertex-index of a common edge
                if i == 1 || i == length(tf_vector) ...
                        || ~tf_vector(i-1) || ~tf_vector(i+1)
                    label_ctrlpnt( i ) = true;
                end
            end
        end

    end
    
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

function label_ctrlpnt = addExtraPnts( label_ctrlpnt )
% add two extra control points around one original control point
% to avoid sharp corner when simplifying polygon
%
% example
% input:    [1  1  0  0  0  1  0  0  0  0  0  0  0  1  1]';
% output:   [1  1  1  0  1  1  1  0  0  0  0  0  1  1  1]';
% 
% history: revised 20250110

    % treat starting point of polgon as control point
    label_ctrlpnt(1) = true;
    label_ctrlpnt(end) = true;

    idx = find( label_ctrlpnt );
    
    % add two extra control points around one original control point
    for m = 1: length(idx)
        if idx(m) ~= 1
            label_ctrlpnt( idx(m)-1 ) = true;
        end
        
        if idx(m) ~= length(label_ctrlpnt)
            label_ctrlpnt( idx(m)+1 ) = true;
        end
    end
end


function new_poly = insertNaN( poly, label_ctrlpnt )
% insert (NaN,NaN) according to label_ctrlpnt
%
% example
%     poly1=[1 2; 1 1; 0 1; 0 0; 1 0; 1 -1; 0 -1; -1 -1;
%                         -1 0; -1 1; -1 2; -1 3; 0 3; 1 3; 1 2];
%                     
%     label_ctrlpnt = false( length(poly1), 1 );
%     label_ctrlpnt( [2 5 6] ) = true;
%     new_poly1 = insertNaN( poly1, label_ctrlpnt);
%
    
    % set starting point to false to avoid error
    label_ctrlpnt( 1 ) = false;
    label_ctrlpnt( end ) = false;

    
    num_vert = length(label_ctrlpnt);
    idx = find( label_ctrlpnt );
    new_poly = zeros( num_vert + 2*length(idx), 2 );
    
    count = 1;  % for new_poly
    for i = 1: num_vert
        if label_ctrlpnt(i)
            new_poly( count, : ) = poly( i, : );
            new_poly( count+1, : ) = [ NaN, NaN ];
            new_poly( count+2, : ) = poly( i, : );
            count = count + 3;
        else
            new_poly( count, : ) = poly( i, : );
            count = count + 1;
        end
    end

end
