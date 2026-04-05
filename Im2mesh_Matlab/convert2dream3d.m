function [finalNodes, finalTriangles, nodeTypes, faceLabels] = convert2dream3d(allNodes, allTriangles, phaseIDs)
% convert2dream3d: 
% highly optimized conversion for large datasets
%
% 'nodeTypes', N-by-1 array, is the label for node type. The label is as follows.
% 2: Normal Vertex
% 3: Triple Line
% 4: Quadruple Point
% 12: Normal Vertex on the outer surface
% 13: Triple Line on the outer surface
% 14: Quadruple Point on the outer surface
    
    numPhases = length(phaseIDs);
    
    % --- OPTIMIZATION 1: Preallocate global arrays ---
    numNodes = zeros(numPhases, 1);
    numTris = zeros(numPhases, 1);
    for i = 1:numPhases
        numNodes(i) = size(allNodes{i}, 1);
        numTris(i) = size(allTriangles{i}, 1);
    end
    
    totalNodes = sum(numNodes);
    totalTris  = sum(numTris);
    
    if totalNodes == 0
        disp('No mesh data to export.');
        finalNodes = []; finalTriangles = []; nodeTypes = []; faceLabels = [];
        return;
    end
    
    globalNodes = zeros(totalNodes, 3);
    globalTriangles = zeros(totalTris, 3);
    phaseArray = zeros(totalTris, 1);
    
    exportPhaseIDs = phaseIDs;
    if min(exportPhaseIDs) < 1
        exportPhaseIDs = exportPhaseIDs + (1 - min(exportPhaseIDs));
    end
    
    nodeOffset = 0;
    triOffset = 0;
    for i = 1:numPhases
        n = numNodes(i);
        t = numTris(i);
        if n == 0, continue; end
        
        globalNodes(nodeOffset+1 : nodeOffset+n, :) = allNodes{i};
        globalTriangles(triOffset+1 : triOffset+t, :) = allTriangles{i} + nodeOffset;
        phaseArray(triOffset+1 : triOffset+t) = repmat(exportPhaseIDs(i), t, 1);
        
        nodeOffset = nodeOffset + n;
        triOffset = triOffset + t;
    end
    
    % --- OPTIMIZATION 2: Fast Integer Node Uniquification ---
    % Convert to int64 before 'unique' matching - dramatically faster than rounding floats
    intNodes = int64(round(globalNodes * 1e5));
    [~, uniqueIdx, nodeMap] = unique(intNodes, 'rows');
    finalNodes = globalNodes(uniqueIdx, :); 
    mappedTriangles = nodeMap(globalTriangles);
    
    % --- OPTIMIZATION 3: Single-pass Triangle & Face Compilation ---
    sortedTriangles = sort(mappedTriangles, 2);
    
    % Call unique exactly once instead of 3 times
    [finalTriangles, firstIdx, faceIdx] = unique(sortedTriangles, 'rows', 'first');
    counts = accumarray(faceIdx, 1);
    
    numFaces = length(counts);
    faceLabels = zeros(numFaces, 2);
    faceLabels(:, 1) = phaseArray(firstIdx); 
    faceLabels(:, 2) = -1; % Default boundary label
    
    % O(N) Trick to find second phase for shared faces without another sort
    sharedMask = (counts == 2);
    sumPhases = accumarray(faceIdx, phaseArray);
    faceLabels(sharedMask, 2) = sumPhases(sharedMask) - faceLabels(sharedMask, 1);
    
    % --- OPTIMIZATION 4: Sparse Matrix Node Type Evaluation ---
    N1 = finalTriangles(:, 1); N2 = finalTriangles(:, 2); N3 = finalTriangles(:, 3);
    G1 = faceLabels(:, 1);     G2 = faceLabels(:, 2);
    
    % Shift phase IDs uniformly to strictly positive integers
    shiftG = 1 - min(min(G1), min(G2)); 
    
    % Stack up all node and phase connections (6 per face)
    N_all = double([N1; N1; N2; N2; N3; N3]);
    G_all = double([G1; G2; G1; G2; G1; G2]) + shiftG;
    
    % Creating a sparse matrix naturally collapses identical combinations
    % S(Node, Phase) = 1, converting massive combination checks into an instant boolean matrix
    S = sparse(N_all, G_all, 1, size(finalNodes, 1), max(G_all));
    domainCount = full(sum(S > 0, 2)); % Total unique phases touching each node
    
    nodeTypes = domainCount;
    nodeTypes(nodeTypes < 2) = 2; 
    nodeTypes(nodeTypes > 4) = 4; 
    
    % --- OPTIMIZATION 5: Boundary Condition Trimming ---
    % Using pure logical arrays, avoiding slower 'abs' checks
    minX = min(finalNodes(:,1)); maxX = max(finalNodes(:,1));
    minY = min(finalNodes(:,2)); maxY = max(finalNodes(:,2));
    minZ = min(finalNodes(:,3)); maxZ = max(finalNodes(:,3));
    
    tol = 1e-5;
    isOuterNode = (finalNodes(:,1) <= minX + tol) | (finalNodes(:,1) >= maxX - tol) | ...
                  (finalNodes(:,2) <= minY + tol) | (finalNodes(:,2) >= maxY - tol) | ...
                  (finalNodes(:,3) <= minZ + tol) | (finalNodes(:,3) >= maxZ - tol);
                   
    nodeTypes(isOuterNode) = nodeTypes(isOuterNode) + 10;
end