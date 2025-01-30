function num_vert = totalNumVertex( bounds )
% calculate the total number of vertices in all polygonal boundaries
%
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.

    % get total number of vertices
    num_vert = 0;
    
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            num_vert = num_vert + length(bounds{i}{j}) - 1;
        end
    end

end