% Clear environment
clear; clc; close all;

%=============================
%     IMAGE PARAMETERS
%=============================
imageSize = 500;                 % 500 x 500 image
treeImage = zeros(imageSize);    % Initialize as a binary matrix

%=============================
%     TREE LAYER SETTINGS
%=============================
centerCol   = floor(imageSize/2);  % Center column of the tree
slopeFactor = 0.8;                 % Controls how quickly each layer widens

% Three layers, each overlapping significantly with the one above:
layerRows = [
    30   80    % Layer 1 (top) 
    60   140   % Layer 2 (middle), overlaps from 60..80 => 21 rows overlap
    100  190   % Layer 3 (bottom), overlaps from 100..140 => 41 rows overlap
];

%=============================
%     TRUNK SETTINGS
%=============================
% Trunk starts immediately below the last layer
trunkTop    = layerRows(end, 2) + 1;  % 190 + 1 = 191
trunkHeight = 30;
trunkWidth  = 25;

%=============================
%     STAR SETTINGS
%=============================
starCenterRow   = layerRows(1,1) - 6;  % Slightly above the first layer
starRadiusOuter = 15;                  % Outer radius of star tips
starRadiusInner = 8;                   % Inner "valley" radius
numPoints       = 5;                   % 5 points for a classic star

%=============================
%    CREATE TREE LAYERS
%=============================
for i = 1:size(layerRows, 1)
    rowStart = layerRows(i, 1);
    rowEnd   = layerRows(i, 2);
    
    for r = rowStart:rowEnd
        % The width grows linearly from top of layer to bottom
        halfWidth = floor((r - rowStart) * slopeFactor);
        
        leftCol  = centerCol - halfWidth;
        rightCol = centerCol + halfWidth;
        
        % Clamp to image boundaries
        leftCol  = max(1, leftCol);
        rightCol = min(imageSize, rightCol);
        
        if leftCol <= rightCol
            treeImage(r, leftCol:rightCol) = 1;
        end
    end
end

%=============================
%    CREATE THE TRUNK
%=============================
trunkBottom   = trunkTop + trunkHeight - 1;  % 191 + 40 - 1 = 230
leftColTrunk  = centerCol - floor(trunkWidth / 2);
rightColTrunk = centerCol + floor(trunkWidth / 2);

leftColTrunk  = max(1, leftColTrunk);
rightColTrunk = min(imageSize, rightColTrunk);
trunkBottom   = min(imageSize, trunkBottom);

for r = trunkTop:trunkBottom
    treeImage(r, leftColTrunk:rightColTrunk) = 1;
end

%=============================
%    CREATE THE STAR
%=============================
if starCenterRow < 1
    starCenterRow = 1;
end

% Create a 5-point star (10-vertex polygon: outer tip -> inner tip -> ...).
anglesOuter = (0 : numPoints-1) * (2*pi / numPoints);
anglesInner = anglesOuter + (pi / numPoints);

xOuter = centerCol + starRadiusOuter * cos(anglesOuter);
yOuter = starCenterRow + starRadiusOuter * sin(anglesOuter);

xInner = centerCol + starRadiusInner * cos(anglesInner);
yInner = starCenterRow + starRadiusInner * sin(anglesInner);

% Interleave the outer and inner points
xPolygon = zeros(1, 2*numPoints);
yPolygon = zeros(1, 2*numPoints);
for k = 1:numPoints
    xPolygon(2*k-1) = xOuter(k);
    yPolygon(2*k-1) = yOuter(k);
    xPolygon(2*k)   = xInner(k);
    yPolygon(2*k)   = yInner(k);
end

% Convert polygon to binary mask using poly2mask
starMask = poly2mask(xPolygon, yPolygon, imageSize, imageSize);

% Merge the star into the tree
treeImage(starMask) = 1;

%=============================
%    DISPLAY THE IMAGE
%=============================
figure;
imshow(treeImage);
title('3-Layer Binary Christmas Tree (500x500), Large Overlaps, No Noise');
