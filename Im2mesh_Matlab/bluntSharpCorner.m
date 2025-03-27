function new_bounds = bluntSharpCorner( boundsCtrlP )
% bluntSharpCorner: blunt sharp corners
%
% Im2mesh is copyright (C) 2019-2025 by Jiexian Ma and is distributed under
% the terms of the GNU General Public License (version 3).
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % Search and record sharp corner in boundary in boundsCtrlP
    % Return a cell array with x y coordinates
    pntSharpC = findSharpCorner( boundsCtrlP );
    
    % Local smooth sharp corners
    iters = 30;
    pntSmoothC = smoothSharp( pntSharpC, iters );
    
    % Get exact location of sharp corner in boundsCtrlP
    % Replace sharp corner with smooth corners and insert NaN
    new_bounds = replaceSharpCorner( boundsCtrlP, pntSharpC, pntSmoothC );

end

function pntSharpC = findSharpCorner( bounds )
% findSharpCorner: search and record sharp corner in boundary
%
% Assume sharp corner aligns with ctrl point
% bounds is with labelled ctrl points (NaN, NaN)
%
% pntSharpC is a cell array. pntSharpC{i} is 3-by-2 array. 
% pntSharpC{i}(1,:) is the x y coordinate of one sharp corner
% pntSharpC{i}(2:end,:) is the subsequent vertices of that sharp corner
% 
    
    pntSharpC = {};     % cell
    
    for i = 1: length(bounds)
        for j = 1: length(bounds{i})
            poly = bounds{i}{j};             % contain NaN
            
            tf_nan = isnan(poly(:,1));  % vector
            numNaN = sum(tf_nan);
            
            % -------------------------------------------------------------
            % skip when not exist NaN
            if numNaN < 1,  continue;   end
            
            % skip when the number of vetices is less than 10
            numVert = size(poly,1) - 2*numNaN;
            if numVert < 10,    continue;   end

            % -------------------------------------------------------------
            % Case 1 - normal
            nanInd = find( tf_nan );  % index vector for NaN
            
            for k = 1: length(nanInd)
                pntInd = nanInd(k);    % current location of the k-th NaN
                
                % check whether point (pntInd) is a sharp corner in poly
                pntSharpC = checkSharp( poly, pntInd, pntSharpC );
            end

            % -------------------------------------------------------------
            % Case 2 - when ctrl pnt algins with starting pnt of polyline
            % change the starting pnt to the next ctrl pnt
            [ polyTemp, newInd ] = changeStartPnt( poly );
            
            pntSharpC = checkSharp( polyTemp, newInd, pntSharpC );
            
            % -------------------------------------------------------------
        end
    end

end

function pntSharpC = checkSharp( poly, pntInd, pntSharpC )
% checkSharp: check whether point (pntInd) is a sharp corner in poly
% If it is, add this point to pntSharpC

    % ---------------------------------------------------------------------
    % check input

    % skip when out of range
    if pntInd + 5 > size(poly,1)
        return;
    end
    
    % skip when out of range
    if pntInd - 5 < 1
        return;
    end
    
    % skip when another NaN exist nearby
    tempVec = poly( (pntInd-5):(pntInd+5), 1 );
    if sum(isnan( tempVec )) > 1
        return;
    end
    
    % ---------------------------------------------------------------------
    % obtain turning vector
    loc = [(pntInd-5):(pntInd-1), (pntInd+2):(pntInd+5)]';
    pnts = poly( loc, : );      % 9-by-2 array
    
    turnVec = getTurnVec(pnts);     % 7-by-1 vector. 
    % Left turn: 1; Right turn: -1; No turn: 0;
    
    turnVec1 = turnVec(1:3);    % before ctrl pnt   % 3-by-1 vector
    turnVec2 = turnVec(4);      % at ctrl pnt
    turnVec3 = turnVec(5:7);    % after ctrl pnt    % 3-by-1 vector
    
    % ---------------------------------------------------------------------
    % check turning vector
    
    % skip when no turning at ctrl pnt
    if turnVec2 == 0
        return;
    end
    
    % skip when no turning before and after ctrl pnt
    if all(turnVec1==0) && all(turnVec3==0)
        return;
    end
    
    % when sharp corner is after ctrl pnt
    tf_after = all(turnVec1(2:3)==0) && turnVec3(1) ~= 0 && ...
               turnVec2 == turnVec3(1) && all(turnVec3(2:3)==0) ;
    
    % when sharp corner is before ctrl pnt
    tf_before = all(turnVec3(1:2)==0) && turnVec1(3) ~= 0 && ...
                turnVec2 == turnVec1(3) && all(turnVec1(1:2)==0) ;
    
    % found sharp corner
    if tf_after
        loc = (pntInd+1): (pntInd+5);
        pntSharpC{end+1,1} = poly( loc, : );
    elseif tf_before
        loc = (pntInd-1): -1: (pntInd-5);
        pntSharpC{end+1,1} = poly( loc, : );
    else
        % pntInd is not a sharp corner
        return;
    end
    % ---------------------------------------------------------------------
end


function turnVec = getTurnVec(polyline)
% getTurnVec: get turning angle between the adjacent edges in polyline
%
% Assume all edge in the polyline has unit length. The angle between the 
% adjacent edge can be 180 degrees, 90 degrees, or -90 degrees. Based on 
% the polyline, I want to create a vector turnVec, which records the 
% turning angle between adjacent edges in the polyline. For example, when 
% the turning angle between the i-th edge and the (i+1)-th edge is 90 
% degrees, the value of turnVec(i) is 1. 
%
% polyline: n-by-2 array of vertices. Each row is a vertex
%
% turnVec: (n-2)-by-1 vector. Left turn: 1. Right turn: -1. No turn: 0.
%

    % Compute edge vectors between consecutive vertices
    edges = diff(polyline);

    % Compute the cross product (z-component) and dot product for adjacent edges.
    crossVals = edges(1:end-1,1) .* edges(2:end,2) - edges(1:end-1,2) .* edges(2:end,1);
    dotVals   = sum(edges(1:end-1,:) .* edges(2:end,:), 2);

    % Compute the signed turning angles in radians.
    angles = atan2(crossVals, dotVals);

    % Convert turning angles (in radians) into multiples of 90 degrees.
    % For example, if angle is pi/2 (90 degrees), then pi/2/(pi/2)=1.
    turnVec = round(angles/(pi/2));

end


function [ newPoly, nI ] = changeStartPnt( poly )
% changeStartPnt: change the starting pnt to the next ctrl pnt
% 
% nI is the new location of the original start point (NaN)

    newPoly = zeros( size(poly,1), 2 );

    % location index of the 1st ctrl pnt (NaN)
    I = find( isnan(poly(:,1)), 1 );   % an interger

    % new location index of that NaN. (new location of original start pnt)
    nI = size(poly,1) - I + 1;

    newPoly( 1:(nI-1), : ) = poly( (I+1):end, : );
    newPoly( nI, : )  = [NaN, NaN];
    newPoly( (nI+1):end, : ) = poly( 1:(I-1), : );

end

function pntSmoothC = smoothSharp( pntSharpC, iters )
% smoothSharp: local smooth sharp corners

    pntSmoothC = cell( length(pntSharpC), 1 );

    for i = 1: length(pntSharpC)
        p = pntSharpC{i};
        
        % insert a new point
        newp = [ p(1,:);
                0.5 * (p(1,:)+p(2,:));
                p(2:end,:);
                ];

        newp = taubinSmooth( newp, 0.5, -0.5, iters);

        pntSmoothC{i} = newp(1:4,:);
    end

end

function new_bounds = replaceSharpCorner( bounds, pntSharpC, pntSmoothC )
% replaceSharpCorner: Get exact location of sharp corner in boundsCtrlP and
% replace sharp corner with smooth corners and insert NaN.
%
% bounds is with labelled ctrl points (NaN, NaN)

    new_bounds = bounds;
    
    counter = 1;
    nVert2Rep = 2;  % num of vertices to be replaced after the sharp corner
    
    for i = 1: length(pntSharpC)
        A = pntSharpC{i}(1:2,:);
    
        for j = 1: length(bounds)
            for k = 1: length(bounds{j})
                P = new_bounds{j}{k};
                [ tf_found, loc ] = isvertex(A,P);
                
                if all(tf_found)
                    ind = loc(2);   % location of A(2,:) in P
                    
                    % check ordering of A(1,:) and A(2,:) in P
                    if isequal( P(ind-1,:), A(1,:) )
                        % A(1,:) is before A(2,:) in P. Positive vertex order.
                        P = replaceVert( P, ind, nVert2Rep, pntSmoothC{i}(2:end,:) );
                        % disp('+');
                    elseif isequal( P(ind+1,:), A(1,:) )
                        % A(1,:) is after A(2,:) in P. Reversed vertex order.
                        P = replaceVert( P, ind, -nVert2Rep, pntSmoothC{i}(2:end,:) );
                        % disp('-');
                    else
                        error('Wierd case.')
                    end
    
                    % update
                    new_bounds{j}{k} = P;
    
                    % disp(counter);
                    counter = counter + 1;
                end
            end
        end
    end

end

function new_pnt = replaceVert( pnt, ind, nVert2Rep, pntRep )
% replaceVert: insert NaN to pntRep and replace segment in pnt with pntRep
%
    % ---------------------------------------------------------------------
    % add NaN to all vertices in pntRep
    pntRep = addNaN(pntRep);
    
    % ---------------------------------------------------------------------
    % Replace pnt( ind: (ind+nVert-1), : ) with pntRep

    if nVert2Rep > 0        % Use positive vertex order in pntRep
        nVert = nVert2Rep;
        new_pnt = replaceSeg( pnt, ind, nVert, pntRep );

        if ~isequal( new_pnt(1,:), new_pnt(end,:) )
            error("Non-closed polygon")
        end

    elseif nVert2Rep < 0    % Use reversed vertex order in pntRep
        nVert = -nVert2Rep;

        pntRep = flip(pntRep);  % reverse pntRep in row direction
        new_ind = ind - nVert +1;
        new_pnt = replaceSeg( pnt, new_ind, nVert, pntRep );

        if ~isequal( new_pnt(1,:), new_pnt(end,:) )
            error("Non-closed polygon")
        end
    else
        error("Wierd case.")
    end
    % ---------------------------------------------------------------------
end

function b = addNaN(a)
% ADDNAN Repeats each row of "a" twice with a row of NaNs in between.
%   b = ADDNAN(a)
%
% Example:
%   a = [1 2; 3 4; 5 6];
%   b = addNaN(a);
%   % b will be:
%   %    1   2
%   %    NaN NaN
%   %    1   2
%   %    3   4
%   %    NaN NaN
%   %    3   4
%   %    5   6
%   %    NaN NaN
%   %    5   6

    % Get the size of the input matrix a
    [m, n] = size(a);
    
    % Preallocate b to speed up the code:
    % For each row in "a", we store three rows in "b":
    %   - the original row
    %   - a row of NaNs
    %   - the original row again
    b = NaN(3*m, n);
    
    % Fill b by blocks of three rows
    for i = 1:m
        b(3*(i-1) + 1, :) = a(i, :);      % copy of original row
        % second row is already NaNs
        b(3*(i-1) + 3, :) = a(i, :);      % copy of original row
    end
end


function new_pnt = replaceSeg(pnt,ind,nVert,pntRep)
% replaceSeg
% This function replaces a block of points in the array 'pnt'
% (starting at index 'ind' and covering 'nVert' rows)
% with the new points provided in 'pntRep'. The output is a new
% array 'new_pnt' that reflects this change.
%
% Example:
%   new_pnt = replaceSeg(pnt, 5, 3, pntRep);
%   % This replaces rows 5 to 7 in pnt with the rows in pntRep.


    nVertEx = length(pntRep) - nVert;      % extra
    new_pnt = zeros( length(pnt)+nVertEx, 2 );
    
    new_pnt( 1:ind-1, : ) = pnt( 1:ind-1, : );
    new_pnt( ind:(ind+length(pntRep)-1), : ) = pntRep;
    new_pnt( (ind+length(pntRep)):end, : ) = pnt( (ind+nVert):end, : );

end

