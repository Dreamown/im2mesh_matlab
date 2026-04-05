function [nodes, elements] = readMsh( filename )
% readMsh: Reads a Gmsh .msh file (Format 2.2) and extracts nodes/elements.
% Only works for tetrahedral mesh with one phase.
%
% Usage:
%   [vert, ele] = readMsh('mesh.msh');
%
% Inputs:
%   filename - String containing the path to the .msh file
%
% Outputs:
%   nodes    - [N x 3] matrix containing the x, y, z coordinates of the nodes
%   elements - [E x 4] matrix containing the node indices of the tetrahedrons
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % Open the file for reading
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Initialize empty arrays
    nodes = [];
    elements = [];

    % Read file line by line
    while ~feof(fid)
        line = strtrim(fgetl(fid));

        % Parse Nodes
        if strcmp(line, '$Nodes')
            % Read the total number of nodes
            numNodes = fscanf(fid, '%d', 1);
            
            % Read all node data.
            % Format: node_id x_coord y_coord z_coord
            % fscanf reads column-wise, so we read 4 rows and transpose it.
            nodeData = fscanf(fid, '%f', [4, numNodes])';
            
            % Extract just the coordinates (columns 2, 3, and 4)
            nodes = nodeData(:, 2:4);

        % Parse Elements
        elseif strcmp(line, '$Elements')
            % Read the total number of elements
            numElements = fscanf(fid, '%d', 1);
            fgetl(fid); % Consume the newline character after the number

            % Preallocate maximum possible size for tetrahedral elements
            % (Assuming every element could be a tetrahedron to save memory reallocation time)
            elements = zeros(numElements, 4);
            tetCount = 0;

            % Process each element line
            for i = 1:numElements
                lineStr = strtrim(fgetl(fid));
                if isempty(lineStr)
                    continue;
                end

                % Read numbers from the line
                vals = sscanf(lineStr, '%f'); 
                
                if length(vals) >= 4
                    % Gmsh element format: 
                    % elm-number elm-type number-of-tags < tag 1 > ... < tag n > node-number-list
                    elm_type = vals(2);
                    
                    % elm_type == 4 refers to a 4-node tetrahedron
                    if elm_type == 4 
                        num_tags = vals(3);
                        % Calculate where the node indices begin
                        nodes_start = 4 + num_tags; 
                        
                        tetCount = tetCount + 1;
                        % Extract the 4 node IDs for the tetrahedron
                        elements(tetCount, :) = vals(nodes_start : nodes_start + 3)';
                    end
                end
            end
            
            % Trim the preallocated array down to the actual number of tetrahedrons found
            elements = elements(1:tetCount, :);

        % Stop Reading at Element Data
        elseif strcmp(line, '$ElementData')
            % Stop parsing to ignore everything that follows
            break;
        end
    end

    fclose(fid);
    
    fprintf('Loaded %d nodes and %d elements.\n', size(nodes, 1), size(elements, 1));
end