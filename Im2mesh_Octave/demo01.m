%% *demo01 of Im2mesh package*
% demo01 - Demonstrate function im2mesh, which use MESH2D as mesh generator.
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
%% Kumamon
% Let's start demo01. We'll demostate the usage of function im2mesh.
%
% Import image kumamon.tif.

im = imread("kumamon.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im );

%%
% Show the grayscale levels in the image

intensity = unique( im );
intensity

%%
% Let's use function im2mesh to generate meshes based on the kumamon image.
% We will use default settings. Note that function im2mesh has incorporated the
% workflow that you saw in im2mesh_GUI: extract polygonal boundaries from image,
% search & label control points, smooth boundary, simplify boundary, select phase,
% and generate mesh.

[ vert, tria, tnum ] = im2mesh( im );
% plot mesh using function plotMeshes
plotMeshes( vert, tria, tnum )

%% ------------------------------------------------------------------------
%% Mesh quality
% We can use function tricost check the mesh quality.

tricost( vert, tria, tnum )

%%
% We can get the mean value of Q.

mean(triscr2( vert, tria ))

%%
% Wonderful! Let's check the total number of triangles in the mesh.

size( tria, 1 )

%%
% That's a lot of triangles.

%% ------------------------------------------------------------------------
%% Change parameter
% We can change the parameters of function im2mesh to see whether it help to
% reduce the number of triangles.

opt = [];               % initialize. opt is a structure array.
opt.tolerance = 1;      % default value for opt.tolerance is 0.3

[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum )

% Now, the number of triangles decreased to 785. That's great.

%% ------------------------------------------------------------------------
%% Parameters of function im2mesh
% As I showed before, there're two ways to call function im2mesh.
%
%   [ vert, tria, tnum ] = im2mesh( im );   % this use default opt setting
%   [ vert, tria, tnum ] = im2mesh( im, opt );
%
% Variable opt means options. It's a structure array used to stored input
% parameters for function. We can take a look at the default value of opt.
%%
%   % opt is a structure array for parameters
%     opt.tf_avoid_sharp_corner = false;
%     opt.lambda = 0.5;
%     opt.mu = -0.5;
%     opt.iters = 100;
%     opt.threshold_num_turning = 10;
%     opt.threshold_num_vert_Smo = 10;
%     opt.tolerance = 0.3;
%     opt.threshold_num_vert_Sim = 10;
%     opt.grad_limit = 0.25;
%     opt.hmax = 500;
%     opt.mesh_kind = 'delaunay';
%     opt.select_phase = [];
%
%%
% The meaning of these parameters are listed the file "Im2mesh functions and parameters.pdf".
% Please refer to "Im2mesh_GUI Tutorial.pdf" about how to choose the value of
% these parameters. You can change these default values by editting function setOption
% in "im2mesh.m".

%% ------------------------------------------------------------------------
%% Example 1
% Let's show some examples with different opt.

% example 1
opt = [];               % reset opt
opt.tolerance = 2;
[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum );

%% ------------------------------------------------------------------------
%% Example 2

% example 2
opt = [];                       % reset opt
opt.tolerance = 1;
opt.select_phase = [1 2 4];     % select phase for meshing
[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum );

%% ------------------------------------------------------------------------
%%

% end of demo
