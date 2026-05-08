function [isMatching, details] = checkPBCNode( vert )
% checkPBCNodeMatching checks if a 2D mesh on a rectangular domain
% satisfies node matching for Periodic Boundary Conditions (PBCs).
%
% Inputs:
%   vert - Nn-by-2 matrix of node coordinates [x, y]
%
% Outputs:
%   isMatching - Boolean, true if opposite boundaries match perfectly
%   details    - Struct containing matching diagnostics and node indices

    % Set a tolerance for floating-point comparisons
    tol = 1e-8;

    % 1. Determine the rectangular bounding box of the domain
    xmin = min(vert(:,1));
    xmax = max(vert(:,1));
    ymin = min(vert(:,2));
    ymax = max(vert(:,2));

    % 2. Identify the indices of nodes on each of the four boundaries
    left_idx   = find(abs(vert(:,1) - xmin) < tol);
    right_idx  = find(abs(vert(:,1) - xmax) < tol);
    bottom_idx = find(abs(vert(:,2) - ymin) < tol);
    top_idx    = find(abs(vert(:,2) - ymax) < tol);

    % 3. Extract the perpendicular coordinates for comparison and sort them
    % For Left/Right, we compare the Y-coordinates
    y_left   = sort(vert(left_idx, 2));
    y_right  = sort(vert(right_idx, 2));
    
    % For Bottom/Top, we compare the X-coordinates
    x_bottom = sort(vert(bottom_idx, 1));
    x_top    = sort(vert(top_idx, 1));

    % 4. Validate Left-Right matching
    match_LR = true;
    msg_LR = 'Left and Right boundaries match perfectly.';
    
    if length(y_left) ~= length(y_right)
        match_LR = false;
        msg_LR = sprintf('Node count mismatch: Left (%d nodes), Right (%d nodes).', length(y_left), length(y_right));
    elseif any(abs(y_left - y_right) > tol)
        match_LR = false;
        msg_LR = 'Node y-coordinates on Left and Right boundaries do not align.';
    end

    % 5. Validate Bottom-Top matching
    match_BT = true;
    msg_BT = 'Bottom and Top boundaries match perfectly.';
    
    if length(x_bottom) ~= length(x_top)
        match_BT = false;
        msg_BT = sprintf('Node count mismatch: Bottom (%d nodes), Top (%d nodes).', length(x_bottom), length(x_top));
    elseif any(abs(x_bottom - x_top) > tol)
        match_BT = false;
        msg_BT = 'Node x-coordinates on Bottom and Top boundaries do not align.';
    end

    % 6. Compile the final results
    isMatching = match_LR && match_BT;
    
    details.match_LR = match_LR;
    details.msg_LR = msg_LR;
    details.match_BT = match_BT;
    details.msg_BT = msg_BT;
    
    % Return the indices in case you need to build the DOF mapping matrix later
    details.left_nodes   = left_idx;
    details.right_nodes  = right_idx;
    details.bottom_nodes = bottom_idx;
    details.top_nodes    = top_idx;
    
    % Print a summary to the command window
    if isMatching
        fprintf('PBC Check Passed: All opposite boundary nodes are aligned.\n');
    else
        fprintf('PBC Check Failed:\n  - %s\n  - %s\n', msg_LR, msg_BT);
    end
end