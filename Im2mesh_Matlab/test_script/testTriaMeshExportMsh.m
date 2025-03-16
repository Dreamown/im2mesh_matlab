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
boundsClear = boundsClear([1,3]);
%%
plotBounds(boundsClear)
%%
% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

%%
[ vert,tria,tnum,~,~,conn ] = poly2mesh( poly_node, poly_edge, ...
                                        500, 'delaunay', 0.25 );

%%
plotMeshes(vert,tria,tnum);
%%
precision_nodecoor = 5;
path_file_name = '2025.msh';

%%
clc
%%
printMsh( vert );
%%
printMsh( vert, tria );
%%
printMsh( vert, tria, tnum );
%%
printMsh( vert, tria, [], [], precision_nodecoor );
%%
printMsh( vert, tria, tnum, [], precision_nodecoor );
%%
printMsh( vert, tria, tnum, conn, precision_nodecoor );
%%
printMsh( vert, tria, tnum, [], precision_nodecoor, path_file_name );


%%
vert(:,3) = vert(:,1);
%%
tria(:,4) = tria(:,1);
%%
printMsh( vert );
%%
printMsh( vert, tria );
%%
printMsh( vert, tria, tnum );















































