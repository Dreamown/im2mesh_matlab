%% 
clearvars
set(groot, 'DefaultFigurePosition', [560 420 560 420])

%%

% create polyshape
vert1 = [ 0 0; 15 0; 15 10; 0 10 ];
ps1 = polyshape(vert1);

vert2 = [15 0] + [ 0 0; 10 0; 10 10; 0 10 ];
ps2 = polyshape(vert2);

vert3 = [15 10] + [ 0 0; 10 0; 10 15; 0 15 ];
ps3 = polyshape(vert3);

ps13 = union( ps1, ps3 );
psCell = { ps13; ps2 };

% bounds is a nested cell array of polygonal boundary
bounds = polyshape2bound(psCell);

[ poly_node, poly_edge ] = getPolyNodeEdge( bounds );

hmax = 3; 
mesh_kind = 'delaunay'; % method used to create mesh size function
grad_limit = 0.25;
[ vert,tria,tnum ] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit );
plotMeshes(vert,tria,tnum);

%% 
clearvars
set(groot, 'DefaultFigurePosition', [560 420 560 420])

%%
% create polyshape
vert1 = [ 0 0; 15 0; 15 10; 0 10 ];
ps1 = polyshape(vert1);
vert2 = [15 0] + [ 0 0; 10 0; 10 10; 0 10 ];
ps2 = polyshape(vert2);
vert3 = [15 10] + [ 0 0; 10 0; 10 15; 0 15 ];
ps3 = polyshape(vert3);

ps13 = union( ps1, ps3 );
psCell = { ps13; ps2 };

% bounds is a nested cell array of polygonal boundary
bounds = polyshape2bound(psCell);

tol_intersect = 1e-6;   % distance tolerance for intersect
bounds = addIntersectPnts( bounds, tol_intersect );

poly = bounds{1}{2};
polyline = poly(2:4,:);

iters = 5;
polyline = insertMidPnt( polyline, iters );

tol_dist = 1e-2;    % distance tolerance
newB = addPnt2Bound( polyline, bounds, tol_dist );

[ poly_node, poly_edge ] = getPolyNodeEdge( newB );

hmax = 3; 
mesh_kind = 'delaunay'; % method used to create mesh size function
grad_limit = 0.25;
[ vert,tria,tnum ] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit );

plotMeshes(vert,tria,tnum);

%%
edge = poly(3:4,:);

iters = 6;
ratio = 0.5;
edge = insertBiasedSeed( edge, iters, ratio );

iters = 1;
edge = insertMidPnt( edge, iters );

tol_dist = 1e-2;    % distance tolerance
newB = addPnt2Bound( edge, bounds, tol_dist );


[ poly_node, poly_edge ] = getPolyNodeEdge( newB );

hmax = 3; 
mesh_kind = 'delaunay'; % method used to create mesh size function
grad_limit = 0.25;
[ vert,tria,tnum ] = poly2mesh( poly_node, poly_edge, hmax, mesh_kind, grad_limit );

plotMeshes(vert,tria,tnum);





















