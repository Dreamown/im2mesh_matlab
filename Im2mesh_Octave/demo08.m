%% *demo08 of Im2mesh package*
% demo08 - Demonstrate parameter hmax for mesh generation
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
%% Transition
% Let's start demo. Import image Transition.tif.

im = imread("Transition.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im );

%% 
% Generate mesh.

opt = [];       % reset opt
opt.threshold_num_turning = 0;
opt.threshold_num_vert_Smo = 0;
opt.threshold_num_vert_Sim = 0;
opt.hmax = 8;

[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum )

%% 
% We can see that the max mesh size is limited by the parameter hmax.

%% ------------------------------------------------------------------------
%% hmax
% Let's use a much larger hmax to see how things are changing.

opt = [];       % reset opt
opt.threshold_num_turning = 0;
opt.threshold_num_vert_Smo = 0;
opt.threshold_num_vert_Sim = 0;
opt.hmax = 500;

[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum )

%% 
% Now, the max mesh size is much larger. Note that hmax is a upper bound for 
% the max mesh size. There exists boundary edge contraints and gradient-limt, 
% so the max mesh size in the generated mesh can not reach hmax.
% 
%% ------------------------------------------------------------------------


% end of demo