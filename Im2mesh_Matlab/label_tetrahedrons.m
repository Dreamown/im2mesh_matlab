function labels = label_tetrahedrons(vert, ele, phaseFaces, V)
% Applies an Spatial-Hash Ray Caster for phase labeling
% Hashes points ONCE, uses flat array memory (no cell arrays).
% Project website: https://github.com/mjx888/im2mesh
%
    
    disp('//////////////// Phase labeling ////////////////');

    % disp('  -> Calculating tetrahedron centroids...');
    v1 = vert(ele(:,1), :);
    v2 = vert(ele(:,2), :);
    v3 = vert(ele(:,3), :);
    v4 = vert(ele(:,4), :);
    centroids = (v1 + v2 + v3 + v4) / 4;
    
    numElems = size(ele, 1);
    labels = zeros(numElems, 1); % 0 is background
    
    % disp('  -> Applying irrational rotation for robust ray casting...');
    theta_x = pi / 7.1234;
    theta_y = exp(1) / 5.123;
    Rx = [1, 0, 0; 0, cos(theta_x), -sin(theta_x); 0, sin(theta_x), cos(theta_x)];
    Ry = [cos(theta_y), 0, sin(theta_y); 0, 1, 0; -sin(theta_y), 0, cos(theta_y)];
    R = Rx * Ry;
    
    centroids_rot = centroids * R';
    V_rot = V * R';
    
    % Decide grid size ONCE based on robust heuristics
    rangeX = max(centroids_rot(:,1)) - min(centroids_rot(:,1));
    rangeY = max(centroids_rot(:,2)) - min(centroids_rot(:,2));
    % Target roughly 500x500 grid to prevent memory blowouts while maintaining high localization
    grid_size = max([rangeX/500, rangeY/500, 1e-3]); 
    
    % disp('  -> Building Global Spatial Hash (Flat Memory Architecture)...');
    [cell_start, cell_end, sort_order, minPx, minPy, num_cells_X, num_cells_Y] = build_spatial_hash(centroids_rot, grid_size);
    
    for i = 1:length(phaseFaces)
        F_phase = phaseFaces{i};
        if isempty(F_phase), continue; end
        
        fprintf('Phase %d / %d ...\n', i, length(phaseFaces));
        % Raycast utilizing the pre-built global hash
        inPhase = fast_Z_raycast_hashed(F_phase, V_rot, centroids_rot, grid_size, ...
                                        cell_start, cell_end, sort_order, ...
                                        minPx, minPy, num_cells_X, num_cells_Y);
        
        labels(inPhase) = i; % Assign phase label
    end
    
    disp('//////////////// Labeling complete! ////////////////');
end

function [cell_start, cell_end, sort_order, minPx, minPy, num_cells_X, num_cells_Y] = build_spatial_hash(P, grid_size)
% Replaces slow `accumarray` cell lists with hyper-fast sorted flat arrays
    numP = size(P, 1);
    minPx = min(P(:,1)) - grid_size;
    minPy = min(P(:,2)) - grid_size;
    
    grid_X = floor((P(:,1) - minPx) / grid_size) + 1;
    grid_Y = floor((P(:,2) - minPy) / grid_size) + 1;
    
    num_cells_X = max(grid_X);
    num_cells_Y = max(grid_Y);
    lin_grid_idx = grid_X + (grid_Y - 1) * num_cells_X;
    
    % Sort points by their grid index
    [sorted_grid_idx, sort_order] = sort(lin_grid_idx);
    
    % Find transitions (where one cell ends and the next begins)
    transitions = [1; find(diff(sorted_grid_idx)) + 1; numP + 1];
    unique_grids = sorted_grid_idx(transitions(1:end-1));
    
    % Map the exact start and end row indices in `sort_order` for every possible grid ID
    cell_start = zeros(num_cells_X * num_cells_Y, 1);
    cell_end = zeros(num_cells_X * num_cells_Y, 1);
    cell_start(unique_grids) = transitions(1:end-1);
    cell_end(unique_grids) = transitions(2:end) - 1;
end

function in = fast_Z_raycast_hashed(F, V_rot, P_rot, grid_size, cell_start, cell_end, sort_order, minPx, minPy, num_cells_X, num_cells_Y)
    % Inner Raycaster, heavily vectorized and memory-preallocated
    numP = size(P_rot, 1);
    numF = size(F, 1);

    X0 = V_rot(F(:,1), 1); Y0 = V_rot(F(:,1), 2); Z0 = V_rot(F(:,1), 3);
    X1 = V_rot(F(:,2), 1); Y1 = V_rot(F(:,2), 2); Z1 = V_rot(F(:,2), 3);
    X2 = V_rot(F(:,3), 1); Y2 = V_rot(F(:,3), 2); Z2 = V_rot(F(:,3), 3);

    minX = min([X0, X1, X2], [], 2); maxX = max([X0, X1, X2], [], 2);
    minY = min([Y0, Y1, Y2], [], 2); maxY = max([Y0, Y1, Y2], [], 2);
    maxZ = max([Z0, Z1, Z2], [], 2);

    % Plane params
    Nx = (Y1-Y0).*(Z2-Z0) - (Z1-Z0).*(Y2-Y0);
    Ny = (Z1-Z0).*(X2-X0) - (X1-X0).*(Z2-Z0);
    Nz = (X1-X0).*(Y2-Y0) - (Y1-Y0).*(X2-X0);
    D = -(Nx.*X0 + Ny.*Y0 + Nz.*Z0);
    
    validFaces = abs(Nz) > 1e-8;
    invNz = 1 ./ Nz; % Optimization: Divide outside the loop

    min_gx = max(1, floor((minX - minPx) / grid_size) + 1);
    max_gx = min(num_cells_X, floor((maxX - minPx) / grid_size) + 1);
    min_gy = max(1, floor((minY - minPy) / grid_size) + 1);
    max_gy = min(num_cells_Y, floor((maxY - minPy) / grid_size) + 1);

    crosses = zeros(numP, 1);

    % Pre-extract arrays for speed
    Px_all = P_rot(:,1); Py_all = P_rot(:,2); Pz_all = P_rot(:,3);

    for f = 1:numF
        if ~validFaces(f), continue; end

        % Phase 1: Rapid Cell Fetch (Pre-allocated, no slow array growing)
        cid_list = zeros((max_gx(f)-min_gx(f)+1) * (max_gy(f)-min_gy(f)+1), 1);
        c_count = 0;
        for xi = min_gx(f):max_gx(f)
            for yi = min_gy(f):max_gy(f)
                cid = xi + (yi - 1) * num_cells_X;
                if cell_start(cid) > 0
                    c_count = c_count + 1;
                    cid_list(c_count) = cid;
                end
            end
        end
        
        if c_count == 0, continue; end
        
        % Phase 2: Exact Point Extraction
        if c_count == 1
            pts = sort_order(cell_start(cid_list(1)) : cell_end(cid_list(1)));
        else
            total_pts = sum(cell_end(cid_list(1:c_count)) - cell_start(cid_list(1:c_count)) + 1);
            pts = zeros(total_pts, 1);
            idx_fill = 1;
            for c = 1:c_count
                cid = cid_list(c);
                n_p = cell_end(cid) - cell_start(cid) + 1;
                pts(idx_fill : idx_fill + n_p - 1) = sort_order(cell_start(cid) : cell_end(cid));
                idx_fill = idx_fill + n_p;
            end
        end

        Px = Px_all(pts); Py = Py_all(pts); Pz = Pz_all(pts);

        % Phase 3: Strict bounding box filter
        bb_mask = Px >= minX(f) & Px <= maxX(f) & ...
                  Py >= minY(f) & Py <= maxY(f) & ...
                  Pz < maxZ(f);

        pts = pts(bb_mask);
        if isempty(pts), continue; end

        Px = Px(bb_mask); Py = Py(bb_mask); Pz = Pz(bb_mask);

        % Phase 4: 2D Barycentric mapping
        v0x = X2(f) - X0(f); v0y = Y2(f) - Y0(f);
        v1x = X1(f) - X0(f); v1y = Y1(f) - Y0(f);
        v2x = Px - X0(f); v2y = Py - Y0(f);

        dot00 = v0x.*v0x + v0y.*v0y;
        dot01 = v0x.*v1x + v0y.*v1y;
        dot11 = v1x.*v1x + v1y.*v1y;

        dot02 = v0x.*v2x + v0y.*v2y;
        dot12 = v1x.*v2x + v1y.*v2y;

        invDenom = 1 ./ (dot00.*dot11 - dot01.*dot01);
        u = (dot11.*dot02 - dot01.*dot12) .* invDenom;
        v = (dot00.*dot12 - dot01.*dot02) .* invDenom;

        % Exact triangle hit
        inside_tri = (u > -1e-6) & (v > -1e-6) & (u + v < 1 + 1e-6);

        pts = pts(inside_tri);
        if isempty(pts), continue; end
        Px = Px(inside_tri); Py = Py(inside_tri);

        % Phase 5: Ray goes in +Z, so intersection must be strictly > Pz
        Z_intersect = -(Nx(f).*Px + Ny(f).*Py + D(f)) .* invNz(f);
        hit_mask = Z_intersect > Pz(inside_tri);
        
        hit_pts = pts(hit_mask);
        crosses(hit_pts) = crosses(hit_pts) + 1;
    end

    in = mod(crosses, 2) == 1;
end