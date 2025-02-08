function bounds = delZeroAreaPoly( bounds )
% delete polygon with zero area
%
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.
%
%   Jiexian Ma, mjx0799@gmail.com, Feb 2025

    %----------------------------------------------------------------------
    % find sub-polygon in bounds{i}{j} with zero area
    
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            % check bounds{i}{j}

            % convert a polygon to cell array that consists of polylines
            % x, y are N-by-1 cell arrays with one polygon segment per cell
            [x, y] = polysplit( bounds{i}{j}(:,1), bounds{i}{j}(:,2) );

             % normal case
            if numel(x) == 1
                continue   
            end
            
            % something wierd happen
            % need to delete wierd sub-polygon with zero area
            mark_empty_segment = false( numel(x), 1 );

            for k = 1: numel(x)
                if polyarea( x{k}, y{k} ) == 0
                    mark_empty_segment(k) = true;
                end
            end

            % delete wierd sub-polygon with zero area
            x(mark_empty_segment) = [];
            y(mark_empty_segment) = [];

            if numel(x) ~= 1
                error("BAD input")
            end

            % update bounds{i}{j}
            bounds{i}{j} = [ x{1}, y{1} ];
        end
    end

    %---------------------------------------------------------------------
    % find polygon bounds{i}{j} with zero area

    mark_empty_bounds = false( length(bounds), 1 );
    
    for i = 1: length(bounds)
        mark_zero_poly = false( length(bounds{i}), 1 );
        % check bounds{i}{j}
        for j = 1: length(bounds{i})
            if polyarea( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) == 0
                mark_zero_poly(j) = true;
            end
        end      
        bounds{i}( mark_zero_poly ) = [];   % delete bounds{i}{j}
        
        % check bounds{i}
        if isempty(bounds{i})
            mark_empty_bounds(i) = true;
        end
    end
    
    bounds( mark_empty_bounds ) = [];       % delete bounds{i}
    %----------------------------------------------------------------------
end