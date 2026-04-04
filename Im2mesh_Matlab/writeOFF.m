function writeOFF(filename, V, F)
% writeOFF: Export shared-vertex mesh to Object File Format (.off)
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot create OFF file.');
    end

    fprintf(fid, 'OFF\n');
    fprintf(fid, '%d %d 0\n', size(V,1), size(F,1));
    
    % Write Vertices
    fprintf(fid, '%f %f %f\n', V');

    % Write Faces (prefix with 3 for triangles, 0-based indexing)
    fprintf(fid, '3 %d %d %d\n', (F - 1)'); 

    fclose(fid);

    disp('//////////////// writeOFF Done! ////////////////');
end