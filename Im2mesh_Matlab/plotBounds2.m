function plotBounds2( boundsA, boundsB )
% plot 2 polygonal boundaries
%
% usage:
%   plotBounds2( boundsA, boundsB );
%
%   bounds - a nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%            plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%            polygon. Use plotBounds( bounds ) to view all polygons.
%

    figure;
    title(['Black - ', inputname(1),'.  Blue - ', inputname(2)])
    hold on
    axis image off;
    
    b = boundsA;
    for i = 1: length(b)
	    for j = 1: length(b{i})
		    poly = b{i}{j};
		    plot( poly(:,1), poly(:,2), 'k' );
	    end
    end
    
    b = boundsB;
    for i = 1: length(b)
	    for j = 1: length(b{i})
		    poly = b{i}{j};
		    plot( poly(:,1), poly(:,2), 'b' );
	    end
    end
    
    hold off
end
