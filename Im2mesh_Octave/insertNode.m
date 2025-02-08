function [vertU, triaU] = insertNode(vert, tria)
% insertNode: inserts midpoints into all triangle edges to form 6-node elements.
%
%   [vertU, triaU] = insertNode(vert, tria)
%
% input:
%   vert : (N x 2) array of node coordinates
%          vert(i,:) = (x, y) for the i-th node
%
%   tria : (M x 3) array of triangles
%          tria(k,:) = [i1, i2, i3] (1-based indices of the triangle's nodes)
%
% output:
%   vertU : (N + E) x 2 array of updated node coordinates
%           (original nodes + newly inserted midpoints)
%
%   triaU : (M x 6) array of "quadratic" triangle connectivity
%           triaU(k,:) = [i1, i2, i3, i4, i5, i6],
%           where the last 3 entries are the midpoint node indices on edges
%

    % Number of original vertices (nV) and triangles (nT)
    nV = size(vert,1);
    nT = size(tria,1);

    % -------------------------------------------------------------
    % 1) "tria_app" for edges (1->2, 2->3, 3->1), as in the original
    % -------------------------------------------------------------
    tria_app = [tria, tria(:,1)];  % nT-by-4

    % -------------------------------------------------------------
    % 2) Generate all midpoints in the exact j,k order 
    %    (triangle-by-triangle, edges: (1->2),(2->3),(3->1))
    % -------------------------------------------------------------
    i1 = reshape(tria_app(:,1:3).', [], 1);  % each triangle's corner1->corner2->corner3
    i2 = reshape(tria_app(:,2:4).', [], 1);  % to get their matched next corner

    % Midpoint coordinates, in the same order the original loop would append them
    newCoords = 0.5 * (vert(i1,:) + vert(i2,:));  % (3*nT)-by-2

    % -------------------------------------------------------------
    % 3) Combine old vertices + newly created midpoints
    % -------------------------------------------------------------
    V2 = [vert; newCoords];  % (nV + 3*nT)-by-2

    % -------------------------------------------------------------
    % 4) Remove duplicates in a stable way (first occurrence is kept,
    %    in the order they appear). This replicates
    %    unique(...,'stable','rows') in older Octave.
    % -------------------------------------------------------------
    [vertU, ~, ic] = stable_unique_rows(V2);

    % -------------------------------------------------------------
    % 5) Build final 6-node connectivity "triaU"
    %
    %    - The first 3 columns are the mapped indices of the original corners,
    %      i.e. ic(tria).
    %    - The next 3 columns are the newly inserted midpoints,
    %      i.e. ic(nV+1 : nV+3*nT), one for each edge, reshaped per triangle.
    % -------------------------------------------------------------
    cornerMapped = ic(tria);  % each corner i => ic(i)
    midMapped    = reshape(ic(nV+1:end), 3, nT).';  % each triangle gets 3 midpoints

    triaU = [cornerMapped, midMapped];

end

%--------------------------------------------------------------------------
% Subfunction: stable_unique_rows
%
% This mimics "unique(A,'rows','stable')" in older Octave versions 
% (and in MATLAB) by preserving the first occurrence of each row 
% in the order they appear.
%--------------------------------------------------------------------------
function [C, ia, ic] = stable_unique_rows(A)
    % 1) unique(...,'rows','first') picks out the *first* occurrence index
    %    for each unique row, but sorts them in ascending row order.
    [~, firstIdx] = unique(A, 'rows', 'first');

    % 2) Sort 'firstIdx' so they appear in the order rows occur in A 
    %    (this replicates the 'stable' behavior).
    firstIdxSorted = sort(firstIdx);

    % 3) The stable unique rows are:
    C = A(firstIdxSorted, :);

    % 4) For each row in A, find its index in C:
    [~, ic] = ismember(A, C, 'rows');

    % 5) ia is the list of row indices of A that map to each row of C.
    %    That’s just firstIdxSorted. (We don’t actually use ia in the main code.)
    ia = firstIdxSorted;
end
