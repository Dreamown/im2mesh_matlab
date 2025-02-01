%% *demo04 of Im2mesh package*
% demo04 - Demonstrate what is inside function im2mesh.
%% 
% 
%% ------------------------------------------------------------------------
%% Note
% I suggest familiarizing yourself with Im2mesh_GUI before learning Im2mesh. 
% With graphical user interface, Im2mesh_GUI will help you better understand the 
% workflow and parameters of Im2mesh.
% 
% Im2mesh_GUI: <https://www.mathworks.com/matlabcentral/fileexchange/179684-im2mesh_gui-2d-image-to-finite-element-meshes 
% https://www.mathworks.com/matlabcentral/fileexchange/179684-im2mesh_gui-2d-image-to-finite-element-meshes>
% 

%% ------------------------------------------------------------------------
%% Setup
% Before we start, please set folder "Im2mesh_Octave" as your current folder 
% of MATLAB.
clear all

% load packages of Octave
pkg load image
pkg load matgeom
pkg load geometry

% Function im2mesh use a mesh generator called MESH2D. We can use the following 
% command to add the folder 'mesh2d-master' to the path of MATLAB. 

addpath(genpath('mesh2d-master'))

%% ------------------------------------------------------------------------
%% Shape
% Let's start demo. Import image Shape.tif.

im = imread("Shape.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im );

%% ------------------------------------------------------------------------
%% Extract boundaries
% We use function im2Bounds to extract boundaries.

% image to polygon boundary
boundsRaw = im2Bounds( im );
% plot boundary using plotBounds
plotBounds(boundsRaw);

%% 
% We can use function totalNumVertex to get total number of vertices in boundsRaw.

totalNumVertex(boundsRaw)

%% ------------------------------------------------------------------------
%% Find control points
% We use function getCtrlPnts to find and label control points.

% label control points
tf_avoid_sharp_corner = false;
boundsCtrlP = getCtrlPnts( boundsRaw, tf_avoid_sharp_corner, size(im) );

plotBounds(boundsCtrlP, true);     % show starting and control points

%% 
% We can use function totalNumCtrlPnt to get total number of control points.

totalNumCtrlPnt(boundsCtrlP)

%% ------------------------------------------------------------------------
%% Smooth boundary
% We use function smoothBounds to smooth boundary.

lambda = 0.5;
mu = -0.5;
iters = 100;
threshold_num_turning = 0;
threshold_num_vert_Smo = 0;

boundsSmooth = smoothBounds( boundsCtrlP, lambda, mu, iters, ...
                threshold_num_turning, threshold_num_vert_Smo );

plotBounds(boundsSmooth);

%% ------------------------------------------------------------------------
%% Simplify boundary
% We use function simplifyBounds to simplify boundary. Other operation shown 
% here is used to clear up redundant vertices.

% simplify polygon boundary
tolerance = 0.5;
threshold_num_vert_Sim = 0;
boundsSimplified = simplifyBounds( boundsSmooth, tolerance, ...
                                        threshold_num_vert_Sim );
boundsSimplified = delZeroAreaPoly( boundsSimplified );

% clear up redundant vertices
% only control points and turning points will remain
boundsClear = getCtrlPnts( boundsSimplified, false );
boundsClear = simplifyBounds( boundsClear, 0 );

plotBounds(boundsClear);

%% 
% We can use function totalNumVertex to get total number of vertices in boundsClear.

totalNumVertex(boundsClear)

%% ------------------------------------------------------------------------
%% Generate mesh
% We can use function getPolyNodeEdge to get the nodes and edges of polygonal 
% boundary. Then, we can use function poly2mesh to generate mesh. Function poly2mesh 
% is using MESH2D as mesh generator.

grad_limit = 0.25;
hmax = 500;
mesh_kind = 'delaunay';

% get nodes and edges of polygonal boundary
[ poly_node, poly_edge ] = getPolyNodeEdge( boundsClear );

% generate triangular mesh
[ vert,tria,tnum ] = poly2mesh( poly_node, poly_edge, ...
                            hmax, mesh_kind, grad_limit );
% plot mesh using function plotMeshes
plotMeshes(vert,tria,tnum)

%% ------------------------------------------------------------------------
%%

% end of demo