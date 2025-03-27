function xyNew = insertEleSizeSeed( xy, targetLen )
% insertEleSizeSeed: insert equally spaced seeds to polyline (edges)
%
% xy - n-by-2 array. Each row is a vertex for polyline.
% targetLen - space between seeds
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % --------------------------------------------------------------------
    % calculate edge length
    dx = diff(xy(:,1));
    dy = diff(xy(:,2));
    len = sqrt(dx.^2 + dy.^2);      % vector

    % calculate the number of future segments for each edge by rounding!
    numSegment = round( len / targetLen );      % vector
    
    % --------------------------------------------------------------------
    % insert

    nEdge = size(xy,1) - 1;
    xyCell = cell( nEdge, 1 );

    for i = 1: nEdge
        if numSegment(i) >= 2      
            % insert uniform seeds into the line segment
            tempPnts = divideSegment( xy(i:i+1,:), numSegment(i) );

            % exclude the end pnt
            xyCell{i} = tempPnts( 1:end-1, : );     
        else
            xyCell{i} = xy(i,:);
        end
    end

    % --------------------------------------------------------------------
    % vertical concatenation
    xyNew = vertcat( xyCell{:} );

    % add the end pnt
    xyNew(end+1,:) = xy(end,:);     

    % --------------------------------------------------------------------
end

function newPnts = divideSegment( twoPnt, numSegment )
% divideSegment: insert equally spaced vertices between two points to make 
% it become a polyline with (numSegment) segments. 

    x1 = twoPnt(1,1);
    y1 = twoPnt(1,2);

    x2 = twoPnt(2,1);
    y2 = twoPnt(2,2);

    % generate numPnt points
    numPnt = numSegment + 1;
    newx = linspace( x1, x2, numPnt )';
    newy = linspace( y1, y2, numPnt )';

    newPnts = [newx, newy];

end