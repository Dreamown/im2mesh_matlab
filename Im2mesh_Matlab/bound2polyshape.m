function p = bound2polyshape(bounds)
% bound2polyshape: Convert a cell array of polygonal boundaries to a cell 
% array of polyshape objects.
%
% input:
%   bounds - a nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%            plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%            polygon. Use plotBounds( bounds ) to view all polygons.
%
% output:
% p - cell array. p{i} is a polyshape object, which corresponds to polygons
%     in bounds{i}
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    try
        p = cell( length(bounds), 1 );  % p is a cell vector for polyshape
        
        % boundary cell to polyshape cell
        for i = 1: length(bounds)
            x_temp = [];
            y_temp = [];
            for j = 1: length(bounds{i})
                x_temp = [ x_temp; NaN; bounds{i}{j}(:,1) ];
                y_temp = [ y_temp; NaN; bounds{i}{j}(:,2) ];
            end
            p{i} = polyshape( x_temp, y_temp, 'KeepCollinearPoints', true  );
        end
    catch
        p = cell( length(bounds), 1 );  % p is a cell vector for polyshape
        
        % boundary cell to polyshape cell
        for i = 1: length(bounds)
            x_temp = [];
            y_temp = [];
            for j = 1: length(bounds{i})
                x_temp = [ x_temp; NaN; bounds{i}{j}(:,1) ];
                y_temp = [ y_temp; NaN; bounds{i}{j}(:,2) ];
            end
            p{i} = polyshape( x_temp, y_temp  );
        end
    end
end

