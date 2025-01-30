function num_ctrlp = totalNumCtrlPnt( bounds )
% Calculate the total number of control points in all polygonal boundaries.
% Each polygon has at least one ccontrol point (i.e., the starting vertex).
%
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.

    % total number of control points
    num_ctrlp = 0;

    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            % number of control points in one polygon 
            num_ctrlp_1poly = 1 + sum( isnan( bounds{i}{j}(:,1) ) );
            % accumulate
            num_ctrlp = num_ctrlp + num_ctrlp_1poly;
        end
    end

end