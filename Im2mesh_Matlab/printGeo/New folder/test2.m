% vert = [0 0; 1 0; 1 1; 0 1; 2 0; 3 0; 3 1; 2 1];
% tria = [1 2 4; 2 3 4; 5 6 8; 6 7 8];
% tnum = 1+zeros(size(tria,1),1);

%% vert,tria,tnum)
plotMeshes(vert,tria,tnum);

%%
triaN = tria(tnum==1,:);

%%
components = findIsolatedMeshRegions(vert, triaN);

%% Isolated
I = 1;
triaI = triaN( components == I, : );

%%
boundaryEdges = findBoundaryEdges(triaI);

%%
loops = groupBoundaryEdgesIntoLoops(boundaryEdges);

%%
loops = makeOuterBoundaryFirst(loops, vert);

%% 
plotLoops(loops, vert)

%%
plotLoops(loops(1:3), vert)

%%
loopsEdges = convertLoopsToEdgePairs(loops);

%% Need edges
loopsEdgesInd = createLoopsEdgesInd(loopsEdges, edge);











