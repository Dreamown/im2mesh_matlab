%%
clearvars
im = imread("kumamon.tif");
if size(im,3) == 3;  im = rgb2gray( im ); end
imshow( im,'InitialMagnification','fit' );

%%
opt.select_phase = [1 3];
[ vert, ele, tnum, vert2, ele2 ] = pixelMesh( im, opt );
plotMeshes( vert, ele, tnum );

%%






%% msh
%%
%%
precision_nodecoor = 8;
path_file_name = 'test_linear.msh';
printMsh( vert, ele, tnum, [], precision_nodecoor, path_file_name );

%%




%% inp
%%
clc

%%
precision_nodecoor = 5;
path_file_name = '2025.inp';
ele_type = 'CPS3';

%%
printInp2d( vert, ele );
%%
printInp2d( vert, ele, [], [], [], path_file_name );
%%
printInp2d( vert, ele, tnum );
%%
printInp2d( vert, ele, tnum, [], precision_nodecoor );
%%
printInp2d( vert, ele, tnum, ele_type, precision_nodecoor );
%%
printInp2d( vert, ele, tnum, ele_type, precision_nodecoor, path_file_name );
%%
%% linear

precision_nodecoor = 8;
path_file_name = 'test_linear.inp';
ele_type = 'CPS4';

printInp2d( vert, ele, tnum, ele_type, precision_nodecoor, path_file_name );

%%
%% quadratic

precision_nodecoor = 8;
path_file_name = 'test_quad.inp';
ele_type = 'CPS8';

printInp2d( vert2, ele2, tnum, ele_type, precision_nodecoor, path_file_name );

%%



%%
%% bdf
%%
precision_nodecoor = 5;
path_file_name = '2025.bdf';

%%
printBdf2d( vert, ele );
%%
printBdf2d( vert, ele, [], [], [], path_file_name );
%%
printBdf2d( vert, ele, tnum );
%%
printBdf2d( vert, ele, tnum, [], precision_nodecoor );
%%
printBdf2d( vert, ele, tnum, [], precision_nodecoor, path_file_name );

%%
precision_nodecoor = 8;
path_file_name = 'test_quadrang.bdf';

printBdf2d( vert, ele, tnum, [], precision_nodecoor, path_file_name );







































