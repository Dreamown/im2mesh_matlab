function plotBounds( bounds, tf_show_ctrlpnt )
% plot bounds{i}{j}
%
% usage:
%   plotBounds( bounds );
%   plotBounds( bounds, true );     % show starting and control points
%
% bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons.
%

    % check the number of inputs
    if nargin == 1
        tf_show_ctrlpnt = false;
    elseif nargin == 2
        % normal case
    else
        error("check the number of inputs");
    end

    figure;
    hold on
    axis image off;
    
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            poly = bounds{i}{j};
            plot( poly(:,1), poly(:,2), 'k' );

            if tf_show_ctrlpnt == true
                % show starting points with 'x'
                plot( poly(1,1), poly(1,2), 'k x' );
                
                % show control points with 'o'
                % find NaN
                TFNaN = isnan( poly(:,1) );
                index = find( TFNaN ) - 1;
                % show control points with 'o'
                for k = 1: length(index)
                     plot( poly(index(k),1), poly(index(k),2), 'k o' );
                end
            end
        end
    end
    hold off
end
