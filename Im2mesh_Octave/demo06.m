%% *demo06 of Im2mesh package*
% demo06 - Demonstrate thresholds in polyline smoothing
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

%% ------------------------------------------------------------------------
%% Extract boundaries and find control points

% image to polygon boundary
boundsRaw = im2Bounds( im );

% label control points
tf_avoid_sharp_corner = false;
boundsCtrlP = getCtrlPnts( boundsRaw, tf_avoid_sharp_corner, size(im) );

plotBounds(boundsCtrlP);    

%% ------------------------------------------------------------------------
%% Smooth boundary
% Set thresholds to zero.

lambda = 0.7;
mu = -0.4;
iters = 10;
threshold_num_turning = 0;
threshold_num_vert_Smo = 0;

boundsSmooth = smoothBounds( boundsCtrlP, lambda, mu, iters, ...
                threshold_num_turning, threshold_num_vert_Smo );

plotBounds(boundsSmooth);

%% 
% It seems that some boundaries are over-smoothed. Let's zoom in to check that.

plotBounds(boundsSmooth);

xlim([34.5 55.5])
ylim([44.2 64.8])

%% ------------------------------------------------------------------------
%% Compare
% We can compare boundsSmooth with boundsRaw.

figure;
title('Red - Smoothed. Blue - Pristine')
hold on
axis image off;

b = boundsRaw;
for i = 1: length(b)
	for j = 1: length(b{i})
		poly = b{i}{j};
		plot( poly(:,1), poly(:,2), 'b' );
	end
end

b = boundsSmooth;
for i = 1: length(b)
	for j = 1: length(b{i})
		poly = b{i}{j};
		plot( poly(:,1), poly(:,2), 'r' );
	end
end

hold off

%% 
% Let's zoom in.

figure;
title('Red - Smoothed. Blue - Pristine')
hold on
axis image off;

b = boundsRaw;
for i = 1: length(b)
	for j = 1: length(b{i})
		poly = b{i}{j};
		plot( poly(:,1), poly(:,2), 'b' );
	end
end

b = boundsSmooth;
for i = 1: length(b)
	for j = 1: length(b{i})
		poly = b{i}{j};
		plot( poly(:,1), poly(:,2), 'r' );
	end
end

hold off

xlim([34.5 55.5])
ylim([44.2 64.8])

%% 
% We can see that boundsSmooth lost the details of the pristine boundaries. 
% Some of the smoothed polygons have zero area. This is not what we want.

%% ------------------------------------------------------------------------
%% Set threshold
% Now, we set thresholds.

lambda = 0.7;
mu = -0.4;
iters = 10;
threshold_num_turning = 10;
threshold_num_vert_Smo = 20;

boundsSmooth = smoothBounds( boundsCtrlP, lambda, mu, iters, ...
                threshold_num_turning, threshold_num_vert_Smo );

plotBounds(boundsSmooth);

%% 
% Zoom in.

plotBounds(boundsSmooth);

xlim([34.5 55.5])
ylim([44.2 64.8])

%% 
% It seems new boundaries are better. We can compare with the pristine boundaries.

figure;
title('Red - Smoothed. Blue - Pristine')
hold on
axis image off;

b = boundsRaw;
for i = 1: length(b)
	for j = 1: length(b{i})
		poly = b{i}{j};
		plot( poly(:,1), poly(:,2), 'b' );
	end
end

b = boundsSmooth;
for i = 1: length(b)
	for j = 1: length(b{i})
		poly = b{i}{j};
		plot( poly(:,1), poly(:,2), 'r' );
	end
end

hold off

xlim([34.5 55.5])
ylim([44.2 64.8])

%% 
% Very good.
%% ------------------------------------------------------------------------

% end of demo