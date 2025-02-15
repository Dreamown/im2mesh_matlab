function boundaryEdges = findBoundaryEdges(Tsub)
%FINDBOUNDARYEDGES  Identify boundary edges of a sub-mesh.
%
%  INPUT:
%     Tsub  : (nTri x 3) array of triangle vertex indices
%             describing one connected sub-mesh.
%  OUTPUT:
%     boundaryEdges : (nBdryEdges x 2) array of vertex indices
%                     for edges on the boundary.
%                     Each row is [v1, v2] with v1 < v2.
%
%  NOTE:
%  - If your sub-mesh is a subset of a larger mesh, ensure Tsub uses
%    the same vertex indices as the original mesh. Coordinates are
%    not needed in order to find boundary edges.

    nTri = size(Tsub, 1);
    
    % Pre-allocate space for all edges: each triangle has 3 edges
    allEdges = zeros(3*nTri, 2);
    
    % Fill array of edges
    idx = 1;
    for i = 1:nTri
        v = Tsub(i,:);
        % Triangular face => edges: (v1,v2), (v2,v3), (v3,v1)
        triEdges = [v(1),v(2);
                    v(2),v(3);
                    v(3),v(1)];
        
        % Sort each edge so edge = [min, max]
        triEdges = sort(triEdges, 2);
        
        % Store
        allEdges(idx:idx+2, :) = triEdges;
        idx = idx + 3;
    end
    
    % Find unique edges and count occurrences
    [uniqueEdges, ~, ic] = unique(allEdges, 'rows', 'stable');
    counts = accumarray(ic, 1);
    
    % Boundary edges are those that appear exactly once
    isBoundary = (counts == 1);
    boundaryEdges = uniqueEdges(isBoundary, :);
end
