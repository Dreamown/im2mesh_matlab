function area = quadarea(vert, ele)
% quadarea calculates the signed area of each quadrilateral element,
% where the sign depends on the node ordering:
%   - Counterclockwise ordering yields a positive area.
%   - Clockwise ordering yields a negative area.
%
%   area = quadarea(vert, ele)
%
% INPUTS:
%   vert : Nn-by-2 matrix of (x, y) coordinates for the Nn mesh nodes.
%   ele  : Ne-by-4 matrix of node indices for the Ne quadrilaterals.
%
% OUTPUT:
%   area : Ne-by-1 column vector of (signed) element areas.

    % Number of elements
    Ne = size(ele, 1);

    % Initialize output area vector
    area = zeros(Ne, 1);

    for i = 1:Ne
        % Extract the node indices for element i
        nodes = ele(i, :);

        % Extract the coordinates of the 4 vertices
        x = vert(nodes, 1);
        y = vert(nodes, 2);

        % Shoelace formula components
        sum1 = x(1)*y(2) + x(2)*y(3) + x(3)*y(4) + x(4)*y(1);
        sum2 = y(1)*x(2) + y(2)*x(3) + y(3)*x(4) + y(4)*x(1);

        % Signed area: no absolute value
        area(i) = 0.5 * (sum1 - sum2);
    end
end
