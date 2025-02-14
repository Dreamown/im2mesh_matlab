% Suppose we have:
% point: Np-by-2 array (x, y)
% line: Nl-by-2 array (start_point_index, end_point_index)
% loop: M-by-1 array (line indices for the loop)
%
clearvars

%%
point = vert;
line = edge;
loopB = phaseLoops{1}{1}; % 1x2 cell

%%
% Define a characteristic length
lc = 1.0;

% Open a file for writing
fid = fopen('test233.geo', 'wW');

% ---------------------------
% 1. Print out the Points
% ---------------------------
for i = 1:size(point, 1)
    x = point(i, 1);
    y = point(i, 2);
    % Gmsh syntax: Point(ID) = {x, y, z, lc};
    fprintf(fid, 'Point(%d) = {%.6f, %.6f, 0};\n', ...
            i, x, y );
end
fprintf(fid, '\n');

% ---------------------------
% 2. Print out the Lines
% ---------------------------
for i = 1:size(line, 1)
    p1 = line(i, 1);
    p2 = line(i, 2);
    % Gmsh syntax: Line(ID) = {startPt, endPt};
    fprintf(fid, 'Line(%d) = {%d, %d};\n', i, p1, p2);
end
fprintf(fid, '\n');

% ---------------------------
% 3. Print out the Line Loop
% ---------------------------
% Suppose you have a single loop with M lines:
% Gmsh syntax: Line Loop(LLID) = {l1, l2, ...};
for loopID = 1: length(loopB)
    loopT = loopB{loopID};
    printLoop( fid, loopT, loopID );
end

% If you want to generate a surface from the loop, you could add:
fprintf(fid, 'Plane Surface(%d) = {%d};\n\n', loopID, loopID);

% Finally, close the file
fclose(fid);

disp('Gmsh .geo file generated');














