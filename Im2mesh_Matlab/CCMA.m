classdef CCMA
    % CCMA  Curvature-Corrected Moving Average (CCMA) Filter
    %       (https://github.com/UniBwTAS/ccma)
    % This is a MATLAB class
    % This is a matlab implementation CCMA
    % Example:
    %     n = 50;
    %     noise = 0.05 * randn(n, 2);
    %     t = linspace(0, 2*pi, n);
    %     points = [cos(t(:)), sin(t(:))];
    %     noisy_points = points + noise;
    %     
    %     ccma_instance = CCMA(5, 3, 'pascal', [], [], 0.95, 0.95);
    %     ss = ccma_instance.filter( noisy_points, 'fill_boundary');
    %     
    %     figure
    %     hold on
    %     axis equal
    %     plot( noisy_points(:,1), noisy_points(:,2), 'k')
    %     plot( ss(:,1), ss(:,2), 'b' );
    %     hold off

    properties
        w_ma          % Width parameter for moving average
        w_cc          % Width parameter for curvature correction
        w_ccma        % Combined width (w_ma + w_cc + 1)
        distrib_ma    % Distribution for the moving average
        distrib_cc    % Distribution for the curvature correction
        rho_ma        % Truncation area (if normal distribution) for MA
        rho_cc        % Truncation area (if normal distribution) for CC
        weights_ma    % Cell array of MA weights (for each w from 0..w_ma)
        weights_cc    % Cell array of CC weights (for each w from 0..w_cc)
    end

    methods
        % ----------------------------------------------------------------------
        % Constructor
        % ----------------------------------------------------------------------
        function obj = CCMA(w_ma, w_cc, distrib, distrib_ma, distrib_cc, rho_ma, rho_cc)
            % Handle default arguments
            if ~exist('w_ma','var') || isempty(w_ma), w_ma = 5; end
            if ~exist('w_cc','var') || isempty(w_cc), w_cc = 3; end
            if ~exist('distrib','var') || isempty(distrib), distrib = 'pascal'; end

            if ~exist('distrib_ma','var'), distrib_ma = []; end
            if ~exist('distrib_cc','var'), distrib_cc = []; end
            if isempty(distrib_ma), distrib_ma = distrib; end
            if isempty(distrib_cc), distrib_cc = distrib; end

            if ~exist('rho_ma','var') || isempty(rho_ma), rho_ma = 0.95; end
            if ~exist('rho_cc','var') || isempty(rho_cc), rho_cc = 0.95; end

            % Assign properties
            obj.w_ma = w_ma;
            obj.w_cc = w_cc;
            obj.w_ccma = w_ma + w_cc + 1;

            obj.distrib_ma = distrib_ma;
            obj.distrib_cc = distrib_cc;

            obj.rho_ma = rho_ma;
            obj.rho_cc = rho_cc;

            % Compute weights
            obj.weights_ma = obj.get_weights(w_ma, obj.distrib_ma, rho_ma);
            obj.weights_cc = obj.get_weights(w_cc, obj.distrib_cc, rho_cc);
        end


        % ----------------------------------------------------------------------
        % get_weights (static-like method)
        % ----------------------------------------------------------------------
        function weight_list = get_weights(obj, w, distrib, rho)
            % Generate a cell array of weight vectors (kernels) for each window
            % size from 0..w. The distribution can be 'normal', 'uniform',
            % 'pascal', 'hanning' or a user-defined function handle.
            %
            % weight_list{k+1} -> weights for 2*k+1 points (k from 0..w).

            weight_list = cell(w+1, 1);

            if strcmp(distrib, 'normal')
                % Normal distribution (truncated)
                % norminv in MATLAB = ppf in Python
                x_start = norminv((1 - rho) / 2, 0, 1);
                x_end   = norminv(1 - (1 - rho)/2, 0, 1);

                for w_i = 0:w
                    % We generate 2*w_i+1 intervals for the PDF integration
                    x_values = linspace(x_start, x_end, (2*w_i + 1) + 1);
                    weights = zeros(2*w_i+1, 1);
                    for idx = 1:(2*w_i+1)
                        % normcdf in MATLAB = norm.cdf in Python
                        weights(idx) = ...
                            normcdf(x_values(idx+1),0,1) - normcdf(x_values(idx),0,1);
                    end
                    weights = (1 / rho) * weights;   % Adjust by rho
                    weight_list{w_i + 1} = weights;
                end

            elseif strcmp(distrib, 'uniform')
                % Uniform distribution
                for w_i = 0:w
                    weights = ones(2*w_i+1, 1) * (1 / (2*w_i + 1));
                    weight_list{w_i + 1} = weights;
                end

            elseif strcmp(distrib, 'pascal')
                % Pascal distribution (rows of Pascal's triangle)
                for w_i = 0:w
                    pascal_row_idx = 2*w_i;
                    row = obj.get_pascal_row(pascal_row_idx);
                    row_sum = sum(row);
                    weight_list{w_i + 1} = row ./ row_sum;
                end

            elseif strcmp(distrib, 'hanning')
                % Hanning window
                for w_i = 0:w
                    kernel = obj.get_hanning_kernel(2*w_i + 1);
                    weight_list{w_i + 1} = kernel;
                end

            elseif isa(distrib, 'function_handle')
                % Custom distribution
                for w_i = 0:w
                    weight_list{w_i + 1} = distrib(2*w_i + 1);
                end

            else
                error(['Distribution must be ''uniform'', ''pascal'', ''hanning'', ', ...
                       '''normal'' or a callable function handle.']);
            end
        end


        % ----------------------------------------------------------------------
        % get_pascal_row
        % ----------------------------------------------------------------------
        function row = get_pascal_row(obj, row_index)
            % Generate 'row_index'-th row of Pascal's triangle as a row vector.
            % Row 0 = [1], Row 1 = [1 1], etc.
            if row_index == 0
                row = 1;
                return;
            end
            prev = obj.get_pascal_row(row_index-1);
            row = [1, arrayfun(@(i) prev(i) + prev(i+1), 1:length(prev)-1), 1];
        end


        % ----------------------------------------------------------------------
        % get_hanning_kernel
        % ----------------------------------------------------------------------
        function hk = get_hanning_kernel(obj, window_size)
            % Return a Hanning window of length `window_size`, normalized to sum=1
            % In standard usage, hanning(N) in MATLAB has zeros at both ends if
            % N>1, so we replicate the Python approach:
            if window_size <= 1
                hk = 1;  % Trivial case (a single point)
                return
            end

            % The standard Hanning window of length `window_size`
            n = (0:(window_size-1))';
            w = 0.5 * (1 - cos(2*pi*n/(window_size - 1)));
            hk = w / sum(w);
        end


        % ----------------------------------------------------------------------
        % get_3d_from_2d (static-like)
        % ----------------------------------------------------------------------
        function pts3d = get_3d_from_2d(~, points)
            % Convert Nx2 into Nx3 by appending a zero z-coordinate
            pts3d = [points, zeros(size(points,1),1)];
        end


        % ----------------------------------------------------------------------
        % get_ma_points (static-like)
        % ----------------------------------------------------------------------
        function ma_pts = get_ma_points(~, points, weights)
            % Apply 1D convolution in each dimension (x,y,z) with 'valid' mode.
            n = size(points, 1);
            wx = conv(points(:,1), weights, 'valid');
            wy = conv(points(:,2), weights, 'valid');
            wz = conv(points(:,3), weights, 'valid');
            ma_pts = [wx, wy, wz];
        end


        % ----------------------------------------------------------------------
        % get_curvature_vectors (static-like)
        % ----------------------------------------------------------------------
        function curvature_vectors = get_curvature_vectors(obj, points)
            % Calculate curvature vectors for each interior point.
            curvature_vectors = zeros(size(points));
            n = size(points,1);

            for i = 2:(n-1)
                p0 = points(i-1,:);
                p1 = points(i,:);
                p2 = points(i+1,:);

                v1 = p1 - p0;
                v2 = p2 - p1;
                crossv = cross(v1, v2);
                cross_norm = norm(crossv);

                if cross_norm ~= 0
                    radius = (norm(v1) * norm(v2) * norm(p2 - p0)) / (2 * cross_norm);
                    curvature = 1.0 / radius;
                else
                    curvature = 0.0;
                end

                curvature_vectors(i,:) = curvature * obj.get_unit_vector(crossv);
            end
        end


        % ----------------------------------------------------------------------
        % get_alphas (static-like)
        % ----------------------------------------------------------------------
        function alphas = get_alphas(~, points, curvatures)
            % Compute the angle (alpha) at each point from the curvature.
            n = size(points,1);
            alphas = zeros(n,1);

            for i = 2:(n-1)
                curv = curvatures(i);
                if curv ~= 0.0
                    radius = 1 / curv;
                    dist_neighbors = norm(points(i+1,:) - points(i-1,:));
                    % alpha = arcsin( (dist_neighbors / 2) / radius )
                    alphas(i) = asin((dist_neighbors/2) / radius);
                else
                    alphas(i) = 0.0;
                end
            end
        end


        % ----------------------------------------------------------------------
        % get_normalized_ma_radii (static-like)
        % ----------------------------------------------------------------------
        function radii_ma = get_normalized_ma_radii(~, alphas, w_ma, weights)
            % Calculate normalized radii using the angles (alphas). The result
            % is a 1D array with the same length as alphas.
            n = length(alphas);
            radii_ma = zeros(n,1);

            for i = 2:(n-1)
                % Start with the central weight
                radius_val = 1.0 * weights(w_ma+1);

                % Summation in the formula: radius += 2*cos(alpha_i * k)*weights[w_ma+k]
                for k = 1:w_ma
                    % Index in 'weights' is w_ma+1+k
                    radius_val = radius_val + 2*cos(alphas(i)*k)*weights(w_ma+1 + k);
                end

                % Threshold
                radii_ma(i) = max(0.35, radius_val);
            end
        end


        % ----------------------------------------------------------------------
        % get_descending_width
        % ----------------------------------------------------------------------
        function desc_width_list = get_descending_width(obj)
            % Generate a list of (w_ma, w_cc) pairs with decreasing size
            w_ma_cur = obj.w_ma;
            w_cc_cur = obj.w_cc;

            desc_width_list = {};
            while ~ (w_ma_cur == 0 && w_cc_cur == 0)
                if w_cc_cur >= w_ma_cur
                    w_cc_cur = w_cc_cur - 1;
                else
                    w_ma_cur = w_ma_cur - 1;
                end
                pair = struct('w_ma', w_ma_cur, 'w_cc', w_cc_cur);
                desc_width_list{end+1} = pair; %#ok<AGROW>
            end
        end


        % ----------------------------------------------------------------------
        % _filter
        % ----------------------------------------------------------------------
        function filt_points = internal_filter(obj, points, w_ma, w_cc, cc_mode)
            % Apply the CCMA filter or just MA, depending on cc_mode.

            w_ccma = w_ma + w_cc + 1;

            % Moving-average step
            points_ma = obj.get_ma_points(points, obj.weights_ma{w_ma+1});

            if ~cc_mode
                % Return only MA result
                filt_points = points_ma;
                return;
            end

            % Curvature vectors, curvatures
            curvature_vectors = obj.get_curvature_vectors(points_ma);
            curvatures = sqrt(sum(curvature_vectors.^2, 2));

            % Angles alphas
            alphas = obj.get_alphas(points_ma, curvatures);

            % Radii
            radii_ma = obj.get_normalized_ma_radii(alphas, w_ma, obj.weights_ma{w_ma+1});

            % Allocate
            new_len = size(points,1) - 2*w_ccma;
            filt_points = zeros(new_len, 3);

            for idx = 1:new_len
                % In python: unit_tangent is from (w_cc+idx+1+1) - (w_cc+idx-1+1)
                % That is effectively from points_ma(w_cc+idx+2,:) - points_ma(w_cc+idx,:)
                % Adjust for MATLAB (1-based):
                center_idx = w_cc + idx;  % center point in points_ma
                p_next = points_ma(center_idx+1+1, :);  % +2
                p_prev = points_ma(center_idx-1+1, :);  % -0
                unit_tangent = obj.get_unit_vector(p_next - p_prev);

                shift = zeros(1,3);
                for idx_cc = 0:(2*w_cc)
                    % curvature_vectors index => (idx + idx_cc + 1)
                    cc_idx = idx + idx_cc;
                    real_idx = cc_idx + 1;  % shift to 1-based

                    if curvatures(real_idx) == 0
                        continue;
                    end

                    u_vec = obj.get_unit_vector(curvature_vectors(real_idx,:));
                    weight_val = obj.weights_cc{w_cc+1}(idx_cc+1);
                    shift_magnitude = (1 / curvatures(real_idx)) * ...
                                      (1 / radii_ma(real_idx) - 1);
                    shift = shift + (u_vec * weight_val * shift_magnitude);
                end

                % Reconstruct final
                filt_points(idx,:) = points_ma(center_idx+1,:) + cross(unit_tangent, shift);
            end
        end


        % ----------------------------------------------------------------------
        % filter (public API)
        % ----------------------------------------------------------------------
        function result = filter(obj, points, mode, cc_mode)
            % filter  Apply CCMA (or just MA) to the given points.
            %
            %   result = obj.filter(points, mode, cc_mode)
            %
            %   Inputs:
            %       points: Nx2 or Nx3 array of coordinates
            %       mode:   'none', 'padding', 'wrapping', or 'fill_boundary'
            %       cc_mode: boolean, true => use curvature correction
            %
            %   Output:
            %       result: Filtered Nx2 or Nx3 set of points
            %

            if ~exist('mode','var') || isempty(mode), mode = 'padding'; end
            if ~exist('cc_mode','var') || isempty(cc_mode), cc_mode = true; end

            % Validate mode
            valid_modes = {'none', 'padding', 'wrapping', 'fill_boundary'};
            if ~ismember(mode, valid_modes)
                error('Invalid mode! Must be one of: none|padding|wrapping|fill_boundary');
            end

            % We need at least 3 points
            if size(points,1) < 3
                error('At least 3 points are necessary for CCMA-filtering');
            end

            % Determine how many points to pad
            if cc_mode
                n_padding = obj.w_ccma;
            else
                n_padding = obj.w_ma;
            end

            % Pad or wrap if requested
            switch mode
                case 'padding'
                    % Pad with first/last repeated
                    top_pad = repmat(points(1,:), n_padding, 1);
                    bot_pad = repmat(points(end,:), n_padding, 1);
                    points = [top_pad; points; bot_pad];

                case 'wrapping'
                    top_wrap = points(end-n_padding+1:end, :);
                    bot_wrap = points(1:n_padding, :);
                    points = [top_wrap; points; bot_wrap];

                case 'fill_boundary'
                    % No immediate padding, we do boundary handling later
                case 'none'
                    % No padding
            end

            % Ensure we have enough points for the widest kernel
            if size(points,1) < (obj.w_ccma * 2 + 1)
                error('Not enough points given for complete filtering!');
            end

            % If input is Nx2, convert to Nx3
            is_2d = (size(points,2) == 2);
            if is_2d
                points_3d = obj.get_3d_from_2d(points);
            else
                points_3d = points;
            end

            if ~strcmp(mode, 'fill_boundary')
                % Standard approach
                out3d = obj.internal_filter(points_3d, obj.w_ma, obj.w_cc, cc_mode);
                if is_2d
                    result = out3d(:,1:2);
                else
                    result = out3d;
                end
            else
                % fill_boundary approach
                dim = 2 + (~is_2d);  % 2 or 3
                if cc_mode
                    % Do the descending approach
                    result = zeros(size(points_3d,1), dim);
                    desc_list = obj.get_descending_width();
                    desc_list = fliplr(desc_list); % reverse the order

                    % First & last point remain
                    result(1,:)   = points_3d(1,1:dim);
                    result(end,:) = points_3d(end,1:dim);

                    % The "full-filtered" portion in the center
                    w_ccma_val = obj.w_ccma;
                    center_out = obj.internal_filter(points_3d, obj.w_ma, obj.w_cc, true);
                    result(w_ccma_val+1 : end-w_ccma_val, :) = center_out(:, 1:dim);

                    % Now handle the boundary transitions (descending widths)
                    for i = 1:length(desc_list)
                        w_ma_cur = desc_list{i}.w_ma;
                        w_cc_cur = desc_list{i}.w_cc;
                        w_ccma_cur = w_ma_cur + w_cc_cur + 1;

                        % design choice for second-last points:
                        use_ma_1 = (w_ma_cur == 0) && (obj.w_ma ~= 0);

                        % ascending boundary
                        sub_points = points_3d(1 : i + w_ccma_cur + 1, :);
                        if ~use_ma_1
                            boundary_out = obj.internal_filter(sub_points, w_ma_cur, w_cc_cur, true);
                        else
                            boundary_out = obj.internal_filter(sub_points, 1, w_cc_cur, false);
                        end
                        result(i+1, :) = boundary_out(end, 1:dim);

                        % descending boundary
                        sub_points2 = points_3d(end - (i + w_ccma_cur) : end, :);
                        if ~use_ma_1
                            boundary_out2 = obj.internal_filter(sub_points2, w_ma_cur, w_cc_cur, true);
                        else
                            boundary_out2 = obj.internal_filter(sub_points2, 1, w_cc_cur, false);
                        end
                        result(end - i, :) = boundary_out2(1, 1:dim);
                    end
                else
                    % MA only, no curvature
                    result = zeros(size(points_3d,1), dim);
                    % center
                    result(obj.w_ma+1 : end-obj.w_ma, :) = ...
                        obj.internal_filter(points_3d, obj.w_ma, 0, false);

                    % boundary
                    for i = 1:obj.w_ma
                        % ascending
                        sub_points = points_3d(1 : 2*i+1, :);
                        boundary_out = obj.internal_filter(sub_points, i, 0, false);
                        result(i, :) = boundary_out(end, 1:dim);

                        % descending
                        sub_points2 = points_3d(end - (2*i) : end, :);
                        boundary_out2 = obj.internal_filter(sub_points2, i, 0, false);
                        result(end - i + 1, :) = boundary_out2(1, 1:dim);
                    end
                end

                % If was 2D originally, strip the Z column
                if is_2d
                    result = result(:,1:2);
                end
            end
        end
    end

    methods(Static)
        % ----------------------------------------------------------------------
        % get_unit_vector (static)
        % ----------------------------------------------------------------------
        function uv = get_unit_vector(vec)
            % Return vec normalized to unit length (or vec itself if norm=0)
            n = norm(vec);
            if n == 0
                uv = vec;
            else
                uv = vec ./ n;
            end
        end
    end
end
