function plotBounds2( boundsA, boundsB )
% plot 2 polygonal boundaries
%
% usage:
%   plotBounds2( boundsA, boundsB );
%
% boundsA - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons.
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
