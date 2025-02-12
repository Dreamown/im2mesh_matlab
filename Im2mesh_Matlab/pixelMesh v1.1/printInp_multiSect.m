function printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision )
% printInp_multiSect: print the nodes and elements into Inp file 'test.inp',
%          test in software abaqus
% 4-node quadrilateral element
% one part with multiple sections
%
% Revision history:
%   Jiexian Ma, mjx0799@gmail.com, Dec 2019
% Cite As:
%   Jiexian Ma (2023). pixelMesh (pixel-based mesh) (https://www.mathworks.
%   com/matlabcentral/fileexchange/104715-pixelmesh-pixel-based-mesh), MATL
%   AB Central File Exchange. Retrieved January 12, 2023.

	% format of Inp file
	% ------------------------------------------------------------------------
	% Heading
	%
	% Node
    %
    % Element
    %
    % Section
    % ------------------------------------------------------------------------
	
    num_sect = length( ele_cell );
    sect_ascii = 65: ( 65 + num_sect - 1);
    sect_char = char( sect_ascii );     % 'ABCD...'
    
    % format of number
    % '%.(precision)f'
    format_node_coor = [ '%.', num2str( precision ), 'f' ];
    
    % ------------------------------------------------------------------------
	fid=fopen('test.inp','wW');
    % ------------------------------------------------------------------------
	% Heading
    fprintf( fid, [...
        '*Heading'                                              '\n'...
        '*Preprint, echo=NO, model=NO, history=NO, contact=NO'  '\n'...
        '**'                                                    '\n'...
        ] );
    
	% ------------------------------------------------------------------------
    % Node
    fprintf( fid, '*Node\n' );
    
    % print coordinates of nodes
    % '%d,%.4f,%.4f\n'
    fprintf( fid, ...
        [ '%d,', format_node_coor, ',', ...
                 format_node_coor, '\n'], ...
        nodecoor_list' );
    
    % ------------------------------------------------------------------------
    % Element
    for i = 1: num_sect
        fprintf( fid, [...
            '*Element, type=%s, elset=Set-%c'  '\n'...
            ], ele_type, sect_char(i) );
        
        % fprintf( fid, '%d,%d,%d,%d,%d\n', ele_cell{i}' );
        printEle( fid, ele_cell{i}(:,[1 3:6]) );
    end
    
    % ------------------------------------------------------------------------
    % Section
    for i = 1: num_sect
        fprintf( fid, [...
            '** Section: Section-%c'            '\n'...
            '*Solid Section, elset=Set-%c, material=Material-%c'  '\n'...
            ','                                 '\n'...
            ], ...
            sect_char(i), ...
            sect_char(i), sect_char(i) ...
            );
    end
    
	fprintf( fid, '**' );
    
    % ------------------------------------------------------------------------
    fclose(fid);
	
	disp('printInp Done! Check the inp file!');
end


function printEle( fid, ele )
% work for linear element
    
    % fprintf( fid, '%d,%d,%d,%d,%d\n', ele' );
    fprintf( fid, ...
        [ repmat('%d,', [1,4]), '%d', '\n' ], ...
        ele' );
    
end