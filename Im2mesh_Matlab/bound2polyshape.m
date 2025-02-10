function p = bound2polyshape(bounds)
% Convert polygonal boundaries to a cell array of polyshape object
%
% input:
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain grayscale level in image.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.
%
% output:
% p - cell array. p{i} is a polyshape object, which corresponds to polygons
%     in bounds{i}
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    p = cell( length(bounds), 1 );  % p is a cell vector for polyshape
    
    % boundary cell to polyshape cell
    for i = 1: length(bounds)
        x_temp = [];
        y_temp = [];
        for j = 1: length(bounds{i})
            x_temp = [ x_temp; NaN; bounds{i}{j}(:,1) ];
            y_temp = [ y_temp; NaN; bounds{i}{j}(:,2) ];
        end
        p{i} = polyshape( x_temp, y_temp );
        p{i} = simplify( p{i} );
    end
end

