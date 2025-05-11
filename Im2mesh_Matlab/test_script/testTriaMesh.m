%%
clearvars
im = imread("kumamon.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im,'InitialMagnification','fit' );

%%
% image to polygon boundary
boundsRaw = im2Bounds( im );
boundsCtrlP = getCtrlPnts( boundsRaw, false, size(im) );

% smooth boundary
boundsSmooth = smoothBounds( boundsCtrlP, 0.5, -0.5, 100, 0, 0 );

% simplify polygon boundary
boundsSimplified = simplifyBounds( boundsSmooth, 0.3, 0 );
boundsSimplified = delZeroAreaPoly( boundsSimplified );

% clear up redundant vertices
% only control points and turning points will remain
boundsClear = getCtrlPnts( boundsSimplified, false );
boundsClear = simplifyBounds( boundsClear, 0 );

%%
select_phase = [2  4]';
boundsClear = boundsClear( select_phase );

%%
[vert,tria,tnum] = bounds2mesh( boundsClear, 500, 0.5 );
plotMeshes(vert,tria,tnum);

%%


%%
% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

%%
[ vert,tria,tnum,vert2,tria2,conn ] = poly2mesh( poly_node, poly_edge, ...
                                500, 'delaunay', 0.25 );

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















