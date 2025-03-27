function xyNew = insertMidPnt( xy, iters )
% insertMidPnt: repeatedly inserts midpoints between vertices of a polyline
%
% takes the coordinates x, y of a 2D polyline, and returns new coordinates 
% xNew, yNew. The new coordinates will have midpoints inserted on each edge
%
% xy is n-by-2 array. Each row is a vertex in 2D polyline.
% iters is the number of iterations
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % check the number of inputs
    if nargin == 1
        iters = 1;
    elseif nargin == 2
        % all input arguments are given
    else
        error("Check the number of inputs");
    end
    
    % ---------------------------------------------------------------------
    for i = 1: iters
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
        for j = 1 : (n - 1)
            % Original vertex goes to index 2i-1
            xNew(2*j - 1) = x(j);
            yNew(2*j - 1) = y(j);
    
            % Midpoint goes to index 2i
            xNew(2*j) = 0.5 * (x(j) + x(j+1));
            yNew(2*j) = 0.5 * (y(j) + y(j+1));
        end
    
        % last vertex
        xNew(end) = x(end);
        yNew(end) = y(end);
    
        xyNew = [xNew, yNew];

        % update xy for next iteration
        xy = xyNew;
    end
    % ---------------------------------------------------------------------
end
