%%
clearvars
im = imread("Shape.tif");
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

% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

%%
[ vert,tria,tnum,vert2,tria2 ] = poly2mesh( poly_node, poly_edge, ...
                                opt.hmax, opt.mesh_kind, opt.grad_limit );

%%
% Convert boundaries to a cell array of polyshape object
pcell = bound2polyshape( boundsClear );
% generate mesh
[vert,tria,tnum,vert2,tria2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, 1.25, 500, 1 );

%%
plotMeshes(vert,tria,tnum);