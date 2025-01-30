%% *demo09 of Im2mesh package*
% demo09 - Demonstrate how to select phases for meshing
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
%% Phases
% Let's start demo. Import image Phases.tif.

im = imread("Phases.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im );

%% 
% Show the grayscale levels in the image.

intensity = unique( im ); 
intensity'

%% 
% There're 7phases. Let's generate mesh using the default setting.

[ vert, tria, tnum ] = im2mesh( im );
plotMeshes( vert, tria, tnum )

%% ------------------------------------------------------------------------
%% Select phases for meshing
% However, we don't need some of the phases in the image. Those phases may be 
% air voids or background. We don't want them to show up in the finite element 
% meshes.
% 
% Function im2mesh support phase selection for meshing. We need to assign a 
% index vector to opt.select_phase. I'll show you how to do that. 
% 
% We knew that the image has the following grayscales.

intensity'

%% 
% For example, we are interested in the grayscale: 40, 80, 120, 200, 240. We 
% don't want grayscle of 0 and 160. Let's use the following operation to obtain 
% the index vector for opt.select_phase.

grayscale_we_like = [ 40, 80, 120, 200, 240 ]';
ind_vec = find( ismember(intensity, grayscale_we_like) );

% ind_vec is the index vector we need
ind_vec'

%% 
% Let's generate mesh.

opt = [];                       % reset opt
opt.select_phase = ind_vec;     % assign index vector to opt.select_phase
[ vert, tria, tnum ] = im2mesh( im, opt );
plotMeshes( vert, tria, tnum )

%% ------------------------------------------------------------------------

% end of demo