function [Q, Volume] = tetcost(vert, ele)
% TETCOST Evaluates the quality of a tetrahedral finite element mesh.
%
%   [Q, Volume] = tetcost(vert, ele)
%
%   INPUTS:
%       vert - Nn-by-3 matrix of vertex coordinates [x, y, z].
%       ele  - Ne-by-4 (linear) or Ne-by-10 (quadratic) matrix of element 
%              connectivity. Each row contains the vertex indices. 
%              For quadratic elements, the first 4 indices must be the corners.
%
%   OUTPUTS:
%       Q      - Ne-by-1 vector of element quality metrics (range: 0 to 1).
%                1 represents a perfect equilateral tetrahedron.
%                0 represents a degenerate (flat) tetrahedron.
%       Volume - Ne-by-1 vector of the calculated element volumes.
%
%   QUALITY METRIC DEFINITION:
%   This uses MATLAB's built-in metric, which heavily penalizes "slivers":
%       Q = 18 * V / ( sqrt(sum(L_i^2)) * sqrt(sum(A_k^2)) )
%
% Project website: https://github.com/mjx888/im2mesh
%

    % --- 1. Input Validation ---
    if size(vert, 2) ~= 3
        error('The vert matrix must be Nn-by-3 (containing x, y, z coordinates).');
    end
    
    if size(ele, 2) ~= 4 && size(ele, 2) ~= 10
        if size(ele, 2) == 3 || size(ele, 2) == 6
            error('The ele matrix represents a triangle surface mesh. A tetrahedral volume mesh requires Ne-by-4 or Ne-by-10.');
        else
            error('The ele matrix must be Ne-by-4 (linear) or Ne-by-10 (quadratic) for a tetrahedral volume mesh.');
        end
    end

    % --- 2. Extract Vertices ---
    % Extract the 3D coordinates for the 4 corner nodes of every tetrahedron.
    % For 10-node quadratic elements, this naturally ignores the mid-edge nodes
    % (columns 5-10) and evaluates the shape of the underlying base tetrahedron.
    A = vert(ele(:, 1), :);
    B = vert(ele(:, 2), :);
    C = vert(ele(:, 3), :);
    D = vert(ele(:, 4), :);

    % --- 3. Compute Edge Vectors & Lengths ---
    % Calculate vectors for all 6 edges of the tetrahedrons
    E1 = B - A;
    E2 = C - B;
    E3 = A - C; 
    E4 = D - A;
    E5 = D - B;
    E6 = D - C;
    
    % Calculate the squared lengths of all 6 edges
    L1_sq = sum(E1.^2, 2);
    L2_sq = sum(E2.^2, 2);
    L3_sq = sum(E3.^2, 2);
    L4_sq = sum(E4.^2, 2);
    L5_sq = sum(E5.^2, 2);
    L6_sq = sum(E6.^2, 2);
    
    % Sum of squared edge lengths for each element
    SumL2 = L1_sq + L2_sq + L3_sq + L4_sq + L5_sq + L6_sq;

    % --- 4. Compute Face Areas & Volume ---
    % Calculate cross products for the 4 faces
    Cross1 = cross(B - A, C - A, 2); % Face A-B-C
    Cross2 = cross(B - A, D - A, 2); % Face A-B-D
    Cross3 = cross(C - A, D - A, 2); % Face A-C-D
    Cross4 = cross(C - B, D - B, 2); % Face B-C-D
    
    % Sum of squared areas of the 4 triangular faces (Area = 0.5 * |Cross|)
    SumA2 = 0.25 * (sum(Cross1.^2, 2) + sum(Cross2.^2, 2) + sum(Cross3.^2, 2) + sum(Cross4.^2, 2));

    % Calculate the volume of each tetrahedron using the scalar triple product
    Volume = abs(sum((D - A) .* Cross1, 2)) / 6;

    % --- 5. Compute Quality Metric (Q) ---
    % We add 'eps' to the denominator to prevent division by zero.
    Q = (18 * Volume) ./ (sqrt(SumL2) .* sqrt(SumA2) + eps);

    % --- 6. Command Window Output (Optional) ---
    % If the user runs the function without assigning outputs, print a summary
    if nargout == 0
        fprintf('\n--- Tetrahedral Mesh Quality Summary ---\n');
        fprintf('Total Elements:      %d\n', size(ele, 1));
        fprintf('Mean Quality (Q):    %.4f\n', mean(Q));
        fprintf('Min Quality (Q):     %.4f\n', min(Q));
        fprintf('Max Quality (Q):     %.4f\n', max(Q));
        fprintf('Poor Elements (<0.1): %d\n', sum(Q < 0.1));
        fprintf('----------------------------------------\n\n');
        
        % Clear variables so they don't dump into the workspace
        clear Q Volume; 
    end
end