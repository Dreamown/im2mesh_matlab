function printBdf( nodecoor_list, ele_cell, precision )
% printBdf: print the nodes and elements into Inp file 'test.bdf'
% 4-node quadrilateral element
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Nov 2019
% Cite As:
%   Jiexian Ma (2023). pixelMesh (pixel-based mesh) (https://www.mathworks.
%   com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh), MATL
%   AB Central File Exchange. Retrieved January 12, 2023.
    
    num_node = size( nodecoor_list, 1 );
    
    % ------------------------------------------------------------------------
    % format of number
    % field width of node numbering
    width_node_num = 1 + floor( log10( num_node ) );         % 18964 -> 5
    if width_node_num > 16
        error('more than 16 digits')
    end
    
    num_digits_of_int_part = 1 + floor( log10( max(nodecoor_list(end,2:3)) ) );
                                                             % 182.9 -> 3
    if num_digits_of_int_part + precision + 1 > 16
        error('more than 16 digits')
    end
    format_node_coor = [ '%.', num2str( precision ), 'f' ];
                                                             % '%.(precision)f'
    
    % ------------------------------------------------------------------------
	fid=fopen('test.bdf','wW');
    % ------------------------------------------------------------------------
    fprintf( fid, 'BEGIN BULK\n');
    
    % print node
    % GRID*,3,,0.5000,2.5000,*
    % *,0.0
    fprintf( fid, ...
            [ 'GRID*,%d,,', format_node_coor, ',', format_node_coor, ',*\n', ...
            '*,', '0.0\n'], ...
            nodecoor_list' );

    % ------------------------------------------------------------------------
    % renumber global element numbering in ele_cell{i}(:,1)
    count = 0;
    for i = 1: size( ele_cell, 1 )
        ele_cell{i}(:,1) = (1:size(ele_cell{i},1))' + count;
        count = count + size(ele_cell{i},1);
    end

    % print element
    % CQUAD4*,5,1,40,46,*
    % *,17,11
    for i = 1: size( ele_cell, 1 )
        fprintf( fid, ...
            ['CQUAD4*,%d,%d,%d,%d', ',*\n', ...
             '*,', '%d,%d\n'], ...
            ele_cell{i}' );
    end
    
    % ------------------------------------------------------------------------
	fprintf( fid, 'ENDDATA' );
    
    % ------------------------------------------------------------------------
    fclose(fid);
	
	disp('printBdf Done! Check the bdf file!');
end
