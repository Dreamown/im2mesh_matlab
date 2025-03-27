%%
% input boundsCtrlP
%%
clearvars
im = imread("kumamon-1.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im,'InitialMagnification','fit' );

%%
% image to polygon boundary
boundsRaw = im2Bounds( im );
boundsCtrlP = getCtrlPnts( boundsRaw, false, size(im) );
%%
plotBounds( boundsCtrlP )


%%
boundsCtrlP = bluntSharpCorner( boundsCtrlP );

%%
plotBounds(boundsCtrlP)

%%
boundsSmooth = smoothBounds( boundsCtrlP, 0.5, -0.5, 100, 10, 10 );

%%

% simplify polygon boundary
boundsSimplified = simplifyBounds( boundsSmooth, 0.5, 10 );
boundsSimplified = delZeroAreaPoly( boundsSimplified );

% clear up redundant vertices
% only control points and turning points will remain
boundsClear = getCtrlPnts( boundsSimplified, false );
boundsClear = simplifyBounds( boundsClear, 0 );

% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

[ vert,tria,tnum ] = poly2mesh( poly_node, poly_edge, ...
                                500, 'delaunay', 0.25 );

plotMeshes(vert,tria,tnum);
































