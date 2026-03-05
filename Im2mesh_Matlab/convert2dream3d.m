function [finalNodes, finalTriangles, nodeTypes, faceLabels] = convert2dream3d(allNodes, allTriangles, phaseIDs)
% convert2dream3d: convert surface mesh to the output format of Dream.3D
% Project website: https://github.com/mjx888/im2mesh
%
    
    globalNodes = [];
    globalTriangles = [];
    phaseArray = [];
    
    exportPhaseIDs = phaseIDs;
    if min(exportPhaseIDs) < 1
        shift_val = 1 - min(exportPhaseIDs);
        exportPhaseIDs = exportPhaseIDs + shift_val;
    end
    
    for i = 1:length(phaseIDs)
        if isempty(allNodes{i}), continue; end
        globalTriangles = [globalTriangles; allTriangles{i} + size(globalNodes, 1)];
        globalNodes = [globalNodes; allNodes{i}];
        phaseArray = [phaseArray; repmat(exportPhaseIDs(i), size(allTriangles{i}, 1), 1)];
    end
    
    if isempty(globalNodes)
        disp('No mesh data to export.'); return;
    end
    
    [~, uniqueIdx, nodeMap] = unique(round(globalNodes, 5), 'rows');
    finalNodes = globalNodes(uniqueIdx, :); 
    mappedTriangles = nodeMap(globalTriangles);
    
    sortedTriangles = sort(mappedTriangles, 2);
    [~, ~, faceIdx] = unique(sortedTriangles, 'rows');
    counts = accumarray(faceIdx, 1);
    
    numFaces = length(counts);
    faceLabels = zeros(numFaces, 2);
    
    [~, firstIdx] = unique(sortedTriangles, 'rows', 'first');
    [~, lastIdx] = unique(sortedTriangles, 'rows', 'last');
    
    finalTriangles = mappedTriangles(firstIdx, :);
    faceLabels(:, 1) = phaseArray(firstIdx); 
    
    sharedMask = (counts == 2);
    faceLabels(sharedMask, 2) = phaseArray(lastIdx(sharedMask)); 
    boundaryMask = (counts == 1);
    faceLabels(boundaryMask, 2) = -1;
    
    N1 = finalTriangles(:, 1); N2 = finalTriangles(:, 2); N3 = finalTriangles(:, 3);
    G1 = faceLabels(:, 1); G2 = faceLabels(:, 2);
    
    nodeFeaturePairs = [N1, G1; N1, G2; N2, G1; N2, G2; N3, G1; N3, G2;];
    uniquePairs = unique(nodeFeaturePairs, 'rows');
    domainCount = accumarray(uniquePairs(:,1), 1, [size(finalNodes,1), 1]);
    
    nodeTypes = domainCount;
    nodeTypes(nodeTypes < 2) = 2; 
    nodeTypes(nodeTypes > 4) = 4; 
    
    minX = min(finalNodes(:,1)); maxX = max(finalNodes(:,1));
    minY = min(finalNodes(:,2)); maxY = max(finalNodes(:,2));
    minZ = min(finalNodes(:,3)); maxZ = max(finalNodes(:,3));
    
    isOuterNode = (abs(finalNodes(:,1) - minX) < 1e-5 | abs(finalNodes(:,1) - maxX) < 1e-5 | ...
                   abs(finalNodes(:,2) - minY) < 1e-5 | abs(finalNodes(:,2) - maxY) < 1e-5 | ...
                   abs(finalNodes(:,3) - minZ) < 1e-5 | abs(finalNodes(:,3) - maxZ) < 1e-5);
                   
    nodeTypes(isOuterNode) = nodeTypes(isOuterNode) + 10;
end