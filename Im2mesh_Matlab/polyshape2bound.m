function bounds = polyshape2bound( pC )
% polyshape2bound: polyshape cell to boundary cell
% 

    bounds = cell( length(pC), 1 );
    
    for i = 1: length(bounds)
        [ x, y ] = boundary(pC{i});
        [ xC, yC ] = polysplit( x, y );

        num_face = numel(xC);
        bounds{i} = cell( num_face, 1 );

        for j = 1: num_face
            bounds{i}{j} = [ xC{j}, yC{j} ];
        end
    end

    % post-process
    bounds = bounds2CCW( bounds );       % counterclockwise ordering
end


function bounds = bounds2CCW( bounds )
% Convert polygon contour to counterclockwise vertex ordering
% 
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            [ bounds{i}{j}(:,1), bounds{i}{j}(:,2) ] = poly2ccw( ...
                                    bounds{i}{j}(:,1), bounds{i}{j}(:,2) );
            
        end
    end
end










