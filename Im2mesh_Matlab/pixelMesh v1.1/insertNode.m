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
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % Number of original vertices and elements
    nV = size(vert,1);
    nT = size(tria,1);

    % 1) "tria_app" for the edges (1->2, 2->3, 3->1), same as original
    tria_app = [tria, tria(:,1)];

    % Vectorize this by listing the edges in exactly that order:
    i1 = reshape(tria_app(:,1:4)', [], 1); 
    i2 = reshape(tria_app(:,2:5)', [], 1);  

    % Compute all midpoints in a single shot (still in the same order)
    newCoords = 0.5* (vert(i1, :) + vert(i2, :)); 

    % 3) Combine the original vertices + newly created midpoints
    V2 = [vert; newCoords]; 

    % 4) Remove duplicates with "stable" to replicate original order
    [vertU, ~, ic] = unique(V2, 'stable', 'rows');

    % 5) Construct the final 6-node connectivity "triaU"
    % Vector-map the original corners:
    cornerMapped = ic(tria);  % each corner i => ic(i)

    % Vector-map the midpoints:
    midMapped = reshape(ic(nV+1:end), 4, nT).';

    % Combine corners + midpoints
    triaU = [cornerMapped, midMapped];
end
