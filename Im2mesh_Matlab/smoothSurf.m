function V = smoothSurf( V, F, ntype, num_iters, lamda, mu)
% smoothSurf

    disp('//////////////// Taubin Smoothing ////////////////');
	
    % Start timer
    tic;
    
    % Geometric constraints
    minX = min(V(:,1)); maxX = max(V(:,1));
    minY = min(V(:,2)); maxY = max(V(:,2));
    minZ = min(V(:,3)); maxZ = max(V(:,3));
    geom = [double(V(:,1) > minX & V(:,1) < maxX), ...
            double(V(:,2) > minY & V(:,2) < maxY), ...
            double(V(:,3) > minZ & V(:,3) < maxZ)];  % N x 3

    % Smoothing passes
    fprintf('Smooth Exterior Triple Lines\n');
    V = graph_smooth_taubin(V, F, 'ext_triple', ntype, geom, lamda, mu, num_iters);
    fprintf('Smooth Interior Triple Lines\n');
    V = graph_smooth_taubin(V, F, 'int_triple', ntype, geom, lamda, mu, num_iters);
    fprintf('Smooth Boundaries\n');
    V = graph_smooth_taubin(V, F, 'bound', ntype, geom, lamda, mu, num_iters);
    
    % Stop timer
    smoothTime = toc;
	
    disp('//////////////// Smoothing Done! ////////////////');
	fprintf('//////////////// Time = %.2fs ////////////////\n', smoothTime);
end