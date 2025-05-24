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






