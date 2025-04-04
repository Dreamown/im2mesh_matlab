function plotBounds( bounds, tf_show_ctrlpnt, lin_spec )
% plotBounds: plot polygonal boundaries
%
% usage:
%   plotBounds( bounds );
%   plotBounds( bounds, true );     % show starting and control points
%   plotBounds( bounds, false, '' );        % show color
%   plotBounds( bounds, false, 'k.-' );     % with line specification
%   plotBounds( bounds, true, 'k.-' );
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
%   tf_show_ctrlpnt - Boolean. Whether to show starting and control points.
%                     Default value: false.
%
%   lin_spec - Line specification. Default value is 'k'. (black line)
%

    % ---------------------------------------------------------------------
    % check the number of inputs
    if nargin == 1
        tf_show_ctrlpnt = false;
        lin_spec = 'k';
    elseif nargin == 2
        lin_spec = 'k';
    elseif nargin == 3
        % all the input are specified
    else
        error("check the number of inputs");
    end

    % ---------------------------------------------------------------------
    % find x y range
    [xmin, xmax, ymin, ymax] = xyRange( bounds );

    xWid = xmax - xmin;
    yWid = ymax - ymin;

    xlim_vec = [ xmin-0.1*xWid, xmax ];
    ylim_vec = [ ymin-0.1*yWid, ymax ];

    % ---------------------------------------------------------------------
    % plot
    figure;
    hold on
    axis equal
    % axis image off;
    
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            poly = bounds{i}{j};
            plot( poly(:,1), poly(:,2), lin_spec );
            
            % show starting point and ctrl points
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

    xlim(xlim_vec);
    ylim(ylim_vec);

    hold off
end
