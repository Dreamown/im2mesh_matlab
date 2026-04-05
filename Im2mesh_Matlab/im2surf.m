function [V, F, ntype, flabel] = im2surf(im, voxelSpacing)
% im2surf: 3d voxel image to 3d triangular surface mesh
%
% Inputs:
%   im - 3D numeric array representing the voxel volume. Different integer values
%        represent different phases or materials.
%
%   voxelSpacing - 1x3 numeric array specifying the physical dimension of a single voxel 
%                  in the [x, y, z] directions (e.g., [1, 1, 1]).
%
% Outputs:
%   V - A K-by-3 numeric array of all unique global node coordinates.
%
%   F - An L-by-3 numeric array of global triangle connectivities 
%       referencing the row indices of V.
%
%   ntype - A K-by-1 numeric array labeling the topological type of each node:
%               2: Normal Vertex (touches 1 or 2 phases)
%               3: Triple Line (touches 3 phases)
%               4: Quadruple Point (touches 4 or more phases)
%              12: Normal Vertex on the outer boundary surface
%              13: Triple Line on the outer boundary surface
%              14: Quadruple Point on the outer boundary surface
%
%   flabel - An L-by-2 numeric array where each row contains the phaseIDs 
%            of the two phases sharing the corresponding triangle in 
%            F. If the face is on an outer boundary 
%            (unshared), the second column will be -1.
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % Extract triangular surface mesh
    [nodes, triangles, phaseIDs] = extractPhaseMesh(im, voxelSpacing);
    
    % Convert surface mesh to the output format of Dream.3D
    [V, F, ntype, flabel] = convert2dream3d(nodes, triangles, phaseIDs);
end