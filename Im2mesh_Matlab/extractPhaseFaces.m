function phaseFaces = extractPhaseFaces(F, flabel)
% extractPhaseFaces: Extracts surface mesh faces for each individual phase.
% 
% This function identifies unique phases from the provided face labels
% (ignoring the background label, denoted as -1) and groups the mesh faces 
% into a cell array. Each cell will contain the corresponding faces that 
% belong to a specific individual phase.
%
% usage:
%	phaseFaces = extractPhaseFaces(F, flabel);
%
% Inputs:
%   F      - An N x M numeric matrix representing the surface mesh faces. 
%            N is the total number of faces, and M is the number of vertices 
%            per face (e.g., 3 for triangular meshes).
%   flabel - An N x 2 numeric matrix containing the phase labels associated 
%            with each face. The columns typically denote the phase IDs on 
%            either side of the given face.
%
% Outputs:
%   phaseFaces - A C x 1 cell array, where C is the number of unique valid 
%                phases (excluding the background phase -1). Each cell 
%                contains the subset of faces from 'F' that are associated 
%                with that specific phase ID.
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    phase_ids = unique(flabel);
    phase_ids(phase_ids == -1) = []; % Remove background label

    % Store faces in a cell array for dynamic handling
    phaseFaces = cell(length(phase_ids), 1);
    for i = 1:length(phase_ids)
        pi = phase_ids(i);
        i1 = find(pi == flabel(:,1));
        i2 = find(pi == flabel(:,2));
        phaseFaces{i} = F([i1; i2], :);
    end
end