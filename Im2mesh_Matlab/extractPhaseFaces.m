function phaseFaces = extractPhaseFaces(F, flabel)
% Extract surface mesh faces for each individual phase
% Project website: https://github.com/mjx888/im2mesh
%

    phase_ids = unique(flabel);
    phase_ids(phase_ids == -1) = []; % Remove background label

    % Store faces in a cell array for dynamic handling
    phaseFaces = cell(length(phase_ids), 1);
    for i = 1:length(phase_ids)
        pi = phase_ids(i);
        i1 = find(pi == flabel(:,1));
        i2 = find(pi == flabel(:,2));
        phaseFaces{i} = F([i1; i2], :);
    end
end