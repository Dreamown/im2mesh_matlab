function new_bounds = simplifyBounds( bounds, tolerance, threshold_num_vert )
% simplify each bounds{i}{j} using dpsimplify.m
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
%   bounds{i}{j} is a polygon boundary with (NaN,NaN). (NaN,NaN) is the 
%   label for control point.
% 
%   tolerance - parameter for polygon or polyline simplification.
%               Function: dpsimplify.m (Douglas–Peucker algorithm)
% 
%   threshold_num_vert - threshold for the number of vertices.
%                        If the number of vertices in a ppolyline is not 
%                        larger than this threshold, do not perform 
%                        simplification.
%
% output:
%   new_bounds - cell array. new_bounds{i}{j} is without (NaN,NaN)
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%
    
    % check the number of inputs
    if nargin == 2
        threshold_num_vert = 0;
    elseif nargin == 3
        % normal case
    else
        error("check the number of inputs");
    end
    
    new_bounds = bounds;
    
    % simplify each polygonal boundary
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            % bounds{i}{j} is a N-by-2 coordinate array of a polygon boundary with (NaN,NaN)
            
            % convert a polygon to cell array that consists of polylines
            % x, y are N-by-1 cell arrays with one polygon segment per cell
            [x, y] = polysplit( bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
            % simplify each polyline in the polygon
            for k = 1: numel(x)
                % poly_O is the k-th polyline in the polygon
                poly_O = [ x{k}, y{k} ];  % N-by-2
                
                % check the number of vertices in a polyline
                if length(poly_O)-1 <= threshold_num_vert
                    % If the number of vertices in a polyline is smaller 
                    % than threshold, don't perform smoothing.
                    continue
                else
                    % pre-process polyline
                    % dpsimplify() is sensitive to the orientation of 
                    % polyline, so reorient first
                    poly_O = reorient( poly_O );

                    % simplify polyline
                    if tolerance == 0
                        poly_temp = simplifyPolyline_geometry( poly_O );
                    else
                        poly_temp = simplifyPolyline_geometry( poly_O, 'tol', tolerance );
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
    
    new_bounds = mergeBounds( new_bounds );     % delete (NaN,NaN)
end

function polyline = reorient( polyline )
% reorient: make the starting point of polyline the left-bottom. 
% If polyline is a polygon, make it to counter clockwise.

    x = polyline(:,1);
    y = polyline(:,2);

    if x(1) == x(end) && y(1) == y(end)
        % the polyline is a polygon, make it to counter clockwise
        if ispolycw(x, y)
            x = x( end:-1:1 );  % convert to counter clockwise
            y = y( end:-1:1 );
        end
    else
        % the polyline is not a polygon
        % make the starting point of polyline the left-bottom
        if x(1) < x(end) || ...
                ( x(1) == x(end) && y(1) <= y(end) )
            % starting point of polyline already at left-bottom
            % so do nothing
        elseif ( x(1) == x(end) && y(1) > y(end) ) ||...
                x(1) > x(end)
            % starting point not at left-bottom
            % reverse
            x = x(end:-1:1);
            y = y(end:-1:1);
        else
            error('other cases')
        end
    end
    
    % update polyline
    polyline(:,1) = x;
    polyline(:,2) = y;
            
end

function bounds = mergeBounds( bounds )
% delete (NaN,NaN) in bounds{i}{j} using polymerge

    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            poly = [];
            [ poly(:,1), poly(:,2) ] = polymerge( ...
                                    bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
            bounds{i}{j} = poly;
        end
    end
end

function [ x_new, y_new ] = polymerge( x, y )
% Merge line segments with matching endpoints
% line segments are seperated by NaN
% This is a simpler version of official polymerge
% input: column vector
% output: column vector
%
% example:
%     x = [1 2 3 NaN 3 4 5 6]';
%     y = [11 12 13 NaN 13 14 15 16]';
%     [ x_new, y_new ] = polymerge( x, y );
%     
%     x = [1 2 3 NaN 5 4 3]';
%     y = [11 12 13 NaN 15 14 13]';
%     [ x_new, y_new ] = polymerge( x, y );
%     
%     x = [1 2 3 NaN 5 4 3 NaN 7 6 5]';
%     y = [11 12 13 NaN 15 14 13 NaN 17 16 15]';
%     [ x_new, y_new ] = polymerge( x, y );
%
%     x = [3 2 1 NaN 3 4 5 6]';
%     y = [13 12 11 NaN 13 14 15 16]';
%     [ x_new, y_new ] = polymerge( x, y );
%

    % Find NaN locations.
    indx = find( isnan(x(:)) );
    
    % Simulate the trailing NaN if it's missing.
    if ~isempty(x) && ~isnan(x(end))
        indx(end+1,1) = numel(x) + 1;
    end

    N = numel(indx);

    if N == 1
        x_new = x;
        y_new = y;
        return
    end

    % N>1
    % Extract each segment into pre-allocated N-by-1 cell arrays, where N is
    % the number of polygon segments.  (Add a leading zero to the indx array
    % to make indexing work for the first segment.)
    xcell = cell(N,1);
    ycell = cell(N,1);
    indx = [0; indx];

    for k = 1:N
        iStart = indx(k)   + 1;
        iEnd   = indx(k+1) - 1;
        xcell{k} = x(iStart:iEnd);
        ycell{k} = y(iStart:iEnd);
    end

    % reorient to match endpoints
    % 1st segments
    k = 1;
    if ( xcell{k}(1) == xcell{k+1}(1) ) && ( ycell{k}(1) == ycell{k+1}(1) )
        % reverse
        xcell{k}(:) = xcell{k}(end:-1:1);
        ycell{k}(:) = ycell{k}(end:-1:1);
    elseif ( xcell{k}(1) == xcell{k+1}(end) ) && ( ycell{k}(1) == ycell{k+1}(end) )
        % reverse
        xcell{k}(:) = xcell{k}(end:-1:1);
        ycell{k}(:) = ycell{k}(end:-1:1);
    end

    % other segments
    for k = 1: N-1
        if ( xcell{k}(end) == xcell{k+1}(1) ) && ( ycell{k}(end) == ycell{k+1}(1) ) 
            % do nothing
        elseif ( xcell{k}(end) == xcell{k+1}(end) ) && ( ycell{k}(end) == ycell{k+1}(end) ) 
            % reverse
            xcell{k+1}(:) = xcell{k+1}(end:-1:1);
            ycell{k+1}(:) = ycell{k+1}(end:-1:1);
        else
            error("unexpected case");
        end
    end

    % remove repeated match endpoints
    for k = 1: N-1
        xcell{k}(end) = [];
        ycell{k}(end) = [];
    end

    x_new = vertcat( xcell{:} );
    y_new = vertcat( ycell{:} );
end
