function plotLoops(loops, P)
%PLOTLOOPS Plots each loop in the cell array `loops` as a polyline.
%
%  loops : cell array where loops{i} is a row vector of vertex indices
%  P     : (nPts x 2) array of vertex coordinates

    figure; hold on; axis equal;
    for i = 1:numel(loops)
        loopVerts = loops{i};
        coords = P(loopVerts, :);
        
        % Optionally close the loop by repeating the first point at the end:
        coords(end+1,:) = coords(1,:);
        
        % Plot the loop
        plot(coords(:,1), coords(:,2), '-o', 'LineWidth',1.2);
        
        % (Optional) label loops
        text(mean(coords(:,1)), mean(coords(:,2)), sprintf('Loop %d', i), ...
             'Color','r','FontWeight','bold');
    end
    
    title('Boundary Loops');
end
