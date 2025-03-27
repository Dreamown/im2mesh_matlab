function percent_pixel = getPixelPercent( im )
% getPixelPercent: calculate the area perccentage of each grayscale in image
% 
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)

    intensity = unique( im );    % column vector
    num_phase = size( intensity, 1 );
    num_pixel = zeros( num_phase, 1);           % number of pixels
    percent_pixel = zeros( num_phase, 1);       % ratio of pixels
    
    % num_pixel(i) - number of pixels in the i-th phase
    for i = 1: num_phase
        num_pixel(i) = nnz( im == intensity(i) );
    end
    
    % percent_pixel(i) - percent of pixel area for the i-th phase
    for i = 1: num_phase
        percent_pixel(i) = 100* num_pixel(i) / sum(num_pixel);
    end

end