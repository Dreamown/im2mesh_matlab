function linestring = taubinSmooth( linestring, lambda, mu, iters )
% taubinSmooth: 2d polyline smoothing without shrinkage
% detail: https://pypi.org/project/shapelysmooth/#taubin
% 		  https://www.cse.wustl.edu/~taoju/cse554/lectures/lect06_Fairing.pdf
%
%   linestring: polyline, N-by-2 array
%   lambda: How far each node is moved toward the average position of its
%           neighbours during every second iteration. 0<lambda<1
%   mu: How far each node is moved opposite the direction of the average 
%       position of its neighbours during every second iteration. -1<mu<0
%   iters: Number of smoothing steps. Positive interger
%

    factors = [lambda, mu];
    isClosed = checkEnds(linestring(1, :), linestring(end, :));
    numPoints = size(linestring, 1);

    for iter = 1:iters
        for factor = factors
            endpoints = [linestring(2, :); linestring(end-1, :)];
            tempPoint = linestring(1, :);

            for i = 2: numPoints-1
                avgPoint = weightedSum(linestring(i+1, :), linestring(i-1, :), 0.5, 0.5);
                linestring(i-1, :) = tempPoint;
                tempPoint = weightedSum(linestring(i, :), avgPoint, 1 - factor, factor);
            end

            linestring(end-1, :) = tempPoint;

            if isClosed
                avgEndpoints = weightedSum(endpoints(1, :), endpoints(2, :), 0.5, 0.5);
                linestring(1, :) = weightedSum(linestring(1, :), avgEndpoints, 1 - factor, factor);
                linestring(end, :) = linestring(1, :);
            end
        end
    end

end


function result = weightedSum(varargin)
    switch nargin
        case 4
            % weightedSum(t1, t2, w1, w2)
            t1 = varargin{1};
            t2 = varargin{2};
            w1 = varargin{3};
            w2 = varargin{4};
            result = [
                w1 * t1(1) + w2 * t2(1);
                w1 * t1(2) + w2 * t2(2)
            ];
        case 6
            % weightedSum(t1, t2, t3, w1, w2, w3)
            t1 = varargin{1};
            t2 = varargin{2};
            t3 = varargin{3};
            w1 = varargin{4};
            w2 = varargin{5};
            w3 = varargin{6};
            result = [
                w1 * t1(1) + w2 * t2(1) + w3 * t3(1);
                w1 * t1(2) + w2 * t2(2) + w3 * t3(2)
            ];
        otherwise
            error('Invalid number of arguments');
    end
end

function isEqual = checkEnds(startPoint, endPoint)
    isEqual = isequal(startPoint, endPoint);
end