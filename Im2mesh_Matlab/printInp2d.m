function printInp2d( vert, tria, tnum, ele_type, precision_nodecoor, path_file_name )
% printInp2d: write 2d finite element mesh (nodes and elements) into inp 
%           file ('test.inp'). Test in software Abaqus. 
%           One part with multiple sections. 
%           Each phase corresponds to one section in Abaqus.
%           Works for linear and quadratic element.
%           Works for triangular and quadrilateral element.
%
% usage:
%   printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision_nodecoor );
%   % OR
%   path_file_name = 'C:\Downloads\aaa.bdf';
%   printInp_multiSect( nodecoor_list, ele_cell, ele_type, precision_nodecoor, path_file_name );
%
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%


	% format of Inp file
	% ------------------------------------------------------------------------
	% Heading
	%
	% Node
    %
    % Element
    %
    % Section
    %
    % ------------------------------------------------------------------------

    % ------------------------------------------------------------------------
    % check the number of inputs
    if nargin == 5
        % write to current folder
        path_file_name = 'test.inp';
    elseif nargin == 6
        % write to the specified file directory, e.g. 'C:\test.inp'
    else
        error("check the number of inputs");
    end
    
    % ------------------------------------------------------------------------
    % Add node numbering and element numbering, and organize elements into 
    % cell array. eleC{i} represent elements in the i-th phase.
    
    [ nodecoor, ~, eleC ] = getNodeEle( vert, tria, tnum );

    % ------------------------------------------------------------------------
    % convert number 1 2 3 to character A B C
    num_sect = length( eleC );
    sect_ascii = 65: ( 65 + num_sect - 1);
    sect_char = char( sect_ascii );     % 'ABCD...'
    
    % ------------------------------------------------------------------------
    % format of number

    % format_node_coor
    % '%.(precision)f'
    fmNodeCo = [ '%.', num2str( precision_nodecoor ), 'f' ];    
    
    fmNodeNum = '%d';     % format_node_num
    fmEleNum = '%d';      % format_ele_num
    
    % ------------------------------------------------------------------------
	fid=fopen(path_file_name,'wW');
    % ------------------------------------------------------------------------
	% Heading
    fprintf( fid, [...
        '*Heading'                                              '\n'...
        '*Preprint, echo=NO, model=NO, history=NO, contact=NO'  '\n'...
        '**'                                                    '\n'...
        ] ...
        );
    
	% ------------------------------------------------------------------------
    % Node
    fprintf( fid, '*Node\n' );
    
    % print coordinates of nodes
    % example:
    % 3,4.69000000,23.82000000
    %
    % '%d,%.4f,%.4f,%.4f\n'
    
    fprintf( fid, ...
        [ ...
        fmNodeNum, ',', fmNodeCo, ',', fmNodeCo, '\n' ...
        ], ...
        nodecoor' ...
        );
    
    % ------------------------------------------------------------------------
    % Element
    
    for i = 1: num_sect
        % example:
        % *Element, type=CPS3, elset=Set-A
        fprintf( fid, [...
            '*Element, type=%s, elset=Set-%c'  '\n'...
            ], ele_type, sect_char(i) );
        
        % example:
        % 3,173,400,475     % linear tria element
        % 87,428,584,561,866,867,868    % quadratic tria element

        printEle( fid, eleC{i}, fmEleNum, fmNodeNum );
    end
    
    % ------------------------------------------------------------------------
    % Section

    for i = 1: num_sect
        % example:
        % ** Section: Section-A
        % *Solid Section, elset=Set-A, material=Material-A
        % ,

        fprintf( fid, [...
            '** Section: Section-%c'            '\n'...
            '*Solid Section, elset=Set-%c, material=Material-%c'  '\n'...
            ','                                 '\n'...
            ], ...
            sect_char(i), ...
            sect_char(i), sect_char(i) );
    end
    
	fprintf( fid, '**' );
    
    % ------------------------------------------------------------------------
    fclose(fid);
	
	disp('printInp2d Done! Check the inp file!');
    % ------------------------------------------------------------------------
end

function printEle( fid, ele, format_ele_num, format_node_num )
% work for linear element and quadratic element

    num_column = size( ele, 2 );

    % fprintf( fid, '%d,%d,%d,%d,%d\n', ele' );
    % example:
    % 3,173,400,475                 % linear tria element
    % 87,428,584,561,866,867,868    % quadratic tria element

    fprintf( fid, ...
        [   format_ele_num, ',', ...
            repmat([format_node_num, ','], [1,num_column-2]), ...
            format_node_num, '\n' ...
        ], ...
        ele' ...
        );
end

% % old version
% function printEle( fid, ele, format_ele_num, format_node_num )
% % work for linear element and quadratic element
% 
%     num_column = size( ele, 2 );
% 
%     switch num_column
%         case 4
%             % linear element
%             % example:
%             % 3,173,400,475
%             fprintf( fid, ...
%                 [   format_ele_num, ',', ...
%                     repmat([format_node_num, ','], [1,2]), ...
%                     format_node_num, '\n' ...
%                 ], ...
%                 ele' ...
%                 );
%             
%         case 7
%             % quadratic element
%             % example:
%             % 87,428,584,561,866,867,868
%             fprintf( fid, ...
%                 [   format_ele_num, ',', ...
%                     repmat([format_node_num, ','], [1,5]), ...
%                     format_node_num, '\n' ...
%                 ], ...
%                 ele' ...
%                 );
%             
%         otherwise
%             disp('unidentified data')
%     end
% 
% end
