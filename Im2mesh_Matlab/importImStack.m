function im = importImStack( file_name )
% importImStack: import a 3d image stack
% input -  file_name is a string
% 
% example: 
%         file_name = 'test_stacked_image.tif';
%         im = importImStack( file_name );
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

