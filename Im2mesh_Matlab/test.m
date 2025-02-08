clearvars
%%
im = imread("C:\Users\Jason\Downloads\cod\Im2mesh 2.1\myGUI_v2.1\image set 3 Lu\t12.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
%%
boundsRaw = im2Bounds( im );
% label control points
tf_avoid_sharp_corner = false;
boundsCtrlP = getCtrlPnts( boundsRaw, tf_avoid_sharp_corner, size(im) );

lambda = 0.5;
mu = -0.5;
iters = 100;
threshold_num_turning = 10;
threshold_num_vert_Smo = 10;

boundsSmooth = smoothBounds( boundsCtrlP, lambda, mu, iters, ...
                threshold_num_turning, threshold_num_vert_Smo );

% simplify polygon boundary
tolerance = 0.3;
threshold_num_vert_Sim = 10;
boundsSimplified = simplifyBounds( boundsSmooth, tolerance, ...
                                        threshold_num_vert_Sim );
boundsSimplified = delZeroAreaPoly( boundsSimplified );

% clear up redundant vertices
% only control points and turning points will remain
boundsClear = getCtrlPnts( boundsSimplified, false );
boundsClear = simplifyBounds( boundsClear, 0 );

grad_limit = 0.25;
hmax = 500;
mesh_kind = 'delaunay';

% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

%%
% Convert boundaries to a cell array of polyshape object
pcell = bound2polyshape( boundsClear );
% generate triangular mesh
[vert,tria,tnum,vert2,tria2] = poly2meshBuiltIn( poly_node, poly_edge, pcell, 1.25, 500, 1 );

%%
