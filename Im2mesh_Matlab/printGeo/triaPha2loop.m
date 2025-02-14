function surfaceLoops = triaPha2loop(triaP, vert, edge)
% triaPha2loop triangular mesh of one phase to surface loops cell
%
    
    % label isolated mesh regions
    labels = findIsolatedMeshRegions( vert, triaP) ;
    num_region = length( unique(labels) );
    
    surfaceLoops = cell( 1, num_region );
    
    for i = 1: num_region
        triaIso = triaP( labels == i, : );
        % convert isolate triangular mesh to boundary loops 
        % of a surface region
        surfaceLoops{i} = triaIso2loop( triaIso, vert, edge );
    end
end