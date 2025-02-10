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
                    poly_temp = dpsimplify( poly_O, tolerance );
                    
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
            
            if isnan( poly(end,1) )
                poly = poly( 1:end-1, : );  % delete last NaN
            else
                error('not ending with NaN');
            end
            bounds{i}{j} = poly;
        end
    end
end
