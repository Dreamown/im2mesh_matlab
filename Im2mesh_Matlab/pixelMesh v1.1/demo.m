function demo()
% demo of pixelMesh: Convert 2d multi-phase image to pixel-based finite 
%                    element mesh (4-node quadrilateral element)
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, July 2021
% Cite As:
%   Jiexian Ma (2023). pixelMesh (pixel-based mesh) (https://www.mathworks.
%   com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh), MATL
%   AB Central File Exchange. Retrieved January 12, 2023.


    % ---------------------------------------------------------------------
    % import image
    file_name = 'im.tif';   % grayscale or rgb image
    im_o = imread( file_name );

    % convert rgb image to grayscale image
    if size(im_o,3) == 3
        im_o = rgb2gray( im_o );
    end

    % image segmentation using Otsu's method
    num_level = 4;      % How many phases in your image. 
                        % The value of this parameter is chose by you.
    thresh = multithresh( im_o, num_level-1 );
    seg_im = imquantize( im_o, thresh );
    im = uint8( 255 * mat2gray(seg_im) );

    % imshow(im);

    % ---------------------------------------------------------------------
    % parameters
    dx = 1; dy = 1;         % scale of image 
                            % dx - column direction, dy - row direction,
                            % e.g. scale of your imgage is 0.11 mm/pixel, try
                            %      dx = 0.11; and dy = 0.11;

    ele_type = 'CPS4';      % element type, for printInp_multiSect
    precision_nodecoor = 8; % precision of node coordinates, for output

    % ---------------------------------------------------------------------
    % preprocess
    im = flip(im,1);	% in FEM software using right-hand coordinate, 
                        % to coincide with that, must flip in row direction
                        % so the origin of coordinates is at bottom-left

    num_row = size( im, 1 );
    num_col = size( im, 2 );

    % get unique intensities from image
    intensity = unique( im );     % column vector

    % ---------------------------------------------------------------------
    % get numbering of 4 nodes in each element
    % get list of node coordinates
    % ele_cell{i}(j,:) = [ element_number, phase_number, node_number_of_4_nodes ]
    % nodecoor_list(i,:) = [ node_number, x, y ]

    [ nodecoor_list, ele_cell ] = pixelMesh( im, intensity, num_col, num_row );
 
    % ---------------------------------------------------------------------
    % export as inp file or bdf file
    % scale nodecoor_list using dx, dy
    nodecoor_list( :, 2 ) = nodecoor_list( :, 2 ) * dx;
    nodecoor_list( :, 3 ) = nodecoor_list( :, 3 ) * dy;

    % generate inp file
    % export multi-phases in image as multi-sections in inp file
    printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision_nodecoor );

    % generate bdf file
    printBdf( nodecoor_list, ele_cell, precision_nodecoor );

end





