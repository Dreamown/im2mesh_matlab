function loops = makeOuterBoundaryFirst(loops, P)
%MAKEOUTERBOUNDARYFIRST Reorder loops so the one with the largest |area| is first.
%
%  loops : cell array, each element is a list of vertex indices defining a boundary loop.
%  P     : (nPts x 2) vertex coordinates.
%
%  This assumes that in your mesh, the loop with the largest absolute area
%  is indeed the outer boundary.

    % 1) Compute signed area of each loop
    [loopArea, ~] = classifyBoundaryLoops(loops, P);
    
    % 2) Find the loop with the maximum absolute area
    [~, mainIdx] = max(abs(loopArea));
    
    % 3) Reorder loops so that this loop is first
    nLoops = numel(loops);
    newOrder = [ mainIdx, setdiff(1:nLoops, mainIdx) ];
    
    loops = loops(newOrder);
end

function [loopArea, loopType] = classifyBoundaryLoops(loops, P)
%CLASSIFYBOUNDARYLOOPS Compute signed area of each loop and label as 'outer' or 'hole'.
%
%  loopArea : (nLoops x 1) signed area of each loop
%             > 0 => CCW => "outer"
%             < 0 => CW  => "hole"
%  loopType : cell array, 'outer' or 'hole'

    nLoops = numel(loops);
    loopArea = zeros(nLoops,1);
    loopType = cell(nLoops,1);

    for i = 1:nLoops
        coords = P(loops{i}, :);
        loopArea(i) = polygonSignedArea2D(coords);
        if loopArea(i) > 0
            loopType{i} = 'outer';
        else
            loopType{i} = 'hole';
        end
    end
end

function signedArea = polygonSignedArea2D(coords)
%POLYGONSIGNEDAREA2D Compute the signed area of a 2D polygon (shoelace formula).
%  Positive => CCW orientation, Negative => CW orientation.

    % Ensure the polygon is closed
    if any(coords(end,:) ~= coords(1,:))
        coords(end+1,:) = coords(1,:);
    end
    
    x = coords(:,1);
    y = coords(:,2);
    signedArea = 0.5 * sum( x(1:end-1).*y(2:end) - x(2:end).*y(1:end-1) );
end
