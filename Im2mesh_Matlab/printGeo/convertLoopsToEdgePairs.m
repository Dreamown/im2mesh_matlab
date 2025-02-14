function loopsEdges = convertLoopsToEdgePairs(loops)
%CONVERTLOOPSTOEDGEPAIRS Convert each CLOSED loop of vertex indices into Mx2 edge pairs.
%
%  loops : cell array, where each loops{i} = [v1, v2, ..., vN, v1].
%          That is, the loop is already closed (the last vertex repeats the first).
%
%  loopsEdges : cell array of the same size as 'loops'.
%               loopsEdges{i} is an M-by-2 array of vertex indices (each row is one edge).
%               For a loop with length N, you get N-1 edges (the last pair is (vN, v1)).

    nLoops = numel(loops);
    loopsEdges = cell(size(loops));

    for i = 1:nLoops
        thisLoop = loops{i};
        
        % If the loop is closed (v1 == v(end)), then the number of actual edges
        % is length(thisLoop) - 1. Each edge is (v_i, v_{i+1}).
        % For example, [v1, v2, ..., vN, v1] => edges:
        %   (v1, v2)
        %   (v2, v3)
        %   ...
        %   (v_{N-1}, vN)
        %   (vN, v1)
        
        edges = [thisLoop(1:end-1)', thisLoop(2:end)'];
        
        loopsEdges{i} = edges;
    end
end
