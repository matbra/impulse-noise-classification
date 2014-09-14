function st_features = compute_features(x_a)%, fs, T_block, idx_impulse)

% no rhythm considerations so far
% 
% L_x = length(x);
% 
% L_block = floor(fs * T_block);
% 
% L_feed = L_block;
% 
% N_blocks = floor( (L_x - (L_block - L_feed)) / L_feed );
% 
b_compress = false;
% 
% for a = 1 : N_blocks
%     idx_start = (a-1) * L_feed + 1;
%     idx_end = (a-1) * L_feed + L_block;
%     
%     idx_impulse_in_this_block = idx_impulse(find(idx_impulse >= idx_start & idx_impulse <= idx_end));
%     
%     idx_in_cur_block = idx_impulse_in_this_block - idx_start;
%     
%     b_impulse_in_cur_block = ~isempty(idx_impulse_in_this_block);
%     
%     x_a = x(idx_start:idx_end);
    
    
    
    if false
        bla = prctile(x_a, (0:100));
        figure(1); if b_impulse_in_cur_block, plot(x_a, 'r'), else plot(x_a, 'g'), end
        figure(2); if b_impulse_in_cur_block, plot(bla, 'r'), else plot(bla, 'g'), end
    end
    
    if true
        % normalize the declick signal
        sigma_x_a = trimvar(x_a, 5);
        x_a = x_a ./ sigma_x_a;
    end
    
    
    if b_compress
        x_a = sign(x_a) .* x_a.^2;
    end
    
    vec_b_valid = true(length(x_a), 1);
    
    %     for a = 1 : length(idx_beats)
    %         idx_beat = idx_beats(a);
    %
    %         idx_start_clear = idx_beat - L_safety_gap_half;
    %         idx_start_clear = max(idx_start_clear, 1);
    %         idx_end_clear = idx_beat + L_safety_gap_half;
    %         idx_end_clear = min(idx_end_clear, length(x_a));
    %
    %         vec_idx_clear = idx_start_clear : idx_end_clear;
    %
    %
    %
    %         if false
    %             x_a(vec_idx_clear) = 0;%Data(vec_idx_clear, kk) .* vec_window;
    %         else
    %             vec_b_valid(vec_idx_clear) = false;
    %         end
    %     end
    
%     if false
%         figure(10);
%         plot(x_a);
%         hold on;
%         plot(find(~vec_b_valid), x_a(~vec_b_valid), 'r');
%         hold off;
%     end
%     
%     if false
%         figure(1);
%         plot([InternalData(1:length(x_a)) x_a-0.5])
%     end
%     
%     if false
%         % takes long...
%         [xc,lags] = xcorr(x_a(vec_b_valid),x_a(vec_b_valid),'coeff');
%         idx = lags>5000;
%     end
%     
%     if false
%         % compute spectrum
%         % (assuming white prediction error signal for tonal signals)
%         L_DFT = 2^nextpow2(L_block);
%         X_a = fft(x_a, L_DFT);
%         
%         X_a = X_a(1:L_DFT/2+1);
%         
%         per_x_a = real(X_a .* conj(X_a));
%         
%         figure(1), subplot(311); plot(x_a); subplot(312), plot(20*log10(abs(X_a))); subplot(313); plot(unwrap(angle(X_a)))
%     end
    
    
    
    %figure;plot(lags(idx),xc(idx));
    
%     if false%b_removeNoise
%         th = 3 * var(x_a.^(1/2));
%         %             vec_b_valid = vec_b_valid & abs(x_a)>th;
%         x_a(abs(x_a)<th) = 0;
%     end
%     
%     %     [MaxData,MaxIdx] = max(abs(xc(idx)));
%     %     %         kurData = kurtosis(x_a);
%     %     %         kurCorr = kurtosis(xc(idx));
%     %     cf =  peak2rms(x_a(vec_b_valid));
%     
%     if false
%         % takes long...
%         [xc_all,lags] = xcorr(x_a,x_a,'coeff');
%         idx_all = lags>5000;
%         [MaxData_all, MaxIdx_all] = max(abs(xc_all(idx_all)));
%         st_features.acf_value = MaxData_all;
%         st_features.acf_delay = (MaxIdx_all+4999) / fs;
%     end
    
    st_features.peak2rms = peak2rms(x_a);
%     st_features.peak2trimmedrms_1 = peak2trimmedrms(x_a, 1);
%     st_features.peak2trimmedrms_2 = peak2trimmedrms(x_a, 2);
%     st_features.peak2trimmedrms_5 = peak2trimmedrms(x_a, 5);
%     st_features.peak2trimmedrms_10 = peak2trimmedrms(x_a, 10);
%     st_features.peak2trimmedrms_20 = peak2trimmedrms(x_a, 20);
%     st_features.peak2rmeds = peak2rmeds(x_a);
    
    st_features.kurtosis = kurtosis(x_a);
%     st_features.skewness = skewness(x_a);
%     st_features.sparseness = sparseness(x_a);
    
    if false
        st_features.peak2prc95 = max(abs(x_a)) / prctile(x_a, 95);
        st_features.peak2prc96 = max(abs(x_a)) / prctile(x_a, 96);
        st_features.peak2prc97 = max(abs(x_a)) / prctile(x_a, 97);
        st_features.peak2prc98 = max(abs(x_a)) / prctile(x_a, 98);
        st_features.peak2prc99 = max(abs(x_a)) / prctile(x_a, 99);
    end
    
%     abs_x_a = abs(x_a);
%     st_features.peak2rms_abs = peak2rms(abs_x_a);
%     st_features.peak2rmeds_abs = peak2rmeds(abs_x_a);
%     
%     st_features.kurtosis_abs = kurtosis(abs_x_a);
%     st_features.skewness_abs = skewness(abs_x_a);
%     st_features.sparseness_abs = sparseness(abs_x_a);
    
    if false
        st_features.peak2prc95_abs = max(abs(abs_x_a)) / prctile(abs_x_a, 95);
        st_features.peak2prc96_abs = max(abs(abs_x_a)) / prctile(abs_x_a, 96);
        st_features.peak2prc97_abs = max(abs(abs_x_a)) / prctile(abs_x_a, 97);
        st_features.peak2prc98_abs = max(abs(abs_x_a)) / prctile(abs_x_a, 98);
        st_features.peak2prc99_abs = max(abs(abs_x_a)) / prctile(abs_x_a, 99);
    end
    
    
%     if false
%         % step-by-step remove the largest abs-values until we reach the 99%
%         % quantile. the mean distance of the points removed then is a feature
%         % for click presence.
%         val_target = prctile(abs(x_a), 99);
%         x_analyse = x_a;
%         vec_b_valid = true(L_block, 1);
%         val_max = max(x_analyse);
%         %     while mean(abs(x_analyse(vec_b_valid))) > val_target
%         while val_max > val_target
%             [val_max, idx_max] = max(abs(x_analyse(vec_b_valid)));
%             temp_idx = find(vec_b_valid);
%             idx_max = temp_idx(idx_max);
%             vec_b_valid(idx_max) = false;
%             %         figure(2); plot(vec_b_valid); drawnow
%             %         val_max
%         end
%         
%         st_features.removalspread = sparseness(vec_b_valid);
%         n = (diff(find(maxfilt1(~vec_b_valid, 20))));
%         st_features.removalspread_1 = mean(n(n>1));
%         st_features.removalspread_2 = median(n(n>1));
%         st_features.removalspread_3 = sum(maxfilt1(~vec_b_valid, 20));
%         st_features.removalspread_4 = st_features.removalspread_1 / st_features.removalspread_3;
%         st_features.removalspread_5 = st_features.removalspread_1 * st_features.removalspread_3;
%     end
    
%     st_features.removalspread = sparseness(vec_b_valid);
%     n = (diff(find(maxfilt1(~vec_b_valid, 20))));
%     st_features.removalspread_1 = mean(n(n>1));
%     st_features.removalspread_2 = median(n(n>1));
%     st_features.removalspread_3 = sum(maxfilt1(~vec_b_valid, 20));
%     st_features.removalspread_4 = st_features.removalspread_1 / st_features.removalspread_3;
%     st_features.removalspread_5 = st_features.removalspread_1 * st_features.removalspread_3;
    
    
    %     st_features.peak2rms_validOnly = cf;
    %     st_features.peak2rmeds_validOnly = peak2rmeds(x_a(vec_b_valid));
    %     st_features.acf_value_validOnly = MaxData;
    %     st_features.acf_delay_validOnly = (MaxIdx+4999) / fs;
    %     st_features.kurtosis_validOnly = kurtosis(x_a(vec_b_valid));
    %     st_features.skewness_validOnly = skewness(x_a(vec_b_valid));
    %     st_features.sparseness_validOnly = sparseness(x_a(vec_b_valid));
    
    %     st_features.residual_ratio = 10*log10(var(x_a) / var(DataIn));
    %     st_features.residual_ratio_validOnly = 10*log10(var(x_a(vec_b_valid)) / var(DataIn(vec_b_valid)));
%     if false
%         % takes long...
%         vec_quantiles = (0.05:0.05:0.95)';
%         for cur_idx_quantile = 1 : length(vec_quantiles)
%             cur_quantile = vec_quantiles(cur_idx_quantile);
%             
%             cur_quantile_value = quantile(x_a, cur_quantile);
%             %         cur_quantile_value_validOnly = quantile(x_a(vec_b_valid), cur_quantile);
%             
%             st_features.(sprintf('quantile_%03.0f', cur_quantile*100)) = cur_quantile_value;
%             %         st_features.(sprintf('quantile_%03.0f_validOnly', cur_quantile*100)) = cur_quantile_value_validOnly;
%         end
%     end
    
    
    if false
        % takes long...
        % compute l-moments
        vec_lmom = lmom(x_a, 5);
        st_features.L1 = vec_lmom(1);
        st_features.L2 = vec_lmom(2);
        st_features.L3 = vec_lmom(3);
        st_features.L4 = vec_lmom(4);
        st_features.L5 = vec_lmom(5);
        
        vec_lmom_validOnly = lmom(x_a(vec_b_valid), 5);
        %     st_features.L1_validOnly = vec_lmom_validOnly(1);
        %     st_features.L2_validOnly = vec_lmom_validOnly(2);
        %     st_features.L3_validOnly = vec_lmom_validOnly(3);
        %     st_features.L4_validOnly = vec_lmom_validOnly(4);
        %     st_features.L5_validOnly = vec_lmom_validOnly(5);
        
        % some more features
        %     st_features.peak2rmeds_validOnlyDividedByPeak2rmeds = st_features.peak2rmeds_validOnly / st_features.peak2rmeds;
        %     st_features.L4_validOnlyDividedByL2_validOnly = st_features.L4_validOnly / st_features.L2_validOnly;
        %     st_features.L5_validOnlyDividedByL3_validOnly = st_features.L5_validOnly / st_features.L3_validOnly;
        
        st_features.L4_dividedByL2 = st_features.L4 / st_features.L2;
        st_features.L5_dividedByL3 = st_features.L5 / st_features.L3;
    end
    
%     st_features.b_impulse_in_cur_block = b_impulse_in_cur_block;
%     st_features.idx_in_cur_block = idx_in_cur_block;
    
%     st_features_all(a) = st_features;
    
end