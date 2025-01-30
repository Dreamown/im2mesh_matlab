function [ node_cell, edge_cell ] = getPolyNodeEdge( bounds )
% get nodes and edges of polygonal boundary
%
% input:
%   bounds - cell array. bounds{i}{j} is one of the polygonal boundaries,  
%          corresponding to region with certain gray level in image im.
%          Polygons in bounds{i} have the same grayscale level.
%          bounds{i}{j}(:,1) is x coordinate (column direction).
%          bounds{i}{j}(:,2) is y coordinate (row direction). You can use
%          plot( bounds{i}{j}(:,1), bounds{i}{j}(:,2) ) to view the
%          polygon. Use plotBounds( bounds ) to view all polygons, check
%          plotBounds.m.
%   bounds{i} is boundary polygons for the i-th phase
%
% output:
%   node_cell, edge_cell - cell array, nodes and edges of polygonal boundary
%   node_cell{i}, edge_cell{i} corresponds to polygons in bounds{i}.
%   node_cell{i} - N-by-2 array. x,y coordinates of vertices in polygon.
%                  Each row is one vertex.
%   edge_cell{i} - M-by-2 array. Node numbering of two connecting vertices
%                  in polygon. Each row is one edge.
%
% Author:
%   Jiexian Ma, mjx0799@gmail.com, Jan 2025
% Cite As
%   Jiexian Ma (2025). Im2mesh (2D image to triangular meshes) (https://ww
%   w.mathworks.com/matlabcentral/fileexchange/71772-im2mesh-2d-image-to-t
%   riangular-meshes), MATLAB Central File Exchange. Retrieved Jan 23, 202
%   5.


    node_cell = cell( 1, length(bounds) );
    edge_cell = cell( 1, length(bounds) );
    
    for i = 1: length(bounds)
        % node_mulpoly and edge_mulpoly store multiple polygons in one phase
        node_mulpoly = [];
        edge_mulpoly = [];
        
        for j = 1:length(bounds{i})
            if isequal( bounds{i}{j}(1,:), bounds{i}{j}(end,:) )
                % node_temp and edge_temp store one polygon
                node_temp = bounds{i}{j}( 1:end-1, : );
                edge_temp = zeros( length(node_temp), 2 );
                
                for k = 1:length(node_temp)
                    edge_temp(k,:) = [ k, k+1 ];
                end
                edge_temp( end, 2 ) = 1;

                [ node_mulpoly, edge_mulpoly ] = joinNodeEdge( ...
                        node_mulpoly,edge_mulpoly, node_temp,edge_temp );
            else
                error('polygon not close')
            end
        end
        node_cell{i} = node_mulpoly;
        edge_cell{i} = edge_mulpoly;
    end
end