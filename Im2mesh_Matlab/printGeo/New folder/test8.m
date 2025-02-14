clearvars

%%
point = vert;
line = edge;
C = phaseLoops;
printGeo( C, point, line, 1, 'test233.geo' );

%%
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


% Initialize counters for Gmsh IDs
phyID    = 1;  % Physical surface ID
surfaceID = 1; % Plane surface ID
loopID   = 1;  % Line loop ID

% Loop over each physical surface
for i = 1:numel(C)
    % We will collect the plane surfaces (their IDs) that go into this physical surface
    surfacesInThisPhysical = [];
    
    % Each C{i} is a cell array of plane surfaces
    for j = 1:numel(C{i})
        
        % We will collect the loop IDs in this plane surface
        loopsInThisSurface = [];
        
        % Each C{i}{j} is a cell array of loops
        for k = 1:numel(C{i}{j})
            lineIndices = C{i}{j}{k};  % Nx1 array of line indices for the k-th loop
            
            % -------------------------------
            % 1. Print the Line Loop
            % -------------------------------
            % Gmsh syntax: Line Loop(loopID) = {line1, line2, ...};
            fprintf(fid, 'Line Loop(%d) = {', loopID);
            % Print each line index, separated by commas
            for n = 1:numel(lineIndices)
                if n == numel(lineIndices)
                    fprintf(fid, '%d};\n', lineIndices(n));
                else
                    fprintf(fid, '%d, ', lineIndices(n));
                end
            end
            
            % Store this loop ID so we can reference it in the plane surface
            loopsInThisSurface = [loopsInThisSurface, loopID];
            loopID = loopID + 1;
            
        end % k
        
        % -------------------------------
        % 2. Print the Plane Surface
        % -------------------------------
        % A plane surface can have one or more loops: the first is the outer boundary,
        % and subsequent loops can be holes (with negative sign in advanced usage).
        % But here we assume each plane surface uses all the loops in loopsInThisSurface.
        
        % Gmsh syntax: Plane Surface(surfaceID) = {loop1, loop2, ...};
        fprintf(fid, 'Plane Surface(%d) = {', surfaceID);
        for u = 1:numel(loopsInThisSurface)
            if u == numel(loopsInThisSurface)
                fprintf(fid, '%d};\n', loopsInThisSurface(u));
            else
                fprintf(fid, '%d, ', loopsInThisSurface(u));
            end
        end
        
        % Store this surface ID so we can reference it in the physical surface
        surfacesInThisPhysical = [surfacesInThisPhysical, surfaceID];
        surfaceID = surfaceID + 1;
        
    end % j
    
    % -------------------------------
    % 3. Print the Physical Surface
    % -------------------------------
    % Gmsh syntax: Physical Surface(phyID) = {surface1, surface2, ...};
    
    fprintf(fid, 'Physical Surface(%d) = {', phyID);
    for v = 1:numel(surfacesInThisPhysical)
        if v == numel(surfacesInThisPhysical)
            fprintf(fid, '%d};\n', surfacesInThisPhysical(v));
        else
            fprintf(fid, '%d, ', surfacesInThisPhysical(v));
        end
    end
    
    phyID = phyID + 1;
    
end % i

fclose(fid);

