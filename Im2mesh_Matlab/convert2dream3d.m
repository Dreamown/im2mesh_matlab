function [finalNodes, finalTriangles, nodeTypes, faceLabels] = convert2dream3d(allNodes, allTriangles, phaseIDs)
% convert2dream3d: convert individual phase meshes into a global DREAM.3D 
% compatible surface mesh.
%
% This function takes independently generated surface meshes (nodes and triangles) 
% for multiple individual phases (or grains) and combines them into a single, 
% globally unified mesh. It removes duplicate nodes, resolves shared faces 
% between adjacent phases, assigns phase labels to both sides of each face, 
% and classifies the topological type of every node based on phase connectivity 
% and boundary proximity.
%
% usage:
%	[finalNodes, finalTriangles, nodeTypes, faceLabels] = convert2dream3d(allNodes, allTriangles, phaseIDs);
%
% Inputs:
%   allNodes     - A 1D cell array of length numPhases. Each cell contains an 
%                  N_i-by-3 numeric array of node (vertex) coordinates [X, Y, Z] 
%                  for phase i.
%
%   allTriangles - A 1D cell array of length numPhases. Each cell contains an 
%                  M_i-by-3 numeric array of triangle connectivities for phase i, 
%                  referencing local nodes within the corresponding allNodes cell.
%
%   phaseIDs     - A 1D numeric array of length numPhases containing the unique 
%                  identifiers (e.g., Grain IDs or Phase IDs) for each mesh group.
%
% Outputs:
%   finalNodes     - A K-by-3 numeric array of all unique global node coordinates.
%
%   finalTriangles - An L-by-3 numeric array of global triangle connectivities 
%                    referencing the row indices of finalNodes.
%
%   nodeTypes      - A K-by-1 numeric array labeling the topological type of each node:
%                       2: Normal Vertex (touches 1 or 2 phases)
%                       3: Triple Line (touches 3 phases)
%                       4: Quadruple Point (touches 4 or more phases)
%                      12: Normal Vertex on the outer boundary surface
%                      13: Triple Line on the outer boundary surface
%                      14: Quadruple Point on the outer boundary surface
%
%   faceLabels     - An L-by-2 numeric array where each row contains the phaseIDs 
%                    of the two phases sharing the corresponding triangle in 
%                    finalTriangles. If the face is on an outer boundary 
%                    (unshared), the second column will be -1.
%
% Notes:
%   Highly optimized conversion for large datasets utilizing sparse matrices, 
%   integer coordinate matching, and single-pass topological compilation.
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

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