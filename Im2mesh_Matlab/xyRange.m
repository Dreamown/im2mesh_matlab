function [xminG,xmaxG,yminG,ymaxG] = xyRange( inarg )
%  xyRange: get the range of x y coordinate in polygonal boundary
%
% usage:
%   [xmin,xmax,ymin,ymax] = xyRange( bounds );
%   [xmin,xmax,ymin,ymax] = xyRange( polyshapeCell );
%
% input:
%   inarg: a nested cell array of polygonal boundary 
%          or a cell array of polyshape
%
% 
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
%

    % --------------------------------------------------------------------
    % check input
    if isa( inarg{1}, 'polyshape' )
        bounds = polyshape2bound( inarg );

    elseif size( inarg{1}{1}, 2 ) == 2
        bounds = inarg;
        
    else
        error( '%s\n%s', ...
            'Input should be a nested cell array of polygonal boundary ', ...
            'or a cell array of polyshape' ...
            );
    end

    % --------------------------------------------------------------------
    % initialize
    xminG = bounds{1}{1}(1,1);  
    xmaxG = bounds{1}{1}(1,1);

    yminG = bounds{1}{1}(1,2);  
    ymaxG = bounds{1}{1}(1,2);

    % --------------------------------------------------------------------
    % compare
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            p = bounds{i}{j};

            xymin = min(p);
            xmin = xymin(1);
            ymin = xymin(2);

            xymax = max(p);
            xmax = xymax(1);
            ymax = xymax(2);
            
            if xmin < xminG
                xminG = xmin;
            end

            if ymin < yminG
                yminG = ymin;
            end

            if xmax > xmaxG
                xmaxG = xmax;
            end

            if ymax > ymaxG
                ymaxG = ymax;
            end
        end
    end
    % --------------------------------------------------------------------
end













