function loops = groupBoundaryEdgesIntoLoops(boundaryEdges)
%GROUPBOUNDARYEDGESINTOLOOPS Group boundary edges into separate loops.
%  
%  boundaryEdges : (nBdryEdges x 2), each row [v1, v2] (no strict requirement of v1 < v2).
%  loops         : cell array of loops; loops{i} is a list of vertex IDs [v1, v2, ..., vK]
%                  that form a closed boundary chain. The last vertex typically equals the first.
%
%  This function attempts to trace out boundary loops edge by edge. It avoids infinite
%  loops by picking one unvisited "next" edge at each vertex. If there's branching
%  (multiple possible next edges), it picks the first one. Any remaining unvisited edges
%  from that branching point will start a new loop in the next iteration.

    if isempty(boundaryEdges)
        loops = {};
        return;
    end

    %--- 1) Build adjacency from vertex -> boundary neighbors
    allVerts = unique(boundaryEdges(:));
    adjMap = containers.Map('KeyType','double','ValueType','any');
    for v = allVerts(:)'
        adjMap(v) = [];
    end
    
    for i = 1:size(boundaryEdges, 1)
        v1 = boundaryEdges(i,1);
        v2 = boundaryEdges(i,2);
        adjMap(v1) = [adjMap(v1), v2];
        adjMap(v2) = [adjMap(v2), v1];
    end
    
    %--- 2) Keep track of visited edges
    nEdges = size(boundaryEdges,1);
    visitedEdges = false(nEdges, 1);

    % We create a map from (v1-v2 or v2-v1) -> edge index,
    % so we can easily find which edge index corresponds to a pair of vertices.
    edgeMap = containers.Map('KeyType','char','ValueType','double');
    for e = 1:nEdges
        v1 = boundaryEdges(e,1);
        v2 = boundaryEdges(e,2);
        k1 = sprintf('%d-%d', v1, v2);
        k2 = sprintf('%d-%d', v2, v1);
        edgeMap(k1) = e;
        edgeMap(k2) = e;  % same edge index for reversed pair
    end
    
    getKey = @(a,b) sprintf('%d-%d', a, b);
    
    %--- 3) Find loops by traversing unvisited edges
    loops = {};
    for e = 1:nEdges
        if ~visitedEdges(e)
            % Start a new loop from this unvisited edge
            v1 = boundaryEdges(e,1);
            v2 = boundaryEdges(e,2);
            
            loop = [v1, v2];
            visitedEdges(e) = true;  % mark this edge visited
            
            currentVertex = v2;
            prevVertex    = v1;
            
            % Keep moving forward around the loop
            while true
                neighbors = adjMap(currentVertex);
                
                % Remove the vertex we came from
                neighbors(neighbors == prevVertex) = [];
                
                % Among these neighbors, find any unvisited edges
                unvisitedNext = [];
                for cand = neighbors
                    eIdx = edgeMap(getKey(currentVertex, cand));
                    if ~visitedEdges(eIdx)
                        unvisitedNext(end+1) = cand; %#ok<AGROW>
                    end
                end
                
                if isempty(unvisitedNext)
                    % No unvisited edge extends from currentVertex
                    % => we can't proceed further to close a loop.
                    break;
                end
                
                % In case of branching, pick the first unvisited neighbor
                nextVertex = unvisitedNext(1);
                
                % Mark that edge visited
                nextEdgeIdx = edgeMap(getKey(currentVertex, nextVertex));
                visitedEdges(nextEdgeIdx) = true;
                
                % Add nextVertex to the loop
                loop(end+1) = nextVertex; %#ok<AGROW>
                
                % Advance
                prevVertex = currentVertex;
                currentVertex = nextVertex;
                
                % Check if we've come full circle
                if currentVertex == v1
                    % Loop is closed
                    break;
                end
            end
            
            loops{end+1} = loop; %#ok<AGROW>
        end
    end
end
