function loopsEdgesInd = triaIso2loop( triaIso, vert, edge )
% triaIso2loop: convert isolate triangular mesh to boundary loops of a 
%               surface region
% plot loopsEdgesInd by function plotLoopsEdgesInd(loopsEdgesInd, edge, vert);

    boundaryEdges = findBoundaryEdges(triaIso);
    loops = groupBoundaryEdgesIntoLoops(boundaryEdges);
    loops = makeOuterBoundaryFirst(loops, vert);
    % plot loops using function plotLoops(loops, vert);

    loopsEdges = convertLoopsToEdgePairs(loops);
    loopsEdgesInd = createLoopsEdgesInd(loopsEdges, edge);
end