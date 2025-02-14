% vert = [0 0; 1 0; 1 1; 0 1; 2 0; 3 0; 3 1; 2 1];
% tria = [1 2 4; 2 3 4; 5 6 8; 6 7 8];
% tnum = 1+zeros(size(tria,1),1);
%%
% ---------------------------------------------------------------------
% Use function regroup to organize cell array poly_node, poly_edge into
% array node, edge.
[ node, edge, part ] = regroup( poly_node, poly_edge );

% Note:
% node, edge - array. Nodes and edges of all polygonal boundary
% node, edge doesn't record phase info.
% node - V-by-2 array. x,y coordinates of vertices. 
%        Each row is one vertex.
% edge - E-by-2 array. Node numbering of two connecting vertices of
%        edges. Each row is one edge.
% part - cell array. Used to record phase info.
%          part{i} is edge indexes of the i-th phase, indicating which 
%          edges make up the boundary of the i-th phase.

% ---------------------------------------------------------------------
% Delaunay triangulation in 2D using subfunction deltri1
[vert,~,tria,tnum] = deltri1( vert, edge, node, edge, part );

%%
clearvars

%%
load('input1.mat')

%% vert,tria,tnum)
plotMeshes(vert,tria,tnum);

%%
num_phase = length( unique(tnum) );
phaseLoops = cell( 1, num_phase );

for i = 1: num_phase
    triaP = tria( tnum==i, : );
    % triangular mesh of one phase to surface loop cell
    phaseLoops{i} = triaPha2loop(triaP, vert, edge);
end

%%
plotLoopsEdgesInd( phaseLoops{1}{1}, edge, vert );

%%
% rename variables to consistent with gmsh
point = vert;
line = edge;
C = phaseLoops;

opt.sizeMin = 0.5;
opt.sizeMax = 30;
opt.algthm = 8;
opt.recombAll = 1;
opt.recombAlgthm = 3;
opt.eleOrder = 1;

path_to_geo = 'gmshTemp.geo';

printGeo( C, point, line, opt, geoFileName );


%%
load("test_gmsh3.mat")

%%
path_to_m = 'gmshTemp.m';
% path_to_geo = [ pwd filesep geoFileName ];
%%
str=sprintf('"%s" "%s" -o "%s" -v %i -save', ... 
			path_to_gmsh, path_to_geo, path_to_m, v );
system(str);

%%
run( path_to_m )
%%
tnum = msh.TRIANGLES(:,end);
tria = msh.TRIANGLES(:,1:3);
vert = msh.POS;
plotMeshes( vert, tria, tnum );

%%
tnum = msh.QUADS(:,end);
tria = msh.QUADS(:,1:4);
vert = msh.POS;
plotMeshes( vert, tria, tnum );

%%
EToV = tria;
VX = vert(:,1);
VY = vert(:,2);
[q,theta] = MeshQualityQuads(EToV,VX,VY);
mean(q)



































