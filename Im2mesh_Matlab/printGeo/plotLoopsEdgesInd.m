function plotLoopsEdgesInd(loopsEdgesInd, edges, P)
%PLOTLOOPSEDGESIND Visualize loops from their signed edge indices.
%
%  loopsEdgesInd : cell array where loopsEdgesInd{i} is a column vector of signed edge indices.
%                  If loopsEdgesInd{i}(j) = +k, edge is edges(k,:) in that orientation.
%                  If loopsEdgesInd{i}(j) = -k, edge is edges(k,:) reversed.
%
%  edges         : (N x 2) global array of edges.
%  P             : (nPts x 2) coordinates for each vertex ID in [1..nPts].
%
%  This function plots each loop in a separate color, connecting consecutive edges
%  as they appear in loopsEdgesInd{i}. If the loop is truly a closed boundary,
%  the last edge should connect to the first, but we rely on your data to ensure that.

    figure; hold on; axis equal;  % For a nice aspect ratio
    
    nLoops = numel(loopsEdgesInd);
    colors = lines(nLoops);  % Get some distinct plot colors
    
    for i = 1:nLoops
        signedEdges = loopsEdgesInd{i};  % M x 1 column vector
        M = numel(signedEdges);
        
        % We'll collect the 2D coordinates of the loop's vertices in order
        % from the signed edges. Because each edge is a pair of vertices,
        % we need to piece them together carefully.
        
        loopCoords = zeros(M+1, 2);  % We'll store M+1 vertices (closing the loop)
        
        for j = 1:M
            eSign = signedEdges(j);
            eIdx  = abs(eSign);      % the index into 'edges'
            e     = edges(eIdx,:);   % row [v1, v2] in global edges
            
            if eSign < 0
                % If negative, the loop's orientation is reversed
                e = fliplr(e);  % swap columns => [v2, v1]
            end
            
            % e is now [vStart, vEnd]
            % We'll place them in loopCoords in a consecutive manner.
            
            if j == 1
                % For the first edge, store both vertices
                loopCoords(j,  :) = P(e(1), :);  % coords of vStart
                loopCoords(j+1,:) = P(e(2), :);  % coords of vEnd
            else
                % For subsequent edges, we only need to store the end vertex
                % because the start vertex should match the end of the previous edge
                loopCoords(j+1,:) = P(e(2), :);
            end
        end
        
        % Now plot the loop as a polyline
        plot(loopCoords(:,1), loopCoords(:,2), '-o', ...
             'Color', colors(i,:), ...
             'LineWidth',1.5, 'MarkerSize',4, 'MarkerFaceColor', colors(i,:));
        
        % Optionally label the loop
        midPt = mean(loopCoords,1);
        text(midPt(1), midPt(2), sprintf('Loop %d', i), ...
             'Color', colors(i,:), 'FontWeight','bold', ...
             'HorizontalAlignment','center');
    end
    
    title('Loops Visualized from loopsEdgesInd');
end
