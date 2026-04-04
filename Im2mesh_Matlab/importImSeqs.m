function im = importImSeqs( folder )
% importImSeqs: import 2d image sequences
% input -  folder is a string
%
% example:
%     folder_name = 'test_image_sequences';
%     im = importImSeqs( folder_name );
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    file_struct = dir( folder );

    % delete some trivial infomation in file_struct
    mark = false( length(file_struct), 1 );
    for i = 1:length(file_struct)
       if file_struct(i).bytes < 10
           mark(i) = true;
       end
    end
    file_struct( mark ) = [];

    % import into im one by one
    num_file = length(file_struct);
    temp = imread( fullfile( folder, file_struct(1).name) );
    im = zeros( size(temp,1), size(temp,2), num_file, 'uint8');
    
    for i = 1 : num_file
        im(:,:,i) = imread( fullfile( folder, file_struct(i).name) );
    end

end

