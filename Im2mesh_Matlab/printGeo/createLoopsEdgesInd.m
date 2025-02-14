function loopsEdgesInd = createLoopsEdgesInd(loopsEdges, edges)
%CREATELOOPSEDGESIND Create a cell array storing the signed edge indices for each loop.
%
%  loopsEdges : cell array where loopsEdges{i} is (M_i x 2), the edges of loop i.
%               Each row is [v1, v2] in the orientation of that loop's boundary.
%
%  edges      : (N x 2) global array of edges.
%               Each row edges(k,:) = [v1, v2] indicates the orientation as well.
%
%  loopsEdgesInd : cell array of the same size as loopsEdges.
%                  loopsEdgesInd{i} is a column vector of length M_i.
%                  For an edge [v1, v2] in loopsEdges{i}, if edges(k,:) = [v1, v2],
%                  then loopsEdgesInd{i}(j) = +k.
%                  If edges(k,:) = [v2, v1], then loopsEdgesInd{i}(j) = -k.
%
%  ASSUMPTION: 1-based indexing for vertices and edges (standard in MATLAB).
%              If you have 0-based elsewhere, adjust accordingly.

    nLoops = numel(loopsEdges);
    loopsEdgesInd = cell(size(loopsEdges));
    
    %---------------------------------
    % 1) Build a map from "v1-v2" to signed edge index
    %---------------------------------
    edgeMap = containers.Map('KeyType','char','ValueType','int32');
    
    nEdgesGlobal = size(edges, 1);
    for k = 1:nEdgesGlobal
        v1 = edges(k,1);
        v2 = edges(k,2);
        
        % orientation as stored
        directKey = sprintf('%d-%d', v1, v2);  
        % reversed orientation
        revKey    = sprintf('%d-%d', v2, v1);
        
        % If someone tries to insert a duplicate key, you'd get an error.
        % For a well-defined mesh, each edge should appear exactly once in a given orientation.
        % But to be safe, you might want to check edgeMap.isKey(directKey) etc.
        
        edgeMap(directKey) = +k;  % same orientation => +k
        edgeMap(revKey)    = -k;  % reversed => -k
    end
    
    %---------------------------------
    % 2) For each loop, build a signed index array
    %---------------------------------
    for i = 1:nLoops
        thisEdges = loopsEdges{i};  % M_i x 2
        M = size(thisEdges,1);
        edgeIdxList = zeros(M,1,'int32');  %# for storing signed indices
        
        for j = 1:M
            v1 = thisEdges(j,1);
            v2 = thisEdges(j,2);
            
            key = sprintf('%d-%d', v1, v2);
            if edgeMap.isKey(key)
                edgeIdxList(j) = edgeMap(key);
            else
                % If we don't find it in the map, then something is off
                % (edge does not exist in the global 'edges' list).
                % You could throw an error or store 0 as a sentinel.
                error('Edge [%d %d] not found in global edges.', v1, v2);
            end
        end
        
        loopsEdgesInd{i} = edgeIdxList;  % store as a column vector
    end
end
