function [vert,conn,tria,tnum] = deltri1(varargin)
% deltri1 is the simpfied version of deltri2
%DELTRI2 compute a constrained 2-simplex Delaunay triangula-
%tion in the two-dimensional plane.
%   [VERT,CONN,TRIA,TNUM]=DELTRI2(VERT,CONN,NODE,PSLG,PART)
%   computes the Delaunay trianguation {VERT,TRIA}, the con-
%   straints CONN, and the "inside" status vector TNUM. VERT
%   is an V-by-2 array of XY coordinates to be triangulated,
%   TRIA is a T-by-3 array of vertex indexing, where each
%   row defines a triangle, such that VERT(TRIA(II,1),:),
%   VERT(TRIA(II,2),:) and VERT(TRIA(II,3),:) are the coord-
%   inates of the II-TH triangle. CONN is a C-by-2 array of
%   constraining edges, where each row defines an edge, as
%   per TRIA. The additional arguments NODE,PSLG and PART
%   define a (mutliply-connected) polygonal region, where
%   NODE is an N-by-2 array of vertices and PSLG is a P-by-2
%   array of edges (a piecewise-straight-line-graph), where
%   each row defines an edge as a pair of indices into NODE.
%   PART is a cell-array of polygonal "parts", where each
%   element PART{KK} is an array of edge indices defining a
%   polygonal region. PSLG(PART{KK},:) is the set of edges
%   in the KK-TH part. TNUM is a T-by-1 array of part index-
%   ing, such that TNUM(II) is the index of the part in whi-
%   ch the II-TH triangle resides.
%
%   See also DELAUNAYTRIANGULATION, DELAUNAYTRI, DELAUNAYN

%   Darren Engwirda : 2017 --
%   Email           : d.engwirda@gmail.com
%   Last updated    : 08/07/2018


    %---------------------------------------------- extract args
     vert = varargin{1};
     conn = varargin{2};
     node = varargin{3};
     PSLG = varargin{4};
     part = varargin{5};
    %------------------------------------ compute Delaunay tria.
    if (exist('delaunayTriangulation') == +2 )
        dtri = ...
        delaunayTriangulation(vert,conn) ;
        vert = dtri.Points;
        conn = dtri.Constraints;
        tria = dtri.ConnectivityList;
    else
        error('function delaunayTriangulation not exist')
    end

    %------------------------------------ calc. "inside" status!
    tnum = zeros(size(tria,+1),+1) ;

    tmid = vert(tria(:,1),:) ...
         + vert(tria(:,2),:) ...
         + vert(tria(:,3),:) ;
    tmid = tmid / +3.0;

    for ppos = 1 : length(part)
       [stat] = inpoly2( tmid, node, PSLG(part{ppos},:) );
       tnum(stat)  = ppos ;
    end
    %------------------------------------ keep "interior" tria's
    tria = tria(tnum>+0,:) ;
    tnum = tnum(tnum>+0,:) ;

    %------------------------------------ flip for correct signs
    area = triarea(vert,tria) ;

    tria(area<0.,:) = tria(area<0.,[1,3,2]) ;

end