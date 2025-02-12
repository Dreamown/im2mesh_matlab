%%
clearvars
%%
im = imread("im.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im,'InitialMagnification','fit' );

%%
[vert,quad,tnum] = pixelMesh( im );
plotMeshes( vert, quad, tnum );

%% 
opt.select_phase = [1 3];
[vert,quad,tnum] = pixelMesh( im, opt );
plotMeshes( vert, quad, tnum );

%%
% parameters
dx = 1; dy = 1;
ele_type = 'CPS4'; 
precision_nodecoor = 8; 

% scale node coordinates
vert( :, 1 ) = vert( :, 1 ) * dx;
vert( :, 2 ) = vert( :, 2 ) * dy;

%% export as inp file or bdf file
[ nodecoor_list, ~, ele_cell ] = getNodeEle( vert, quad, tnum );

%%
% generate inp file
% export multi-phases in image as multi-sections in inp file
printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision_nodecoor );

%%
% generate bdf file
printBdf( nodecoor_list, ele_cell, precision_nodecoor );













