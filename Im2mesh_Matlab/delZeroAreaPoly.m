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
%   Jiexian Ma, mjx0799@gmail.com, Oct 2020

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
end