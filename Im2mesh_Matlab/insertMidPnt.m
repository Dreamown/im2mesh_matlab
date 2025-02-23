function xyNew = insertMidPnt(xy)
% insertMidPnt: inserts midpoints between vertices of a polyline
%
% takes the coordinates x, y of a 2D polyline, and returns new coordinates 
% xNew, yNew. The new coordinates will have midpoints inserted on each edge
%

    x = xy(:,1);
    y = xy(:,2);

    % number of vertex
    n = length(x);

    % Number of edges is (n-1). 
    % We add two vertices per edge + final closure.
    m = 2*(n - 1) + 1;
    xNew = zeros(m, 1);
    yNew = zeros(m, 1);

    % Fill new arrays
    for i = 1 : (n - 1)
        % Original vertex goes to index 2i-1
        xNew(2*i - 1) = x(i);
        yNew(2*i - 1) = y(i);

        % Midpoint goes to index 2i
        xNew(2*i) = 0.5 * (x(i) + x(i+1));
        yNew(2*i) = 0.5 * (y(i) + y(i+1));
    end

    % last vertex
    xNew(end) = x(end);
    yNew(end) = y(end);

    xyNew = [xNew, yNew];

end
