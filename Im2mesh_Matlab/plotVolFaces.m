function plotVolFaces( im )
% plotVolFaces: plot the outer surfaces of a 3D volume (3d uint8 array).
%
% Plots the 6 outer faces of the 3D array im onto a rectangular cuboid in 
% 3D space.
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % Make grayscale evenly distributed for visualization
    % ---------------------------------------------------------------------
    % Distribute the unique grayscale values evenly across the 0-255 range
    
    % Find all unique grayscale values present in the volume
    % Converted to double immediately to prevent uint8 integer saturation 
    % when adding 1 for the mapping indices later.
    unique_vals = double(unique(im));
    num_vals = length(unique_vals);
    
    % Create an evenly spaced array of new grayscale values from 0 to 255
    if num_vals > 1
        evenly_spaced_vals = round(linspace(0, 255, num_vals));
    else
        evenly_spaced_vals = unique_vals; % Handle single-color case
    end
    
    % Create a lookup table (mapping) for fast replacement
    mapping = zeros(256, 1, 'uint8');
    mapping(unique_vals + 1) = evenly_spaced_vals;
    
    % Apply the mapping to the entire 3D volume
    im = reshape(mapping(double(im(:)) + 1), size(im));

    % ---------------------------------------------------------------------
    % FEM software use right-hand coordinate
    im = flip(im, 1);
    im = rot90(im, -1);

    % Get dimensions (3D array)
    [rows, cols, slices] = size(im);

    % Prepare the figure
    figure; 
    clf;
    hold on;
    axis equal;
    axis off; % Turn off axis lines, labels, and background
    view(3); % Set standard 3D view
    colormap('gray'); % X-ray CT style

    % ---------------------------------------------------------------------
    % Plot the 6 Faces (OPTIMIZED for 2x2 corner grids)
    % ---------------------------------------------------------------------
    
    % FACE 1: Z = 1 (Front/Bottom)
    % We only define the 4 corners using [1 cols] instead of 1:cols
    [x, y] = meshgrid([1 cols], [1 rows]);
    z = ones(2, 2); 
    c = im(:,:,1);
    surface(x, y, z, c, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 2: Z = End (Back/Top)
    z = ones(2, 2) * slices;
    c = im(:,:,end);
    surface(x, y, z, c, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 3: Y = 1 (Top edge)
    c_y1 = squeeze(im(1,:,:)); 
    [z_grid, x_grid] = meshgrid([1 slices], [1 cols]); 
    y_plane = ones(2, 2);
    surface(x_grid, y_plane, z_grid, c_y1, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 4: Y = End
    c_yEnd = squeeze(im(end,:,:));
    y_plane = ones(2, 2) * rows;
    surface(x_grid, y_plane, z_grid, c_yEnd, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 5: X = 1 (Left edge)
    c_x1 = squeeze(im(:,1,:));
    [z_grid, y_grid] = meshgrid([1 slices], [1 rows]);
    x_plane = ones(2, 2);
    surface(x_plane, y_grid, z_grid, c_x1, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 6: X = End
    c_xEnd = squeeze(im(:,end,:));
    x_plane = ones(2, 2) * cols;
    surface(x_plane, y_grid, z_grid, c_xEnd, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % ---------------------------------------------------------------------
    % Visual Styling
    xlim([1 cols]);
    ylim([1 rows]);
    zlim([1 slices]);
    view([45 30])

    % ---------------------------------------------------------------------
end