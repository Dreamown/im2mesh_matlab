function components = findIsolatedMeshRegions(P, T)
%FINDISOLATEDMESHREGIONS Identify connected components where triangles sharing
% only a vertex are considered disconnected (isolated).
%
% INPUTS:
%   P : (nPts x 2) or (nPts x 3) array of point coordinates (not actually used below)
%   T : (nTri x 3) array of triangle vertex indices
%
% OUTPUT:
%   components : (nTri x 1) array, where components(i) is the index of
%                the connected component to which triangle i belongs,
%                based on sharing *edges* (2 vertices), not just a point.

    nTri = size(T, 1);

    %----------------------------------------------------------------------
    % STEP 1: Build adjacency list so triangles are neighbors only if
    %         they share an entire edge (2 vertices).
    %----------------------------------------------------------------------

    % 1A) Create a map from "edge" -> list of triangle indices that use that edge.
    %     We'll store edges in a canonical form [min, max].
    edgeMap = containers.Map('KeyType','char','ValueType','any');

    for triIdx = 1:nTri
        v = T(triIdx, :);
        % The 3 edges of triangle triIdx:
        edgesTri = [v(1), v(2);
                    v(2), v(3);
                    v(3), v(1)];
        % Sort each row so edge = [min,max]
        edgesTri = sort(edgesTri, 2);

        for e = 1:3
            ePair = edgesTri(e,:);
            key = sprintf('%d-%d', ePair(1), ePair(2));  % e.g. "3-5"
            if ~edgeMap.isKey(key)
                edgeMap(key) = triIdx;  % store just one triangle, or a list
            else
                val = edgeMap(key);
                if ~iscell(val)
                    % convert to cell array if needed
                    val = {val};
                end
                val{end+1} = triIdx; %#ok<AGROW>
                edgeMap(key) = val;
            end
        end
    end

    % 1B) From the edgeMap, build an adjacency list for each triangle.
    adjacency = cell(nTri, 1);
    keysList = edgeMap.keys;
    for i = 1:numel(keysList)
        key = keysList{i};
        val = edgeMap(key);

        if ~iscell(val)
            % Only one triangle had this edge => no adjacency
            continue;
        end

        % If multiple triangles share this same edge, they are neighbors
        triList = [val{:}];  % array of triangle indices
        % Connect all pairs in triList
        for a = 1:length(triList)
            for b = a+1:length(triList)
                tA = triList(a);
                tB = triList(b);
                adjacency{tA}(end+1) = tB; %#ok<AGROW>
                adjacency{tB}(end+1) = tA; %#ok<AGROW>
            end
        end
    end

    % Remove duplicates
    for triIdx = 1:nTri
        adjacency{triIdx} = unique(adjacency{triIdx});
    end

    %----------------------------------------------------------------------
    % STEP 2: Find connected components (based on the adjacency via edges).
    %----------------------------------------------------------------------
    visited = false(nTri, 1);
    components = zeros(nTri, 1);
    currentComp = 0;

    for startTri = 1:nTri
        if ~visited(startTri)
            currentComp = currentComp + 1;
            % Depth-first search (DFS) or BFS
            stack = [startTri];
            visited(startTri) = true;
            components(startTri) = currentComp;

            while ~isempty(stack)
                thisTri = stack(end);
                stack(end) = [];  % pop

                % Neighbors of thisTri
                nbrs = adjacency{thisTri};
                for nb = nbrs
                    if ~visited(nb)
                        visited(nb) = true;
                        components(nb) = currentComp;
                        stack(end+1) = nb; %#ok<AGROW> % push
                    end
                end
            end
        end
    end
end
