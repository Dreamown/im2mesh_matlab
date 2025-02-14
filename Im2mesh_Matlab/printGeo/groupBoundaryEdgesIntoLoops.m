function loops = groupBoundaryEdgesIntoLoops(boundaryEdges)
%GROUPBOUNDARYEDGESINTOLOOPS Group boundary edges into separate loops.
%
%  boundaryEdges: (nBdryEdges x 2), each row [v1, v2] with v1 < v2
%  loops        : cell array of loops; each loop is a sequence of vertex IDs
%                 that forms a closed boundary chain.

    % Create adjacency list: vertex -> neighbors
    allVerts = unique(boundaryEdges);
    adjMap = containers.Map('KeyType','double','ValueType','any');
    for v = allVerts(:)'
        adjMap(v) = [];
    end
    
    % Fill adjacency
    for i = 1:size(boundaryEdges,1)
        v1 = boundaryEdges(i,1);
        v2 = boundaryEdges(i,2);
        adjMap(v1) = [adjMap(v1), v2];
        adjMap(v2) = [adjMap(v2), v1];
    end
    
    visitedEdges = false(size(boundaryEdges,1),1);
    loops = {};
    
    % We also need an edge lookup table to mark edges visited
    % (key = [min, max], value = index in boundaryEdges)
    edgeMap = containers.Map('KeyType','char','ValueType','double');
    for e = 1:size(boundaryEdges,1)
        v1 = boundaryEdges(e,1);
        v2 = boundaryEdges(e,2);
        keyStr = sprintf('%d-%d', v1, v2);
        edgeMap(keyStr) = e;
    end
    
    % A function to find the (unique) key for an edge
    getKey = @(a,b) sprintf('%d-%d', min(a,b), max(a,b));
    
    for e = 1:size(boundaryEdges,1)
        if ~visitedEdges(e)
            % Start a new loop
            v1 = boundaryEdges(e,1);
            v2 = boundaryEdges(e,2);
            
            loop = [v1, v2];
            visitedEdges(e) = true;
            
            % Walk forward from v2 until we come back to v1
            currentVertex = v2;
            prevVertex = v1;

            counter = 0;

            while true
                neighbors = adjMap(currentVertex);
                
                % We want the neighbor that is NOT 'prevVertex'
                % In a closed loop, each interior vertex on the boundary
                % should have exactly 2 neighbors: prevVertex and next.
                nextVertex = neighbors(neighbors ~= prevVertex);
                
                if isempty(nextVertex)
                    % Something is not right or we reached an endpoint
                    break;
                end
                nextVertex = nextVertex(1); % typically there's exactly one

                % Mark edge [currentVertex, nextVertex] as visited
                edgeIdx = edgeMap(getKey(currentVertex, nextVertex));
                visitedEdges(edgeIdx) = true;
                
                loop(end+1) = nextVertex; %#ok<AGROW>
                
                % Move forward
                prevVertex = currentVertex;
                currentVertex = nextVertex;
                
                % If we have returned to v1, the loop is closed
                if currentVertex == v1
                    break;
                end

                counter = counter+1;
                if counter>1000
                    break;
                end
            end
            
            loops{end+1} = loop; %#ok<AGROW>
        end
    end
end
