%%
clear all
clc

%%
addpath(genpath('mesh2d-master'))

%%
% create polyshape
vert1 = [ 0 0; 15 0; 15 10; 0 10 ];
ps1 = polyshape(vert1);
vert2 = [15 0] + [ 0 0; 10 0; 10 10; 0 10 ];
ps2 = polyshape(vert2);
vert3 = [15 10] + [ 0 0; 10 0; 10 25; 0 25 ];
ps3 = polyshape(vert3);
ps13 = union( ps1, ps3 );
psCell = { ps2; ps13 };

% % plot psCell
% figure
% hold on; axis equal;
% for i = 1: length(psCell)
%     plot(psCell{i});
% end
% hold off

% bounds is a nested cell array of polygonal boundary
bounds = polyshape2bound(psCell);

%%
targetSpace = 3;
bounds = refineOuterBoundary( bounds, targetSpace );

plotBounds(bounds,false,'ko-')



















