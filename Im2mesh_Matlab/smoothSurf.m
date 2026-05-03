function V = smoothSurf( V, F, ntype, num_iters, lamda, mu)
% smoothSurf: smooth 3d triangular surface mesh
%
% Performs Taubin smoothing on a 3D surface mesh. This function applies
% volume-preserving smoothing by alternating shrinkage (lambda) and 
% expansion (mu) steps. It sequentially targets specific structural 
% features of the mesh: exterior triple lines, interior triple lines, 
% and boundaries, while constraining the vertices within their original 
% bounding box.
%
% usage:
%	V = smoothSurf( V, F, ntype, num_iters, lamda, mu);
%
% INPUTS:
%   V - N x 3 numeric array. The original vertex coordinates of the mesh.
%   F - M x 3 numeric array. The face connectivity matrix.
%   ntype - A K-by-1 numeric array labeling the topological type of each node:
%               2: Normal Vertex (touches 1 or 2 phases)
%               3: Triple Line (touches 3 phases)
%               4: Quadruple Point (touches 4 or more phases)
%              12: Normal Vertex on the outer boundary surface
%              13: Triple Line on the outer boundary surface
%              14: Quadruple Point on the outer boundary surface
%   num_iters - Integer. The number of Taubin smoothing iterations to perform.
%   lamda - Double. The shrinkage factor parameter (typically > 0).
%   mu - Double. The expansion factor parameter (typically < 0, where 
%        |mu| > lamda).
%
% OUTPUTS:
%   V - N x 3 numeric array. The resulting smoothed vertex coordinates.
%
% NOTE ON SUB-FUNCTIONS:
%   This function relies on `graph_smooth_taubin` (not defined in this scope) 
%   which takes the geometric constraints and specific feature tags 
%   ('ext_triple', 'int_triple', 'bound') to process the respective mesh subsets.
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    disp('//////////////// Taubin Smoothing ////////////////');
    
    % Start timer
    tic;
    
    % Geometric constraints
    % Determine the bounding box of the original mesh to prevent vertices
    % from smoothing outward past their initial absolute limits.
    minX = min(V(:,1)); maxX = max(V(:,1));
    minY = min(V(:,2)); maxY = max(V(:,2));
    minZ = min(V(:,3)); maxZ = max(V(:,3));
    
    % Create a logical/double mask indicating which vertices are strictly 
    % inside the bounding box (N x 3 matrix)
    geom = [double(V(:,1) > minX & V(:,1) < maxX), ...
            double(V(:,2) > minY & V(:,2) < maxY), ...
            double(V(:,3) > minZ & V(:,3) < maxZ)];

    % Smoothing passes
    % Apply Taubin smoothing sequentially to different structural lines
    fprintf('Smooth Exterior Triple Lines\n');
    V = graph_smooth_taubin(V, F, 'ext_triple', ntype, geom, lamda, mu, num_iters);
    
    fprintf('Smooth Interior Triple Lines\n');
    V = graph_smooth_taubin(V, F, 'int_triple', ntype, geom, lamda, mu, num_iters);
    
    fprintf('Smooth Boundaries\n');
    V = graph_smooth_taubin(V, F, 'bound', ntype, geom, lamda, mu, num_iters);
    
    % Stop timer
    smoothTime = toc;
    
    disp('//////////////// Smoothing Done! ////////////////');
    fprintf('//////////////// Time = %.2fs ////////////////\n', smoothTime);
end