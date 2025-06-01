function printDxf( bounds, file_name )
% printDxf: print bounds to dxf files
%
% Multiple dxf files will be created depending on the number of phases in
% the 'bounds'. 
% For example, the length of 'bounds' is 4, meaning total 4
% phases in 'bounds'. 5 dxf files will be created. One dxf file is for all
% the phases, with different phases storing in different draw layer. The
% other 4 dxf files are for each phase in 'bounds'.
%
% input:
%   bounds - A nested cell array of 2d polygonal boundaries.
%            Polygons in bounds{i} belong to the i-th part or phase.
%            bounds{i}{j} is one of the polygons in the i-th part.
%            bounds{i}{j} is a n-by-2 array for x y coordinates of vertices
%            in a polygon. You can use 
%            plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%            polygon. Use plotBounds( bounds ) to view all polygons.
%
%   filename - The name of the DXF file to create (e.g., 'a.dxf').
%
%
% Copyright (C) 2019-2025 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % ---------------------------------------------------------------------
    % Export bounds to a dxf file. 
    % bounds{i} is in the i-th layer of the dxf file

    nestPolyCell2dxf( bounds, file_name );
    
    % ---------------------------------------------------------------------
    % Export bounds to multiple dxf files. 
    % bounds{i} is in the i-th dxf file.

    num_layers = length(bounds);

    for i = 1: num_layers
        layer_name = sprintf('Layer_%d', i);

        [ filepath, name, ext ] = fileparts( file_name );
        
        if ~isempty(filepath)
            layer_filename = [ filepath, filesep, name, '_',  layer_name, ext ];
        else
            layer_filename = [ name, '_',  layer_name, ext ];
        end
        
        polyCell2dxf( bounds{i}, layer_filename, layer_name );
    end

	disp('printDxf Done! Check the dxf file!');
    % ---------------------------------------------------------------------
end

function nestPolyCell2dxf( C, filename )
% nestPolyCell2dxf: Exports a nested cell array of 2D polylines to 
% different layers of a dxf file.
% The length of the nested cell array equals to the number of layer in the
% dxf file.
% Using LINE entities on a specified layer.
%
% inputs:
%   C - A p-by-1 cell array (p >= 1). C{i} is a non-empty q-by-1 cell array
%       (q >= 1). C{i}{j} is an n-by-2 numeric matrix [x, y] (n >= 2) for a
%       2d polyline.
%       Polylines in C{i} are written into the i-th layer of the dxf file. 
%
%   filename - The name of the DXF file to create (e.g., 'c.dxf').
%
% example:
%   poly1 = [0 0; 10 0; 10 10; 0 10; 0 0];
%   poly2 = [2 2; 8 2; 5 8; 2 2];
%   layer1 = {poly1; poly2};
% 
%   poly3 = [12 0; 15 0; 13.5 5; 12 0];
%   layer2 = {poly3};
% 
%   C = {layer1; layer2};
%   nestPolyCell2dxf(C, 'layers.dxf');
%

    % ---------------------------------------------------------------------
    if nargin < 2
        error('Not enough input arguments.');
    end

    % Basic check for C itself: must be a cell array and non-empty
    if ~iscell(C) || isempty(C)
        error('Input C must be a non-empty cell array as per assumptions.');
    end

    if ~ischar(filename) && ~isstring(filename)
        error('Filename must be a character array or a string.');
    end

    % ---------------------------------------------------------------------
    fid = fopen(filename, 'wW');

    % Header Section
    fprintf(fid, '0\nSECTION\n');
    fprintf(fid, '2\nHEADER\n');
    fprintf(fid, '9\n$ACADVER\n');
    fprintf(fid, '1\nAC1009\n');    % AutoCAD R12/LT2 DXF version
    fprintf(fid, '0\nENDSEC\n');

    % Tables Section (Layer Definitions)
    fprintf(fid, '0\nSECTION\n');
    fprintf(fid, '2\nTABLES\n');
    fprintf(fid, '0\nTABLE\n');
    fprintf(fid, '2\nLAYER\n');

    num_layers = length(C);               
    fprintf(fid, '70\n%d\n', num_layers);   % Total number of layer entries

    layer_name_cell = cell(num_layers, 1);

    for i = 1:num_layers
        layer_name = sprintf('Layer_%d', i);
        layer_name_cell{i} = layer_name;
        
        % Assign colors by cycling (1=Red, 2=Yellow, ..., 7=White/Black)
        color_index = mod(i - 1, 7) + 1;

        fprintf(fid, '0\nLAYER\n');
        fprintf(fid, '2\n%s\n', layer_name);      % Layer name
        fprintf(fid, '70\n0\n');                  % Layer flags
        fprintf(fid, '62\n%d\n', color_index);    % Color number
        fprintf(fid, '6\nCONTINUOUS\n');          % Linetype name
    end

    fprintf(fid, '0\nENDTAB\n');
    fprintf(fid, '0\nENDSEC\n');
    
    % Entities Section
    fprintf(fid, '0\nSECTION\n');
    fprintf(fid, '2\nENTITIES\n');

    for i = 1:num_layers                        % Corresponds to C{i}
        current_layer_name = layer_name_cell{i};

        polys_in_layer = C{i};
        
        for j = 1:length(polys_in_layer)        % Corresponds to C{i}{j}
            poly = polys_in_layer{j};
            
            % Loop through segments of the current polyline
            for k_seg = 1:(size(poly, 1) - 1)
                x1 = poly(k_seg, 1);
                y1 = poly(k_seg, 2);
                x2 = poly(k_seg+1, 1);
                y2 = poly(k_seg+1, 2);
                
                fprintf(fid, '0\nLINE\n');
                fprintf(fid, '8\n%s\n', current_layer_name);
                
                % Start point
                fprintf(fid, '10\n%.4f\n', x1);
                fprintf(fid, '20\n%.4f\n', y1);
                fprintf(fid, '30\n0.0\n');      % Z=0
                % End point
                fprintf(fid, '11\n%.4f\n', x2);
                fprintf(fid, '21\n%.4f\n', y2);
                fprintf(fid, '31\n0.0\n');      % Z=0
            end
        end
    end
    
    fprintf(fid, '0\nENDSEC\n');
    
    % End of File
    fprintf(fid, '0\nEOF\n');
    
    fclose(fid);
    % ---------------------------------------------------------------------
end

function polyCell2dxf( pCell, file_name, layer_name )
% polyCell2dxf: export a cell array polylines to a DXF file.
% Using LINE entities on a specified layer.
%
% inputs:
%   pCell - A cell array where each cell contains an N-by-2
%           matrix representing a 2d polyline. N is the number
%           of vertices for that polyline. Each row is (x, y).
%
%   file_name - The name of the DXF file to create (e.g., 'poly.dxf').
%
%   layer_name - A string specifying the name of the layer.
%                (e.g., '1', '0', 'data')
%
% example:
%   % Define sample polylines
%   poly1 = [0 0; 10 0; 10 10; 0 10; 0 0];  % A square
%   poly2 = [12 2; 15 2; 13.5 5; 12 2];     % A triangle
% 
%   % Create a cell array of these polylines
%   pCell = {poly1, poly2};
% 
%   % Export to a layer named 'test'
%   polyCell2dxf(pCell, 'shapes.dxf', 'test');
%
%   % Export to the default layer '0'
%   polyCell2dxf(pCell, 'shapes_0.dxf', '0');
%
%

    % ---------------------------------------------------------------------
    % check input

    if nargin < 3
        error('Not enough input arguments');
    end
    
    if ~iscell(pCell)
        error('First input must be a cell array.');
    end

    if ~ischar(file_name) && ~isstring(file_name)
        error('Second input must be a character array or a string.');
    end

    if ~ischar(layer_name) && ~isstring(layer_name) || isempty(strtrim(layer_name))
        error('Third input must be a non-empty character array or string.');
    end

    % ---------------------------------------------------------------------
    fid = fopen(file_name, 'wW');

    % Header Section
    fprintf(fid, '0\nSECTION\n');
    fprintf(fid, '2\nHEADER\n');
    fprintf(fid, '9\n$ACADVER\n');
    fprintf(fid, '1\nAC1009\n');    % AutoCAD R12/LT2 DXF version
    fprintf(fid, '0\nENDSEC\n');

    % Tables Section (defining the specified layer)
    fprintf(fid, '0\nSECTION\n');
    fprintf(fid, '2\nTABLES\n');
    fprintf(fid, '0\nTABLE\n');
    fprintf(fid, '2\nLAYER\n');

    % For simplicity, we define 1 layer entry here.
    % If layer_name is '0', this defines layer '0'.
    % If it's another name, it defines that layer.

    fprintf(fid, '70\n1\n');      % Number of layer table entries to follow
    
    % Specified layer definition
    fprintf(fid, '0\nLAYER\n');
    fprintf(fid, '2\n%s\n', layer_name);  % Layer name from input
    fprintf(fid, '70\n0\n');          % Layer flags (0 = on, thawed, not locked, etc.)
    fprintf(fid, '62\n7\n');          % Color number (7 = white/black by default).
    
    fprintf(fid, '6\nCONTINUOUS\n');  % Linetype name (default 'CONTINUOUS')
    fprintf(fid, '0\nENDTAB\n');
    fprintf(fid, '0\nENDSEC\n');
    
    % Entities Section
    fprintf(fid, '0\nSECTION\n');
    fprintf(fid, '2\nENTITIES\n');

    num_poly_written = 0;

    % Loop through each polyline in the cell array
    for k = 1:length(pCell)
        current_poly = pCell{k};

        if isempty(current_poly)
            % Skip empty polyline
            continue;
        end

        if ~ismatrix(current_poly) || size(current_poly, 2) ~= 2
            % Skip non-valid data size
            continue;
        end

        if size(current_poly, 1) < 2
            % Skip non-valid data size
            continue;
        end

        % Loop through the segments of the current polyline
        for i = 1:(size(current_poly, 1) - 1)
            % Start point of the line segment
            x1 = current_poly(i, 1);
            y1 = current_poly(i, 2);
            % End point of the line segment
            x2 = current_poly(i+1, 1);
            y2 = current_poly(i+1, 2);

            fprintf(fid, '0\nLINE\n');           % Entity type
            fprintf(fid, '8\n%s\n', layer_name); % Layer name from input
            % Start point
            fprintf(fid, '10\n%.4f\n', x1); % X
            fprintf(fid, '20\n%.4f\n', y1); % Y
            fprintf(fid, '30\n0.0\n');      % Z=0
            % End point
            fprintf(fid, '11\n%.4f\n', x2); % X
            fprintf(fid, '21\n%.4f\n', y2); % Y
            fprintf(fid, '31\n0.0\n');      % Z=0
        end
        num_poly_written = num_poly_written + 1;
    end

    fprintf(fid, '0\nENDSEC\n');

    % End of File
    fprintf(fid, '0\nEOF\n');

    fclose(fid);
    % ---------------------------------------------------------------------
end





