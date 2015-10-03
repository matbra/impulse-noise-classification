function [p_impulsive_noise_overall, st_blocks, st_impulses] = detect_impulsive_noise(filename_input, T_block)

fs = 44100; % todo: unfix

T_safety_gap = 50e-3;
L_safety_gap = floor(T_safety_gap * fs);
L_safety_gap = 2 * floor(L_safety_gap/2); % even
L_safety_gap_half = L_safety_gap / 2;

st_settings = settings();

b_beat = true;

switch T_block
    case {1, 0.5, 0.1}
        tab_model = readtable(fullfile(st_settings.dir_signal_set, st_settings.dir_sub_result_tables, sprintf('model_%.0fms.csv', T_block*1000)), 'ReadRowNames', true);
    otherwise
        error('This block length is not supported.');
end

% determine the size of the file
st_audioinfo = audioinfo(filename_input);

L_block = floor(T_block * st_audioinfo.SampleRate);
if mod(L_block, 2)
    L_block = L_block + 1; % make even
end
L_feed = L_block / 1;

L_DFT = 1024;

% load the file
x = audioread(filename_input);

x_preprocessed = zeros(size(x));

% run the beat detector
T_peak_search_region = 100e-3;
tempo_multiplier = 1;
st_beat_detection_result = detect_beats(x, fs, T_peak_search_region, tempo_multiplier);
idx_beats = [st_beat_detection_result.st_beat_info.sample_pos];

vec_window = sqrt(hanning(L_DFT,'periodic'));

% preprocessing
detectorsignal_mode = 'phat';
switch(detectorsignal_mode)
    case 'phat'
        for a = 1 : st_audioinfo.NumChannels;
            mat_X = spectrogram(x(:,a),vec_window,L_DFT/2,L_DFT,st_audioinfo.SampleRate,'yaxis');
            
            % this is the phat-transform:
            x_temp = ispecgram((ones(size(mat_X)).*exp(j*angle(mat_X))), L_DFT,st_audioinfo.SampleRate);
            x_preprocessed(1:length(x_temp), a) = x_temp;
        end
end

L_x_preprocessed = length(x_preprocessed);

N_blocks = floor( (L_x_preprocessed - (L_block - L_feed)) / L_feed );

st_blocks = struct('idx_start', [], ...
    'idx_end', [], ...
    'idx_channel', [], ...
    'p_impulsive_noise', []);
st_blocks = repmat(st_blocks, N_blocks * st_audioinfo.NumChannels, 1); % TODO : multichannel

st_impulses = struct('idx_start', [], ...
    'idx_end', [], ...
    'idx_channel', [], ...
    'p_impulsive_noise', []);

for p = 1 : N_blocks
    idx_start = (p-1) * L_feed + 1;
    idx_end = (p-1) * L_feed + L_block;
    
    for a = 1 : st_audioinfo.NumChannels
        
        vec_b_valid = true(L_block, 1);
        
        idx_beats_in_cur_block = find(idx_beats >= idx_start & ...
            idx_beats <= (idx_start + L_block - 1));
        
        idx_relative_to_block_start = idx_beats(idx_beats_in_cur_block) - idx_start + 1;
        
        for b = 1 : length(idx_relative_to_block_start)
            idx_beat = idx_relative_to_block_start(b);
            
            idx_start_clear = idx_beat - L_safety_gap_half;
            idx_start_clear = max(idx_start_clear, 1);
            idx_end_clear = idx_beat + L_safety_gap_half;
            idx_end_clear = min(idx_end_clear, L_block);
            
            vec_idx_clear = idx_start_clear : idx_end_clear;
            
            vec_b_valid(vec_idx_clear) = false;
        end
        
        % read a block from the audio file
        x_preprocessed_p = x_preprocessed(idx_start:idx_end, a);
        
        if b_beat
            % remove invalid parts
            x_preprocessed_p = x_preprocessed_p(vec_b_valid);
        end
        
        st_features_p = compute_features(x_preprocessed_p);
        
        % pre-process the features
        c_fieldnames_features = fieldnames(st_features_p);
        for b = 1 : length(c_fieldnames_features)
            cur_fieldname_feature = c_fieldnames_features{b};
            temp = deal(table2array(tab_model({cur_fieldname_feature}, {'mean', 'std'})));
            cur_mean = temp(1);
            cur_std = temp(2);
            st_features_p_processed.(cur_fieldname_feature) = ...
                (st_features_p.(cur_fieldname_feature) - cur_mean) / cur_std;
        end
        
        % make a prediction for the current block
        X = struct2mat(st_features_p_processed, false, c_fieldnames_features)';
        X = [ones(size(X, 1), 1), X]';
        
        intercept = table2array(tab_model('intercept', 'coef'));
        
        theta = intercept;
        
        for b = 1 : length(c_fieldnames_features)
            theta(b+1, 1) = table2array(tab_model(c_fieldnames_features{b}, 'coef'));
        end
        
        h_theta_p = X' * theta;
        p_disturbed_p = sigmoid(h_theta_p);
        
        idx_write = (p-1) * st_audioinfo.NumChannels + a;
        st_blocks(idx_write).idx_start = idx_start;
        st_blocks(idx_write).idx_end = idx_end;
        st_blocks(idx_write).idx_channel = a;
        st_blocks(idx_write).p_impulsive_noise = p_disturbed_p;
    end
end

p_impulsive_noise_overall = mean([st_blocks.p_impulsive_noise]);