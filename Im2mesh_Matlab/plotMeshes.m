function plotMeshes( vert, tria, tnum )
% show meshes
% input:
% output:
%   verrt - Node data. N-by-2 array.
%       vert(i,1:2) = [x_coordinate, y_coordinate] of the i-th node
%
%   tria - Node numbering for each triangle. M-by-3 array.
%       tria(j,1:3) = [node_numbering_of_3_nodes] of the j-th element
%
%   tnum - Label of material phase. P-by-1 array.
%       tnum(j,1) = k; means the j-th element is belong to the k-th phase
%

    figure;
    hold on; 
    axis image off;

    tvalue = unique( tnum );
    num_phase = length( tvalue );
    
    % setup color
    if num_phase == 1
        col = 0.98;
    elseif num_phase > 1
        col = 0.3: 0.68/(num_phase-1): 0.98;
    else
        error("num_phase < 1")
    end
    
    for i = 1: num_phase
        phasecode = tvalue(i);
        patch('faces',tria( tnum==phasecode, 1:3 ),'vertices',vert, ...
        'facecolor',[ col(i), col(i), col(i) ], ...
        'edgecolor',[.1,.1,.1]);
    end
    hold off
    
%     drawnow;
%     set(figure(1),'units','normalized', ...
%         'position',[.05,.50,.30,.35]) ;
end

