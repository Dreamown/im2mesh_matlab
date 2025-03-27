%% 
clearvars
set(groot, 'DefaultFigurePosition', [560 420 560 420])

%% 
im_o = imread('Circle2.tif');
if size(im_o,3) == 3;  im_o = rgb2gray( im_o ); end

% image segmentation
num_level = 2;
thresh = multithresh( im_o, num_level-1 );
seg_im = imquantize( im_o, thresh );
im = uint8( mat2gray(seg_im)*255 );

imshow( im,'InitialMagnification','fit' );


%% 
opt = [];   % reset opt
opt.tolerance = 0.1;
opt.tf_mesh = false;
bounds = im2mesh( im, opt );

psCell = bound2polyshape(bounds);
[xmin,xmax,ymin,ymax] = xyRange( psCell );

% mid point of the upper boundary
xMidUp = (xmin+xmax)/2;
yMidUp = ymax;

% mid point of the right boundary
xMidRight = xmax;
yMidRight = (ymin+ymax)/2;

%%

psParticle = psCell{2};
thickness = 2.5;  % unit: pixel
psITZ = polybuffer( psParticle, thickness );

psITZ = subtract( psITZ, psParticle );

for i = 1: length(psCell)
    psCell{i} = subtract( psCell{i}, psITZ );
end

% add to the end of psCell
psCell{end+1} = psITZ;

%%
boundsNew = polyshape2bound(psCell);
tol_intersect = 1e-6;   % distance tolerance for intersect
boundsNew = addIntersectPnts( boundsNew, tol_intersect );

boundsNewCtrlP = getCtrlPnts( boundsNew, false );

% simplify
tolerance = 0.06;  % for Douglas-Peucker polyline simplification
boundsNewSimplified = simplifyBounds( boundsNewCtrlP, tolerance, 0 );

%%
psCell = bound2polyshape(boundsNewSimplified);

%%

% figure
% hold on; axis equal;
% for i = 1: length(psCell)
%     plot(psCell{i});
% end
% hold off

%%

t = 0.05:0.03:2*pi;
x1 = xMidUp + 6*cos(t);
y1 = yMidUp + 45*sin(t);
psNotch = polyshape(x1,y1);

for i = 1: length(psCell)
    psCell{i} = subtract( psCell{i}, psNotch );
end

%%
% figure
% hold on; axis equal;
% for i = 1: length(psCell)
%     plot(psCell{i});
% end
% hold off

%%
boundsNew = polyshape2bound(psCell);
tol_intersect = 1e-6;   % distance tolerance for intersect
boundsNew = addIntersectPnts( boundsNew, tol_intersect );

boundsNewCtrlP = getCtrlPnts( boundsNew, false );

% simplify
tolerance = 0.01;  % for Douglas-Peucker polyline simplification
boundsNewSimplified = simplifyBounds( boundsNewCtrlP, tolerance, 0 );

%%
% show all vertices
plotBounds( boundsNewSimplified, true, 'ko-' );  

%%

[ poly_node, poly_edge ] = getPolyNodeEdge( boundsNewSimplified );

hmax = 500; 
mesh_kind = 'delaunay';
grad_limit = 0.2;
[ vert,tria,tnum,vert2,tria2 ] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit );

plotMeshes(vert,tria,tnum);




















