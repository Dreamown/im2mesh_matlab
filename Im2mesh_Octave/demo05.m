%% *demo05 of Im2mesh package*
% demo05 - Demonstrate parameter tf_avoid_sharp_corner
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
%% Circle
% Let's start demo. Import image Circle.tif.

im = imread("Circle.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im );

%% 
% Generate mesh.

opt = [];       % reset opt
opt.tf_avoid_sharp_corner = false;
opt.threshold_num_turning = 10;
opt.threshold_num_vert_Smo = 20;
opt.threshold_num_vert_Sim = 20;

[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum )

%% 
% You can see the mesh is very dense in some region. That is induced by the 
% sharp corner between polygonal boundaries. Let's zoom in to confirm that.

plotMeshes( vert, tria, tnum )

xlim([53.4 65.8])
ylim([30.8 42.9])

%% ------------------------------------------------------------------------
%% Avoid sharp corner
% We can set parameter tf_avoid_sharp_corner to true. It may help.

opt = [];       % reset opt
opt.tf_avoid_sharp_corner = true;
opt.threshold_num_turning = 10;
opt.threshold_num_vert_Smo = 20;
opt.threshold_num_vert_Sim = 20;

[ vert, tria, tnum ] = im2mesh( im, opt );

plotMeshes( vert, tria, tnum )

%% 
% Zoom in

plotMeshes( vert, tria, tnum )

xlim([53.4 65.8])
ylim([30.8 42.9])

%% 
% Yes, it helps.
%% ------------------------------------------------------------------------

% end of demo