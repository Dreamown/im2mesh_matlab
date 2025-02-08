%% *demo10 of Im2mesh package*
% demo10 - Demonstrate different polyline smoothing technique
%%
%
%% ------------------------------------------------------------------------
%% Note
% I suggest familiarizing yourself with Im2mesh_GUI before learning Im2mesh
% package. With graphical user interface, Im2mesh_GUI will help you better understand
% the workflow and parameters of Im2mesh package.
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
imshow( im,'InitialMagnification','fit' );

%% ------------------------------------------------------------------------
%% Extract boundaries & find control points
% We use function getCtrlPnts to find and label control points.

% image to polygon boundary
boundsRaw = im2Bounds( im );

% label control points
tf_avoid_sharp_corner = false;
boundsCtrlP = getCtrlPnts( boundsRaw, tf_avoid_sharp_corner, size(im) );

plotBounds(boundsCtrlP, true);     % show starting and control points

%% ------------------------------------------------------------------------
%% Smooth boundary using Taubin method
% We use function smoothBounds to smooth boundary. Inside function smoothBounds,
% it's the Taubin smoothing method (<https://doi.org/10.1109/ICCV.1995.466848
% https://doi.org/10.1109/ICCV.1995.466848>).

lambda = 0.5;
mu = -0.5;
iters = 100;
threshold_num_turning = 4;
threshold_num_vert_Smo = 4;

boundsTaubin = smoothBounds( boundsCtrlP, lambda, mu, iters, ...
                threshold_num_turning, threshold_num_vert_Smo );

plotBounds(boundsTaubin);

%% ------------------------------------------------------------------------
%% Smooth boundary using CCMA method
% Let's try another smoothing method - Curvature Corrected Moving Average (CCMA)
% method (<https://github.com/UniBwTAS/ccma https://github.com/UniBwTAS/ccma>).
% Because Im2mesh package has a good and clear workflow, we can easily implement
% CCMA method via "smoothBoundsCCMA.m". Function smoothBoundsCCMA is just slightly
% different from function smoothBounds.
%
% Here is some info about the input of function smoothBoundsCCMA.

%%
%
%   new_bounds = smoothBoundsCCMA( bounds, w_ma, w_cc, threshold_num_turning, threshold_num_vert )
%   %   w_ma (float): Width parameter for the moving average.
%   %   w_cc (float): Width parameter for the curvature correction.
%   %   w_ma has major impact. Larger w_ma, smoother curve.
%   %   w_cc has little impact.
%
%%
% Let's try it.

w_ma = 30;
w_cc = 3;
threshold_num_turning = 4;
threshold_num_vert_Smo = 4;

boundsCCMA = smoothBoundsCCMA( boundsCtrlP, w_ma, w_cc, ...
                threshold_num_turning, threshold_num_vert_Smo );

plotBounds(boundsCCMA);

%% ------------------------------------------------------------------------
%% Plot together

plotBounds2( boundsTaubin, boundsCCMA );

%% ------------------------------------------------------------------------
%% Zoom in

plotBounds2( boundsTaubin, boundsCCMA );

xlim([32.6 58.5])
ylim([45.7 68.2])

%%
% Very good! It seems the result of CCMA method is quite similar to that of
% Taubin method for our data.

%% ------------------------------------------------------------------------

% end of demo
