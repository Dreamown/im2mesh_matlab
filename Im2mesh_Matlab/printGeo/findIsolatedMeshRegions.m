function [components] = findIsolatedMeshRegions(P, T)
%FINDISOLATEDMESHREGIONS Find connected components (isolated triangular regions).
%
%   INPUTS:
%       P : (nPts x 2) or (nPts x 3) array of point coordinates
%       T : (nTri x 3) array of triangle vertex indices
%
%   OUTPUTS:
%       components : (nTri x 1) array, where components(i) is the index of
%                    the connected component to which triangle i belongs.

    % Number of triangles
    nTri = size(T, 1);
    % Number of vertices
    nPts = size(P, 1);
    
    % --- Step 1: Build adjacency for triangles ---
    %
    % We'll say two triangles are "adjacent" if they share at least one vertex.
    % Another common definition is if they share an edge, but sharing a vertex
    % is enough to consider them in the same connected region for a typical mesh.
    %
    % To do that efficiently, we can map each vertex -> list of triangles that use it.
    
    triOfVertex = cell(nPts, 1);
    for triIdx = 1:nTri
        v1 = T(triIdx,1);
        v2 = T(triIdx,2);
        v3 = T(triIdx,3);
        triOfVertex{v1}(end+1) = triIdx;
        triOfVertex{v2}(end+1) = triIdx;
        triOfVertex{v3}(end+1) = triIdx;
    end
    
    % Now build adjacency lists for each triangle.
    adjacency = cell(nTri, 1);
    for v = 1:nPts
        % Triangles that share vertex v
        triList = triOfVertex{v};
        % Connect all triangles in triList to each other
        % (they share vertex v).
        for i = 1:length(triList)
            for j = i+1:length(triList)
                tA = triList(i);
                tB = triList(j);
                adjacency{tA}(end+1) = tB;
                adjacency{tB}(end+1) = tA;
            end
        end
    end
    
    % Remove duplicates from adjacency lists (optional, but often helpful)
    for triIdx = 1:nTri
        adjacency{triIdx} = unique(adjacency{triIdx});
    end

    % --- Step 2: Find connected components with DFS or BFS ---
    visited = false(nTri, 1);
    componentID = zeros(nTri, 1);
    currentComp = 0;

    for startTri = 1:nTri
        if ~visited(startTri)
            % We found a new component
            currentComp = currentComp + 1;
            % Depth-first search (DFS) or BFS from startTri
            stack = [startTri];
            visited(startTri) = true;
            componentID(startTri) = currentComp;
            
            while ~isempty(stack)
                thisTri = stack(end);
                stack(end) = [];  %# pop
                
                % Look at neighbors
                neighbors = adjacency{thisTri};
                for nb = neighbors
                    if ~visited(nb)
                        visited(nb) = true;
                        componentID(nb) = currentComp;
                        stack(end+1) = nb; %# push
                    end
                end
            end
        end
    end
    
    % componentID(i) holds the connected component index of triangle i
    components = componentID;  % rename for output
end
