function [Vnew, Fnew, flabelnew] = selectPhase( V, F, flabel, ind_vec )
% selectPhase: modify surface mesh faces and labels based on a vector of 
% phase indices.
%
% usage:
%	[Vnew, Fnew, flabelnew] = selectPhase( V, F, flabel, ind_vec );
%
% Inputs:
%   V      - Vertices
%   F      - Faces
%   flabel - Face labels (Nx2)
%   ind_vec - Vector of phase indices to select (e.g., [3, 68, 77, 154])
%             If we want to select all the phases, we can set ind_vec=[];
%
% Outputs:
%   Vnew   - Updated vertices 
%   Fnew   - Updated faces
%   flabelnew - Updated face labels
%
% Example:
%     grayscale_we_like = [ 3, 27, 61 ];
%     [V, F, flabel] = selectPhase( V, F, flabel, grayscale_we_like );
%     
%     grayscale_we_like = [];
%     [V, F, flabel] = selectPhase( V, F, flabel, grayscale_we_like );
%
% Copyright (C) 2019-2026 by Jiexian Ma, mjx0799@gmail.com
% Distributed under the terms of the GNU General Public License (version 3)
% 
% Project website: https://github.com/mjx888/im2mesh
%

    % If ind_vec is not provided or is empty, return inputs unmodified
    if nargin < 4 || isempty(ind_vec)
        Vnew = V;
        Fnew = F;
        flabelnew = flabel;
        return;
    end

    Fnew = F;
    flabelnew = flabel;
    
    % shift +1 to be consistent with flabel
    ind_vec = ind_vec +1;

    % find the phases to be removed/deleted
    phase_ids = unique(flabel);
    phase_ids(phase_ids == -1) = []; % Remove background label
    ind_vec_del = setdiff( phase_ids, ind_vec );
    
    % construct boolean vector using ismember to handle multiple indices
    tf_col1_ind = ismember(flabel(:,1), ind_vec_del);
    tf_col2_ind = ismember(flabel(:,2), ind_vec_del);
    tf_col1_minus1 = flabel(:,1) == -1;
    tf_col2_minus1 = flabel(:,2) == -1;

    % if flabel(j,:) == [ind_vec_del(s), positive_number]
    %   change it to [-1, positive_number]
    tf_temp = tf_col1_ind & ~tf_col2_minus1;
    flabelnew( tf_temp, 1 ) = -1;
    
    % if flabel(j,:) == [positive_number, ind_vec_del(s)]
    %   change it to [positive_number, -1]
    tf_temp = ~tf_col1_minus1 & tf_col2_ind;
    flabelnew( tf_temp, 2 ) = -1;

    % if flabel(j,:) == [ind_vec_del(s),-1] or [-1, ind_vec_del(s)]
    %   delete corresponding row in F, flabel
    tf_temp = (tf_col1_ind & tf_col2_minus1) | (tf_col1_minus1 & tf_col2_ind);
    Fnew( tf_temp, : ) = [];
    flabelnew( tf_temp, : ) = [];
    
    % Remove redundant node in V
    [ Vnew, Fnew ] = delRedundantVertex( V, Fnew );
    
end