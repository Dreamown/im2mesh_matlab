%%
im = imread("im.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im,'InitialMagnification','fit' );

%%
[vert,quad,tnum] = pixelMesh( im );
plotMeshes( vert, quad, tnum );

%%
% parameters
dx = 1; dy = 1;
ele_type = 'CPS4'; 
precision_nodecoor = 8; 

% export as inp file or bdf file
% scale nodecoor_list using dx, dy
nodecoor_list( :, 2 ) = nodecoor_list( :, 2 ) * dx;
nodecoor_list( :, 3 ) = nodecoor_list( :, 3 ) * dy;

%%
[ nodecoor_list, ~, ele_cell ] = getNodeEle( vert, quad, tnum );

%%
% generate inp file
% export multi-phases in image as multi-sections in inp file
printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision_nodecoor );

% generate bdf file
printBdf( nodecoor_list, ele_cell, precision_nodecoor );













