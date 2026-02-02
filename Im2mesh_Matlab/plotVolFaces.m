function plotVolFaces( im )
% plotVolFaces: visualizes the outer surfaces of a 3D volume (3d array).
%
% Plots the 6 outer faces of the 3D array im onto a rectangular cuboid in 
% 3D space.
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    im = flip( flip(im, 1), 3 ); % FEM software use right-hand coordinate

    % Get dimensions (3D array)
    [rows, cols, slices] = size(im);

    % Prepare the figure
    % We use 'gcf' to use current figure or create one if none exists
    figure; 
    clf;
    hold on;
    axis equal;
    axis off; % Turn off axis lines, labels, and background
    view(3); % Set standard 3D view
    colormap('gray'); % X-ray CT style

    % ---------------------------------------------------------------------
    % Plot the 6 Faces
    % ---------------------------------------------------------------------
    % FACE 1: Z = 1 (Front/Bottom)
    % im(:,:,1) varies Y (rows) and X (cols)
    [x, y] = meshgrid(1:cols, 1:rows);
    z = ones(rows, cols); 
    c = im(:,:,1);
    surface(x, y, z, c, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 2: Z = End (Back/Top)
    % im(:,:,end)
    z = ones(rows, cols) * slices;
    c = im(:,:,end);
    surface(x, y, z, c, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 3: Y = 1 (Top edge)
    % im(1,:,:) fixes Y (row 1). Varies X (cols) and Z (slices).
    c_y1 = squeeze(im(1,:,:)); 
    % Mapping: rows of c_y1 are X, cols of c_y1 are Z
    [z_grid, x_grid] = meshgrid(1:slices, 1:cols); 
    y_plane = ones(cols, slices);
    surface(x_grid, y_plane, z_grid, c_y1, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 4: Y = End
    % im(end,:,:)
    c_yEnd = squeeze(im(end,:,:));
    y_plane = ones(cols, slices) * rows;
    surface(x_grid, y_plane, z_grid, c_yEnd, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 5: X = 1 (Left edge)
    % im(:,1,:) fixes X (col 1). Varies Y (rows) and Z (slices).
    c_x1 = squeeze(im(:,1,:));
    % Mapping: rows of c_x1 are Y, cols of c_x1 are Z
    [z_grid, y_grid] = meshgrid(1:slices, 1:rows);
    x_plane = ones(rows, slices);
    surface(x_plane, y_grid, z_grid, c_x1, 'EdgeColor', 'none', ...
        'FaceColor', 'texturemap', 'CDataMapping', 'scaled');

    % FACE 6: X = End
    % im(:,end,:)
    c_xEnd = squeeze(im(:,end,:));
    x_plane = ones(rows, slices) * cols;
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