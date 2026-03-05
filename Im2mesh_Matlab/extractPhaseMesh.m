function [allNodes, allTriangles, phaseIDs] = extractPhaseMesh(voxelData, voxelSpacing)
% extractPhaseMesh: separate phases and generate exact voxel mesh (triangle)
% Project website: https://github.com/mjx888/im2mesh
%
    
    phaseIDs = unique(voxelData(:));
    numPhases = length(phaseIDs);
    
    allNodes = cell(numPhases, 1);
    allTriangles = cell(numPhases, 1);
    
    for i = 1:numPhases
        currentPhaseID = phaseIDs(i);
        currentBW = (voxelData == currentPhaseID);
        
        % Get the exact blocky mesh for this specific phase
        [nodes, triangles] = voxelToExactMesh(currentBW, voxelSpacing);
        
        % Store them for combining later
        allNodes{i} = nodes;
        allTriangles{i} = triangles;
        
%         fprintf('Phase %d converted: %d nodes, %d triangles.\n', ...
%             currentPhaseID, size(nodes,1), size(triangles,1));
    end
end

function [nodes, triangles] = voxelToExactMesh(BW, spacing)
    if nargin < 2, spacing = [1, 1, 1]; end
    [Nx, Ny, Nz] = size(BW);

    BW_xm = false(Nx, Ny, Nz); BW_xm(2:end,:,:) = BW(1:end-1,:,:);
    BW_xp = false(Nx, Ny, Nz); BW_xp(1:end-1,:,:) = BW(2:end,:,:);
    BW_ym = false(Nx, Ny, Nz); BW_ym(:,2:end,:) = BW(:,1:end-1,:);
    BW_yp = false(Nx, Ny, Nz); BW_yp(:,1:end-1,:) = BW(:,2:end,:);
    BW_zm = false(Nx, Ny, Nz); BW_zm(:,:,2:end) = BW(:,:,1:end-1);
    BW_zp = false(Nx, Ny, Nz); BW_zp(:,:,1:end-1) = BW(:,:,2:end);

    face_xm = BW & ~BW_xm; face_xp = BW & ~BW_xp;
    face_ym = BW & ~BW_ym; face_yp = BW & ~BW_yp;
    face_zm = BW & ~BW_zm; face_zp = BW & ~BW_zp;

    node_sz = [Nx+1, Ny+1, Nz+1];
    all_quads = [];

    [x, y, z] = ind2sub([Nx, Ny, Nz], find(face_xm));
    if ~isempty(x)
        q1 = sub2ind(node_sz, x, y, z); q2 = sub2ind(node_sz, x, y, z+1);
        q3 = sub2ind(node_sz, x, y+1, z+1); q4 = sub2ind(node_sz, x, y+1, z);
        all_quads = [all_quads; q1, q2, q3, q4];
    end

    [x, y, z] = ind2sub([Nx, Ny, Nz], find(face_xp));
    if ~isempty(x)
        q1 = sub2ind(node_sz, x+1, y, z); q2 = sub2ind(node_sz, x+1, y+1, z);
        q3 = sub2ind(node_sz, x+1, y+1, z+1); q4 = sub2ind(node_sz, x+1, y, z+1);
        all_quads = [all_quads; q1, q2, q3, q4];
    end

    [x, y, z] = ind2sub([Nx, Ny, Nz], find(face_ym));
    if ~isempty(x)
        q1 = sub2ind(node_sz, x, y, z); q2 = sub2ind(node_sz, x+1, y, z);
        q3 = sub2ind(node_sz, x+1, y, z+1); q4 = sub2ind(node_sz, x, y, z+1);
        all_quads = [all_quads; q1, q2, q3, q4];
    end

    [x, y, z] = ind2sub([Nx, Ny, Nz], find(face_yp));
    if ~isempty(x)
        q1 = sub2ind(node_sz, x, y+1, z); q2 = sub2ind(node_sz, x, y+1, z+1);
        q3 = sub2ind(node_sz, x+1, y+1, z+1); q4 = sub2ind(node_sz, x+1, y+1, z);
        all_quads = [all_quads; q1, q2, q3, q4];
    end

    [x, y, z] = ind2sub([Nx, Ny, Nz], find(face_zm));
    if ~isempty(x)
        q1 = sub2ind(node_sz, x, y, z); q2 = sub2ind(node_sz, x, y+1, z);
        q3 = sub2ind(node_sz, x+1, y+1, z); q4 = sub2ind(node_sz, x+1, y, z);
        all_quads = [all_quads; q1, q2, q3, q4];
    end

    [x, y, z] = ind2sub([Nx, Ny, Nz], find(face_zp));
    if ~isempty(x)
        q1 = sub2ind(node_sz, x, y, z+1); q2 = sub2ind(node_sz, x+1, y, z+1);
        q3 = sub2ind(node_sz, x+1, y+1, z+1); q4 = sub2ind(node_sz, x, y+1, z+1);
        all_quads = [all_quads; q1, q2, q3, q4];
    end

    if isempty(all_quads)
        nodes = []; triangles = []; return;
    end

    triangles_lin = [all_quads(:,1), all_quads(:,2), all_quads(:,3); ...
                     all_quads(:,1), all_quads(:,3), all_quads(:,4)];

    [unq_node_idx, ~, new_tri_idx] = unique(triangles_lin(:));
    triangles = reshape(new_tri_idx, size(triangles_lin));

    [unq_x, unq_y, unq_z] = ind2sub(node_sz, unq_node_idx);
    nodes = [(unq_x - 1) * spacing(1), (unq_y - 1) * spacing(2), (unq_z - 1) * spacing(3)];
end