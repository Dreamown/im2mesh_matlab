function [ vert, tria ] = delRedundantVertex( vert, tria )
% delRedundantVertex: delete redundant vertex in 'vert' and update 'tria'

    % Find all node indices that the mesh actually uses
    keep = unique(tria(:));     % column vector of used node IDs
    
    % Build a lookup table that maps old IDs -> new consecutive IDs
    map = zeros( size(vert,1), 1 );
    map(keep) = 1:numel(keep);  % assign new IDs only to kept nodes
    
    % Update
    vert = vert( keep, :);
    tria = map(tria);
end