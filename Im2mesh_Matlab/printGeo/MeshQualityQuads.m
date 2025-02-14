function [q,theta] = MeshQualityQuads(EToV,VX,VY)
% function [q] = MeshQualityQuads(EToV,VX,VY)
%
% Purpose: Assess the quadrilateral mesh quality using a mesh quality 
%          indicator
%
%          q = prod(1-abs((pi/2 - angles)/(pi/2)))
%
%          where angles are the interior angles of the quadrilateral.
%
%          0<=q<=1 where q=1 for rectangles (good quality) and
%          q=0 for quadrilaterals with triangular shape (four
%          unique vertices assumed).
%
%          Function is useful for detecting quadrilaterals that 
%          degenerate to triangles.
%
%          Function assumes that the quadrilaterals are ordered
%          anti-clockwise.
%   
%          EToV : Element-To-Vertice table
%          VX   : x-table for vertices
%          VY   : y-table for vertices
%
% By Allan P. Engsig-Karup, apek@dtu.dk.

    K      = size(EToV,1);
    Nfaces = size(EToV,2);
    
    % Create face vectors
    fx = VX(EToV(:,[2 3 4 1])) - VX(EToV(:,[1 2 3 4]));
    fy = VY(EToV(:,[2 3 4 1])) - VY(EToV(:,[1 2 3 4]));
    
    % Compute interior angles for each element
    theta = EToV*0;
    for k = 1 : K
        for n = 1 : Nfaces
            a = [fx(k,n); fy(k,n) ]; % face n
            b = [fx(k,mod(n,4)+1); fy(k,mod(n,4)+1) ]; % face before n
            costheta = dot(a,b)/(norm(a)*norm(b));
            theta(k,n) = acos(costheta);
        end
    end
    q = prod(1-abs((pi/2 - theta)/(pi/2)),2);
    
    % statistics
    N = 100; 
    x = linspace(0,1,N+1);
    dx = x(2)-x(1);
    subdivision = x(1:N)+dx/2;
    count = zeros(1,N);
    K = size(EToV,1);
    for i = 1 : length(subdivision)
        count(i) = length(find(q>subdivision(i)-dx/2 & q<=subdivision(i)+dx/2))/K*100;
    end
    
    % visualize
    figure
    bar(subdivision,count,1)
    minlimit = find(q<0.3, 1);
    if isempty(minlimit)
        axis([0.3 1 -1 max(count)*1.05])
    else
        axis([min(q) 1 -1 max(count)*1.05])
        hold on
        plot([0.3 0.3],[0 100],'r--')
    end
    xlabel('Quadrilateral Mesh quality')
    ylabel('Percentage of elements')
    colormap(cool)
    
%     % visualize location of bad elements
%     figure
%     idx = q<0.3;
%     quadplot(EToV,VX,VY,'k')
%     hold on
%     quadplot(EToV(idx,:),VX,VY,'r')
%     axis equal
%     axis off
%     return
end