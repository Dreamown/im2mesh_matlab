function plotMeshes( vert, ele, tnum, color_code, opt )
% plotMeshes: plot triangular or quadrilateral finite element mesh
% Works for linear and quadratic elements
%
% Nodes must be counter-clockwise ordering in an linear element.
%
% usage:
%   plotMeshes( vert, ele );        % one phase
%   plotMeshes( vert, ele, tnum );  % multiple phases
%
%   plotMeshes( vert, ele, [], color_code );    % one phase
%   plotMeshes( vert, ele, tnum, color_code );  % multiple phases
%   plotMeshes( vert, ele, tnum, 2 );
%
%   opt = [];
%   opt.mode = 2;
%   plotMeshes(vert,ele,tnum,2,opt)
%
%   opt = [];
%   opt.mode = 1;
%   opt.wid = 0.5;
%   opt.alpha = 0.2;
%   opt.beta = 0.5;
%   opt.tf_gs = 1;
%   plotMeshes(vert,ele,tnum,2,opt)
%
% input:
%   vert - Node data. N-by-2 array.
%       vert(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   ele - Node numbering for each element. 
%       For example, if linear triangle element, ele is M-by-3 array.
%       ele(j,1:3) = [node_numbering_of_3_nodes] of the j-th element
%
%   tnum - Label of material phase. P-by-1 array.
%       tnum(j,1) = k; means the j-th element is belong to the k-th phase
%
%   color_code - Color code for selecting colormap.
%                Interger. Value: 0-10. Default value: 0.
%
%   opt.mode = 1;   1, 2, 3
%   opt.wid = 0.5;  positive
%   opt.alpha = 0.5;  [0 1]
%   opt.beta = 0;   [-1 1]
%   opt.tf_gs = 1;
%
% by Jiexian Ma, mjx0799@gmail.com
% 
% Project website: https://github.com/mjx888/im2mesh
%

    %--------------------------------------------------------------------   
    % Check the number of inputs. If missing, set as empty. 
    if nargin < 2
        error("Not enough input arguments.");
    end
    
    if nargin < 3
        tnum = [];
    end
    
    if nargin < 4
        color_code = [];
    end
    
    if nargin < 5
        opt = [];
    end

    % ---------------------------------------------------------------------
    % verify field names and set values for opt
    opt = setOption( opt );

    % ---------------------------------------------------------------------
    % If input is empty, assign defaualt value to input
    if isempty(tnum)
        tnum = ones( size(ele,1), 1 );
    end

    if isempty(color_code)
        color_code = 0;
    end

    %--------------------------------------------------------------------
    % check element type
    ele_wid = size(ele,2);

    if ele_wid == 3         % linear triangle
        range_vec = 1:3;
    elseif ele_wid == 6     % quadratic triangle
        range_vec = [1 4 2 5 3 6];
    elseif ele_wid == 4     % linear quadrilateral
        range_vec = 1:4;
    elseif ele_wid == 8     % quadratic quadrilateral
        range_vec = [1 5 2 6 3 7 4 8];
    else
        error("ele - wrong size")
    end

    %--------------------------------------------------------------------
    tvalue = unique( tnum );
    num_phase = length( tvalue );
    
    %--------------------------------------------------------------------
    % setup color
    % Create variable 'colors' - num_phase-by-3 array.
    % Each row in 'colors' is one rgb color.

    switch color_code
        case 0
            % grayscale
            if num_phase == 1
                col = 0.98;
            elseif num_phase > 1
                col = 0.3: 0.68/(num_phase-1): 0.98;
                col = col(:);
            end
            colors = [col, col, col];

        case 1
            colors = lines( num_phase );
        case 2
            colors = parula( num_phase );
        case 3
            colors = turbo( num_phase );
        case 4
            colors = jet( num_phase );
        case 5
            colors = hot( num_phase );
        case 6
            colors = cool( num_phase );
        case 7
            colors = summer( num_phase );
        case 8
            colors = winter( num_phase );
        case 9
            colors = bone( num_phase );
        case 10
            colors = pink( num_phase );
        otherwise
            error('Input argument color_code is out of range.')
    end

    colors = brighten( colors, opt.beta );

    %--------------------------------------------------------------------
    % plot mesh
    figure;
    hold on;
    axis image off;

    if opt.tf_gs == 0
        set(gcf,'GraphicsSmoothing','off');
    end
    
    if opt.mode == 1
        % use function patch to plot
        for i = 1: num_phase
            current_phase = tvalue(i);
            patch( ...
                'faces', ele( tnum==current_phase, range_vec ), ...
                'vertices', vert, ...
                'facecolor', colors(i,:), ...
                'edgecolor', [.1,.1,.1], ...
                'linewidth', opt.wid, ...
                'edgealpha', opt.alpha ...
                );
        end

    elseif opt.mode == 2
        % use function patch to plot
        for i = 1: num_phase
            current_phase = tvalue(i);
            patch( ...
                'faces', ele( tnum==current_phase, range_vec ), ...
                'vertices', vert, ...
                'facecolor', 'none', ...
                'edgecolor', 0.8*colors(i,:), ...
                'linewidth', opt.wid, ...
                'edgealpha', opt.alpha ...
                );
        end
        
    elseif opt.mode == 3        
        % use function triplot to plot      % need checking !!!
        for i = 1: num_phase
            current_phase = tvalue(i);
	        triplot( ...
                    ele( tnum==current_phase, 1:3 ), ...
                    vert(:,1), vert(:,2), ...
                    'color', 0.8*colors(i,:), ...
                    'linewidth', opt.wid ...
                    );   
        end
        
    end

    hold off
    %--------------------------------------------------------------------
    
end


function new_opt = setOption( opt )
% setOption: verify field names in opt and set values in new_opt according
% to opt

    % initialize new_opt with default field names & value 
    new_opt.mode = 1;
    new_opt.wid = 0.5;
    new_opt.alpha = 0.5;
    new_opt.beta = 0;
    new_opt.tf_gs = 1;
    
    if isempty(opt)
        return
    end

    if ~isstruct(opt)
        error("opt is not a structure array. Not valid input.")
    end

    % get the field names of opt
    nameC = fieldnames(opt);

    % verify field names in opt and set values in new_opt
    % compare the field name of opt with new_opt using for loop
    % if a field name of opt exist in new_opt, assign the that field value 
    % in opt to new_opt
    % if a field name of opt not exist in new_opt, show error

    for i = 1: length(nameC)
        if isfield( new_opt, nameC{i} )
            value = getfield( opt, nameC{i} );
            new_opt = setfield( new_opt, nameC{i}, value );
        else
            error("Field name %s in opt is not correct.", nameC{i});
        end
    end

end



