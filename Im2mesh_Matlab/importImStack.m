function im = importImStack( file_name )
% importImStack: import a 3d image stack
% input -  file_name is a string
% 
% example: 
%         file_name = 'test_stacked_image.tif';
%         im = importImStack( file_name );
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    info_image = imfinfo( file_name );
    num_file = length( info_image );
    
    % initialize
    temp = imread( file_name, 'Index', 1 );
    im = zeros( size(temp,1), size(temp,2), num_file, 'uint8');

    % import into im
    for i = 1: num_file
       im(:,:,i) = imread( file_name, 'Index', i );
    end

end

