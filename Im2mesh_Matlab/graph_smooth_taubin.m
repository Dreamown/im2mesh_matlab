function Vout = graph_smooth_taubin(Vin, F, feat, ntype, geom, lamda, mu, num_iters)
% graph_smooth_taubin
% Project website: https://github.com/mjx888/im2mesh
%

    N = size(Vin,1);
    switch feat
        case 'ext_triple', edge_weights = 1*ismember(ntype, 13) + 2*ismember(ntype, 14);
        case 'int_triple', edge_weights = 1*ismember(ntype, 3)  + 2*ismember(ntype, 4);
        otherwise,         edge_weights = ones(N,1);
    end
    
    if ~strcmp(feat, 'bound')
        pinned = ones(N,1); 
    else
        pinned = double(ismember(ntype, [2, 12]));
    end

    is_active = (pinned > 0) & any(geom > 0, 2) & (edge_weights > 0);
    active_idx = find(is_active);
    N_act = length(active_idx);
    
    if N_act == 0, Vout = Vin; return; end
    
    active_mask = false(N, 1);
    active_mask(active_idx) = true;
    
    face_has_active = active_mask(F(:,1)) | active_mask(F(:,2)) | active_mask(F(:,3));
    F_sub = F(face_has_active, :);
    
    if isempty(F_sub), Vout = Vin; return; end
    
    i = [F_sub(:,1); F_sub(:,2); F_sub(:,3); F_sub(:,2); F_sub(:,3); F_sub(:,1)];
    j = [F_sub(:,2); F_sub(:,3); F_sub(:,1); F_sub(:,1); F_sub(:,2); F_sub(:,3)];
    
    keep = active_mask(i);
    i_keep = i(keep);
    j_keep = j(keep);
    
    map_active = zeros(N, 1);
    map_active(active_idx) = 1:N_act;
    row_idx = map_active(i_keep);
    
    A_bin_act = sparse(row_idx, j_keep, 1, N_act, N);
    A_bin_act = spones(A_bin_act); 
    
    [r, c, ~] = find(A_bin_act);
    w_vals = edge_weights(active_idx(r)) .* edge_weights(c);
    A_act = sparse(r, c, w_vals, N_act, N);
    
    d_act = sum(A_act, 2); 
    row_sum_abs_act = 2 * d_act;
    row_sum_abs_act(row_sum_abs_act == 0) = 1e-8;
    W_norm_act = 1 ./ row_sum_abs_act;
    
    pre_lamda_act = lamda * (geom(active_idx, :) .* W_norm_act);
    pre_mu_act    = mu    * (geom(active_idx, :) .* W_norm_act);
    
    V = Vin;
    V_act = V(active_idx, :);
    
    for it = 1:num_iters
        LV1_act = d_act .* V_act - A_act * V;
        V_half_act = V_act - pre_lamda_act .* LV1_act;
        V(active_idx, :) = V_half_act; 
        
        LV2_act = d_act .* V_half_act - A_act * V;
        V_new_act = V_half_act - pre_mu_act .* LV2_act;
        
        V(active_idx, :) = V_new_act; 
        V_act = V_new_act;            
    end
    
    Vout = V;
end