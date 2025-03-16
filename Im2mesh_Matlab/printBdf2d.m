function printBdf2d( vert, tria, tnum, precision_nodecoor, path_file_name )
% printBdf2d: write finite element mesh (nodes and elements) into Bdf file 'test.bdf'
%
% usage:
%   printBdf( nodecoor_list, ele_cell, precision_nodecoor );
%   % OR
%   path_file_name = 'C:\Downloads\aaa.bdf';
%   printBdf( nodecoor_list, ele_cell, precision_nodecoor, path_file_name);
%
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    
    % ------------------------------------------------------------------------
    % check the number of inputs
    if nargin == 4
        % write to current folder
        path_file_name = 'test.bdf';
    elseif nargin == 5
        % write to the specified file directory, e.g. 'C:\test.bdf'
    else
        error("check the number of inputs");
    end

    % ------------------------------------------------------------------------
    % Add node numbering and element numbering, and organize elements into 
    % cell array. eleC{i} represent elements in the i-th phase.

    [nodecoor, ~, eleC] = getNodeEle( vert, tria, tnum );

    % ------------------------------------------------------------------------
    numNode = size( nodecoor, 1 );

    % ------------------------------------------------------------------------
    % format of number
    
    % field width of node numbering
    width_node_num = 1 + floor( log10( numNode ) );         % 18964 -> 5
    if width_node_num > 16
        error('more than 16 digits')
    end
    
    num_digits_of_int_part = 1 + floor( log10( max(nodecoor(end,2:3)) ) );
                                                             % 182.9 -> 3
    if num_digits_of_int_part + precision_nodecoor + 1 > 16
        error('more than 16 digits')
    end
    
    % format_node_coor
    % '%.(precision)f'
    fmNodeCo = [ '%.', num2str( precision_nodecoor ), 'f' ];                                           
    
    % ------------------------------------------------------------------------
	fid=fopen( path_file_name, 'wW' );
    % ------------------------------------------------------------------------
    fprintf( fid, 'BEGIN BULK\n');
    
    % print node
    % GRID*,3,,0.5000,2.5000
    fprintf( fid, ...
            [ 'GRID*,%d,,', fmNodeCo, ',', fmNodeCo, '\n'], ...
            nodecoor' ...
            );

    % ------------------------------------------------------------------------
    % renumber global element numbering in eleC{i}(:,1)
    num_phase = length( eleC );
    count = 0;
    for i = 1: num_phase
        eleC{i}(:,1) = (1:size(eleC{i},1))' + count;
        count = count + size(eleC{i},1);
    end

    % ------------------------------------------------------------------------
    % print element
    ele_wid =  size( eleC{1}, 2 );
    
    if ele_wid == 4
        % linear triangular element
        % CHEXA*,5,1,40,46,*
        % *,47

        for i = 1: num_phase
            fprintf( fid, ...
                ['CTRIA3*,%d,%d,%d,%d', ',*\n', ...
                 '*,', '%d\n'], ...
                [ eleC{i}(:,1), i * ones(size(eleC{i},1),1), eleC{i}(:,2:4) ]' ...
                );
        end
        
    elseif ele_wid == 5
        % linear quadrilateral element
        % CQUAD4*,5,1,40,46,*
        % *,17,11

        for i = 1: num_phase
            fprintf( fid, ...
                [ 'CQUAD4*,%d,%d,%d,%d', ',*\n', ...
                 '*,', '%d,%d\n' ], ...
                [ eleC{i}(:,1), i * ones(size(eleC{i},1),1), eleC{i}(:,2:5) ]' ...
                );
        end
    else
        error('Function printBdf2d only supports linear element.');
    end
    
    % ------------------------------------------------------------------------
	fprintf( fid, 'ENDDATA' );
    
    % ------------------------------------------------------------------------
    fclose(fid);
	
	disp('printBdf2d Done! Check the bdf file!');
    % ------------------------------------------------------------------------
end
