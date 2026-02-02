%%
clear all; clc
%%
% import image sequences in a folder, e.g. a001.tif, a002.tif, ...
folder_name = 'test_image_sequences';
im = importImSeqs( folder_name );

%%
[vert,ele,tnum,vert2,ele2] = voxelMesh( im );
%%
plotMesh3d( vert,ele,tnum )
%%
plotMesh3d( vert2,ele2,tnum )

%%
plotVolFaces( im )

%%
color_code = 2;
opt = [];
opt.faceAlpha = 0.5;
opt.edgeAlpha = 0.3;

plotMesh3d( vert, ele, tnum, color_code, opt );

%%
tolerance = 1E-10;
markerSize = 10;
plane = 'all';
displayBCNode3d( vert, ele, tnum, tolerance, markerSize, plane );

%%
ele_type = 'C3D8';
precision = 8;
file_name = 'test_M1_Lall.inp';
printInp3d( vert, ele, tnum, ele_type, precision, file_name );

%%
ele_type = 'C3D20';
precision = 8;
file_name = 'test_M1_Qall.inp';
printInp3d( vert2, ele2, tnum, ele_type, precision, file_name );

%%
opt = [];
opt.select_phase = [1 3 4 6 8 9 10 15];
[vert,ele,tnum,vert2,ele2] = voxelMesh( im, opt );

%%
plotMesh3d( vert,ele,tnum, 1 )

%%
tolerance = 1E-10;
markerSize = 10;
plane = 'all';
displayBCNode3d( vert, ele, tnum, tolerance, markerSize, plane );

%%
ele_type = 'C3D8';
precision = 8;
file_name = 'test_M2_Lp.inp';
printInp3d( vert, ele, tnum, ele_type, precision, file_name );

%%
ele_type = 'C3D20';
precision = 8;
file_name = 'test_M2_Qp.inp';
printInp3d( vert2, ele2, tnum, ele_type, precision, file_name );

%%

%%
clear all; clc
%%
file_name = 'stacked_image.tif';
im = importImStack( file_name );



%%
clear all; clc
%%
file_name = 'test.tiff';
im = importImStack( file_name );

%%
im_seg = im;
thresh1 = 50;
thresh2 = 100;
thresh3 = 200;
im_seg( im<=thresh1 ) = 0;
im_seg( im>thresh1 & im<=thresh2 ) = 80;
im_seg( im>thresh2 & im<=thresh3 ) = 160;
im_seg( im>thresh3 ) = 255;

%%
resize_factor = 0.25;
im_resize = imresize3( im_seg, resize_factor, 'Method', 'nearest' );

%%
tic
[vert,ele,tnum,vert2, ele2] = voxelMesh( im_resize );
toc
% 18-19s

%%
ele_type = 'C3D8';
precision = 8;
file_name = 'test_M3_Lall.inp';
printInp3d( vert, ele, tnum, ele_type, precision, file_name );

%%
ele_type = 'C3D20';
precision = 8;
file_name = 'test_M3_Qall.inp';
printInp3d( vert2, ele2, tnum, ele_type, precision, file_name );

%%
opt = [];
opt.mode = 1;
opt.tf_gs = 0;
plotMesh3d( vert,ele,tnum, 0, opt )
%%
opt = [];
opt.mode = 1;
plotMesh3dG( vert,ele,tnum, 1 )

































