%%
clearvars
im = imread("kumamon.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im,'InitialMagnification','fit' );

%%
tol = 0.3;

% image to polygon boundary
boundsRaw = im2Bounds( im );
boundsCtrlP = getCtrlPnts( boundsRaw, false, size(im) );

% smooth boundary
boundsSmooth = smoothBounds( boundsCtrlP, 0.5, -0.5, 100, 0, 0 );

% simplify polygon boundary
boundsSimplified = simplifyBounds( boundsSmooth, tol, 0 );
boundsSimplified = delZeroAreaPoly( boundsSimplified );

% clear up redundant vertices
% only control points and turning points will remain
boundsClear = getCtrlPnts( boundsSimplified );
boundsClear = simplifyBounds( boundsClear, tol/2, 0 );

%%
select_phase = [2  4]';
boundsClear = boundsClear( select_phase );
%%
% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

%%
[ vert,tria,tnum,vert2,tria2 ] = bounds2mesh( boundsClear, 500, 0.25 );
plotMeshes(vert,tria,tnum);

%%
[vert,tria,tnum] = bounds2meshBuiltIn( boundsClear, 1.25, 10, 2 );
plotMeshes(vert,tria,tnum);

%%
% Convert boundaries to a cell array of polyshape object
pcell = bound2polyshape( boundsClear );
% generate mesh
[vert,tria,tnum,vert2,tria2,mesh1,mesh2,model1,model2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, 1.25, 500, 1 );

%%
plotMeshes(vert,tria,tnum);

%%
[ nodecoor_list, ~, ele_cell ] = getNodeEle( vert, tria, tnum );

%%
ele_type = 'CPS3';
precision_nodecoor = 8;
printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision_nodecoor );

%%
[ nodecoor_listQ, ~, ele_cellQ ] = getNodeEle( vert2, tria2, tnum );

%%
ele_type = 'CPS6';
precision_nodecoor = 8;
printInp_multiSect( nodecoor_listQ, ele_cellQ, ele_type, precision_nodecoor );

%%
printBdf( nodecoor_list, ele_cell, precision_nodecoor );















