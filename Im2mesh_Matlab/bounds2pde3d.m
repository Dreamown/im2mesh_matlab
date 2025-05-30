function model3d = bounds2pde3d( bounds, height )
% bounds2pde3d

    [ poly_node, poly_edge ] = getPolyNodeEdge( bounds );
    [ node, edge, part ] = regroup( poly_node, poly_edge );
    [vert,~,tria,tnum] = deltri1( node, edge, part );
    
    % Create matlab pde model object
    model_temp = createpde();  % qudratic model
    geometryFromMesh( model_temp, vert', tria', tnum' );
    
    g = model_temp.Geometry;
    extrude( g, height );
    
    generateMesh( model_temp, 'Hmax',500, 'Hmin', 1 );
    
    vert3d = model_temp.Mesh.Nodes';
    tria3d = model_temp.Mesh.Elements';
    
    
    tnum3 = zeros(size(tria3d,+1),+1);
    
    % tria midpoint
    tmid = vert3d(tria3d(:,1),:) ...
         + vert3d(tria3d(:,2),:) ...
         + vert3d(tria3d(:,3),:) ...
         + vert3d(tria3d(:,4),:) ;
    tmid = tmid / +4.0;
    
    % calc. "inside" status
    PSLG = edge;
    for ppos = 1: length(part)
       [stat] = inpoly2( tmid(:,1:2), node, PSLG(part{ppos},:) );
       tnum3(stat)  = ppos;
    end
    
    % keep "interior" tria's
    tria3d = tria3d(tnum3>+0,:);
    tnum3 = tnum3(tnum3>+0,:);
    
    % Create matlab pde model object
    model3d = createpde();
    
    geometryFromMesh( model3d, vert3d', tria3d', tnum3' );

    model3d.Mesh = [];
end